/*
	Anthony De Caria - October 16, 2016

	This module creates a UART transmittor.
	
	Algorithm:
		#Idle
			If we get the ok to start
				Load o, the data and 1 into a 10_bit reg - #Prepare_Data
				Put data[i] onto the line - #Send_Data
				And start the timer
					If the timer goes off
						Add one to i - #Add_i
							If i == 9
								Set the done flag - #Done
									If start is low
										Go to #Idle
									Else
										Stay in #Done
							Else
								Go back to #Send_Data 
					Else
						Keep the data on the line
			Else
				#Idle
*/

module UART_tx(clk, resetn, start, cycles_per_databit, tx_line, tx_data, tx_done);
	/*
		I/Os
	*/
	input clk, resetn, start;	
	input [9:0] cycles_per_databit; //Allows for 1024 cycles between each databit
	input [7:0] tx_data;

	output tx_done;
	output tx_line;
	
	/*
		Wires
	*/
	// Timer
	wire l_tx_timer, rn_tx_timer;
	wire at_cpd;
	
	// i
	wire [3:0] i, n_i;
	wire l_r_i, r_r_i;
	
	// Sending
	wire [9:0] din, dout;
	wire l_r_safety;
	reg current_dout;
	wire dout_select;
	
	// FSM
	reg [2:0] utx_curr, utx_next;
	parameter Idle = 3'b000, Prepare_Data = 3'b001, Send_Data = 3'b010, Add_i = 3'b011, Done = 3'b100;
	
	/*
		Timer 
	*/	
	assign l_tx_timer = ((utx_curr == Send_Data) & (~at_cpd));
	assign rn_tx_timer = ~(~resetn | (utx_curr == Idle) | (utx_curr == Add_i) ) ;
	
	timer_10bit tx_timer(
		.clock(clk), 
		.resetn_timer(rn_tx_timer), 
		.timer_active(l_tx_timer), 
		.timer_final_value(cycles_per_databit), 
		.timer_done(at_cpd)
	);
	
	/*
		i
	*/	
	assign l_r_i = (utx_curr == Add_i);
	assign r_r_i = ~(~resetn | (utx_curr == Idle) );
	
	adder_subtractor_4bit a_i(.a(i), .b(4'b0001), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_4bit_enable_async r_i(.clk(clk), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		Sending Data
	*/	
	assign din[9] = 1'b1;
	assign din[8:1] = tx_data[7:0];
	assign din[0] = 1'b0;
	
	assign l_r_safety = (utx_curr == Prepare_Data);
	
	register_10bit_enable_async r_safety(.clk(clk), .resetn(resetn), .enable(l_r_safety), .select(l_r_safety), .d(din), .q(dout) );
	
	always@(*)
	begin
		if(utx_curr == Send_Data)
			current_dout = dout[i];
	end
	
	assign dout_select = (utx_curr == Send_Data) | (utx_curr == Add_i);
	mux_2_1bit m_dout(.data0(1'b1), .data1(current_dout), .sel(dout_select), .result(tx_line) );
	
	/*
		FSM
	*/
	
	always@(*)
	begin
		case(utx_curr)
			Idle: 
			begin
				if(start)
					utx_next = Prepare_Data;
				else
					utx_next = Idle;
			end
			
			Prepare_Data:
			begin
				utx_next = Send_Data;
			end
			
			Send_Data:
			begin
				if(!at_cpd)
					utx_next = Send_Data;
				else
					utx_next = Add_i;
			end
			
			Add_i:
			begin
				if(i[3] == 1'b1 && i[0] == 1'b1)
					utx_next = Done;
				else
					utx_next = Send_Data;
			end
			
			Done:
			begin
				if(start)
					utx_next = Done;
				else
					utx_next = Idle;
			end
			
			default:
			begin
				utx_next = Idle;
			end
		endcase
	end
	
	always@(posedge clk or negedge resetn)
	begin
		if(!resetn) 
			utx_curr <= Idle; 
		else 
			utx_curr <= utx_next;
	end
	
	assign tx_done = (utx_curr == Done);
	
endmodule

