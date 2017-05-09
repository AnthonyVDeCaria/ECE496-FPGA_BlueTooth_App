/*
	Anthony De Caria - April 1, 2017
	
	This module handles the commands from the App.

	Algorithm:
	Wait for the first piece of data to come in - #Wait_for_First
	If it comes in (uart_done) and we're needed (start)
		Store it in the first register
		Start a timer - #Wait_for_Second
		Wait for the next piece of data
		If it comes in (uart_done)
			Store it in the second register
			Set all the proper flags - #Analyze
			Go back to #Wait_for_First
		Else
			If it never comes in but the timer goes off(timer_done & !uart_done)
				Reset first register
				#Wait_for_First
			Else if the timer hasn't gone off
				#Wait_for_Second
	Else
		#Wait_for_First
*/
module handle_app_commands(
		clock, reset,
		start, uart_done,
		uart_cpd,
		uart_byte_spacing,
		uart_byte,
		stream_select, ds_sending_flag
	);
	/*
		I/Os
	*/
	// General
	input clock, reset;
	
	// Input Flags
	input start, uart_done;
	
	// Timer
	input [9:0] uart_byte_spacing, uart_cpd;
	
	// Analyze
	input [7:0] uart_byte;
	
	// Output Flags
	output [7:0]stream_select;
	output ds_sending_flag;
	
	/*
		Wires
	*/
	// Timer
	wire [9:0] full_byte_limit;
	wire l_hac_timer, rn_hac_timer, hac_timer_done;
	
	// Analyze 
	wire [7:0] commands, operands;
	wire r_r_commands, l_r_commands;
	wire r_r_operands, l_r_operands;
	
	parameter Start_Experiment = 8'h00, Cancel = 8'h01;
	
	wire operand_is_0;
	wire command_is_SE, command_is_Can;
	
	reg l_r_stream_select;
	wire r_r_stream_select;
	
	reg l_r_ds_sending_flag, ds_sending_flag_value;
	wire r_r_ds_sending_flag;
	
	//FSM
	parameter Wait_for_First = 2'b00, Wait_for_Second = 2'b01, Analyze = 2'b10;
	reg [1:0] ds_curr, ds_next;
	
	/*
		Assignments
	*/
	// Timer
	assign full_byte_limit = uart_cpd + uart_byte_spacing + uart_cpd * 8 + uart_cpd + uart_cpd;
	assign l_hac_timer = (ds_curr == Wait_for_Second); 
	assign rn_hac_timer = ~(reset | (ds_curr == Analyze));
	
	//Analyze
	assign r_r_commands = ~reset;
	assign l_r_commands = uart_done & start & (ds_curr == Wait_for_First);
	
	assign r_r_operands = ~(reset | command_is_Can);
	assign l_r_operands = uart_done & (ds_curr == Wait_for_Second) & command_is_SE;
	
	assign operand_is_0 = (operands == 8'h00) ? 1'b1 : 1'b0;
	
	assign command_is_SE = (commands == Start_Experiment) ? 1'b1 : 1'b0;
	assign command_is_Can = (commands == Cancel) ? 1'b1 : 1'b0;
	
	assign r_r_stream_select = ~(reset | command_is_Can); 
	
	assign r_r_ds_sending_flag = ~(reset | command_is_Can);
	
	/*
		Modules
	*/
	// Timer
	timer_10bit hac_timer(
		.clock(clock), 
		.resetn_timer(rn_hac_timer), 
		.timer_active(l_hac_timer), 
		.timer_final_value(full_byte_limit), 
		.timer_done(hac_timer_done)
	);
	
	//	Analyze	
	register_8bit_enable_async r_commands(.clk(clock), .resetn(r_r_commands), .enable(l_r_commands), .select(l_r_commands), .d(uart_byte), .q(commands) );
	register_8bit_enable_async r_operands(.clk(clock), .resetn(r_r_operands), .enable(l_r_operands), .select(l_r_operands), .d(uart_byte), .q(operands) );
	
	register_8bit_enable_async r_stream_select(
		.clk(clock), 
		.resetn(r_r_stream_select), 
		.enable(l_r_stream_select), 
		.select(l_r_stream_select), 
		.d(operands), 
		.q(stream_select) 
	);
	
	register_1bit_enable_async r_ds_sending_flag(
		.clk(clock), 
		.resetn(r_r_ds_sending_flag), 
		.enable(l_r_ds_sending_flag), 
		.select(l_r_ds_sending_flag), 
		.d(ds_sending_flag_value), 
		.q(ds_sending_flag) 
	);
	
	always@(*)
	begin
		if(ds_curr == Analyze)
		begin
			case(commands)
				Start_Experiment:
				begin
					if(operand_is_0)
					begin
						l_r_stream_select = 1'b0;
						
						l_r_ds_sending_flag = 1'b1;
						ds_sending_flag_value = 1'b0;
					end
					else
					begin
						l_r_stream_select = 1'b1;
						
						l_r_ds_sending_flag = 1'b1;
						ds_sending_flag_value = 1'b1;
					end
				end
				Cancel:
				begin
					l_r_stream_select = 1'b0;
					
					l_r_ds_sending_flag = 1'b1;
					ds_sending_flag_value = 1'b0;
				end
				default:
				begin
					l_r_stream_select = 1'b0;
					
					l_r_ds_sending_flag = 1'b0;
					ds_sending_flag_value = 1'b0;
				end
			endcase
		end
		else
		begin
			l_r_stream_select = 1'b0;
			
			l_r_ds_sending_flag = 1'b0;
			ds_sending_flag_value = 1'b0;
		end
	end
	
	/*
		FSMs
	*/
	always@(*)
	begin
		case(ds_curr)
			Wait_for_First:
			begin
				if(start & uart_done)
					ds_next = Wait_for_Second;
				else
					ds_next = Wait_for_First;
			end
			Wait_for_Second:
			begin
				if(uart_done)
					ds_next = Analyze;
				else
				begin
					if(hac_timer_done)
						ds_next = Wait_for_First;
					else
						ds_next = Wait_for_Second;
				end
			end
			Analyze:
			begin
				ds_next = Wait_for_First;
			end
			
			default:
			begin
				ds_next = Wait_for_First;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
			ds_curr <= Wait_for_First;
		else
			ds_curr <= ds_next;
	end
	
endmodule
