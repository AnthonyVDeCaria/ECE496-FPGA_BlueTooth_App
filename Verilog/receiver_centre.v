/*
	Anthony De Caria - November 29, 2016

	This module handles the receiver logic for the ECE496-FPGA_Bluetooth_App.
	
	Algorithms:
		If we're #Collecting_Data
			And the UART_rx sends a done signal
				We set a timer - #Checking_if_Done
					If before the timer is done the UART_rx gets new data
						We go back to #Collecting_Data
					Else
						We're #Done
						Which after a clock cycle means we go back to #Collecting_Data
	
		If we're in DS Mode 
			And we're #Idle
				If new piece of data comes in
					Store it
					Since we got one, go to #Got_One
						And wait for the next piece of data
						When it comes in
							Store it
							Go back to #Idle
			And we're #Done
				Handle each case
					Start
						If the select is valid
							Set the select to whatever the user passed
							Set flag to 1
						Else
							Set everything to 0
					Cancel
						Set flag to 0
				Otherwise
					Don't set anything
					UNLESS we reset
						Then set everything to 0
			Otherwise
				Chill
				
		If we're in AT Mode
			And we get a new piece of data
				Add it to the RFIFO
			And we're #Done
				Set the at_response_flag
			Otherwise
				Chill
*/

module receiver_centre(
		clock, reset, want_at, fpga_rxd,
		uart_cpd, uart_timer_cap,
		at_response_flag,
		RFIFO_rd_en, RFIFO_out, RFIFO_wr_count, RFIFO_rd_count, RFIFO_full, RFIFO_empty,
		stream_select, ds_sending_flag,
		commands, operands, l_r_ds_sending_flag, r_r_ds_sending_flag, ds_sending_flag_value, rc_curr, rc_next, c, n, timer, n_timer
	);
	/*
		I/Os
	*/
	input clock, reset, want_at, fpga_rxd;

	input [9:0] uart_cpd;
	input [9:0] uart_timer_cap;
	
	output at_response_flag;
	
	input RFIFO_rd_en;
	output [15:0] RFIFO_out;
	output [12:0] RFIFO_wr_count;
	output [11:0] RFIFO_rd_count; 
	output RFIFO_full;
	output RFIFO_empty;
	
	output [7:0] stream_select;
	output ds_sending_flag;
	
	/*
		Wires
	*/
	wire [7:0] rx_data;
	wire is_uart_collecting_data, rx_done;
	wire at_mode, data_mode;
	
	parameter Start = 8'h00, Cancel = 8'h01;
	
	assign at_mode = want_at;
	assign data_mode = ~want_at;
	
	/*
		FSM Wires
	*/
	parameter Collecting_Data = 2'b00, Checking_if_Done = 2'b01, Done = 2'b10;
	output reg [1:0] rc_curr, rc_next;
	
	parameter Idle = 1'b0, Got_One = 1'b1; 
	output reg c, n;
	
	/*
		Receiver Hardware
	*/
	//	UART
	UART_rx rx(
		.clk(clock),
		.resetn(~reset),
		.cycles_per_databit(uart_cpd),
		.rx_line(fpga_rxd),
		.rx_data(rx_data),
		.collecting_data(is_uart_collecting_data),
		.rx_data_valid(rx_done)
	);
	
	//	FIFO
	wire RFIFO_wr_en;
	assign RFIFO_wr_en = rx_done & at_mode;
	
	FIFO_8192_8in_16out RFIFO(
		.rst(reset),
		
		.wr_clk(clock),
		.rd_clk(clock),
		
		.wr_en(RFIFO_wr_en),
		.rd_en(RFIFO_rd_en),
		
		.din(rx_data),
		.dout(RFIFO_out),
		
		.full(RFIFO_full),
		.empty(RFIFO_empty),
		
		.rd_data_count(RFIFO_rd_count),
		.wr_data_count(RFIFO_wr_count)
	);
	
	//	User Commands
	output [7:0] commands, operands;
	wire r_r_commands, l_r_commands;
	wire r_r_operands, l_r_operands;
	
	assign r_r_commands = ~reset;
	assign r_r_operands = ~reset;
	
	assign l_r_commands = rx_done & data_mode & (c == Idle);
	assign l_r_operands = rx_done & data_mode & (c == Got_One);
	
	register_8bit_enable_async r_commands(.clk(clock), .resetn(r_r_commands), .enable(l_r_commands), .select(l_r_commands), .d(rx_data), .q(commands) );
	register_8bit_enable_async r_operands(.clk(clock), .resetn(r_r_operands), .enable(l_r_operands), .select(l_r_operands), .d(rx_data), .q(operands) );
	
	/*
		Interpreter Hardware
	*/
	// AT
	assign at_response_flag = (rc_curr == Done) & at_mode;
	
	// Data
	wire begin_understanding_orders, operand_is_0;
	assign begin_understanding_orders = (rc_curr == Done) & data_mode;
	assign operand_is_0 = (operands == 8'h00) ? 1'b1 : 1'b0;
	
	reg l_r_stream_select;
	wire r_r_stream_select;
	assign r_r_stream_select = ~reset; 
	register_8bit_enable_async r_stream_select(.clk(clock), .resetn(r_r_stream_select), .enable(l_r_stream_select), .select(l_r_stream_select), .d(operands), .q(stream_select) );
	
	output reg l_r_ds_sending_flag, ds_sending_flag_value;
	output r_r_ds_sending_flag;
	assign r_r_ds_sending_flag = ~reset;
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
		if(begin_understanding_orders)
		begin
			case(commands)
				Start:
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
		Timer
	*/
	output [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (rc_curr == Checking_if_Done);
	assign r_r_timer = ~(reset | (rc_curr == Collecting_Data) ) ;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == uart_timer_cap) ? 1'b1 : 1'b0;
	
	/*
		FSMs
	*/
	// Receiving
	always@(*)
	begin
		case(rc_curr)
			Collecting_Data:
			begin
				if(rx_done)
					rc_next = Checking_if_Done;
				else
					rc_next = Collecting_Data;
			end
			Checking_if_Done:
			begin
				if(is_uart_collecting_data)
					rc_next = Collecting_Data;
				else
				begin
					if(timer_done)
						rc_next = Done;
					else
						rc_next = Checking_if_Done;
				end
			end
			Done:
			begin
				rc_next = Collecting_Data;
			end
			
			default:
			begin
				rc_next = Collecting_Data;
			end
		endcase
	end
	
	// Storing User Data
	always@(*)
	begin
		case(c)
			Idle:
			begin
				if(rx_done & data_mode)
					n = Got_One;
				else
					n = Idle;
			end
			Got_One:
			begin
				if(rx_done & data_mode)
					n = Idle;
				else
					n = Got_One;
			end
			default:
			begin
				n = Idle;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin 
			rc_curr <= Collecting_Data;
			c <= Idle;
		end
		else
		begin
			rc_curr <= rc_next;
			c <= n;
		end
	end
	
endmodule

