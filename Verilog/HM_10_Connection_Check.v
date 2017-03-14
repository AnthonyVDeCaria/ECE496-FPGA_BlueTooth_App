/*
	Anthony De Caria - March 4, 2017
	
	This module check's the HM-10 BLE module's State line
	to see if a device is connected.
	
	The line will either be solid if there's a connection
	And a periodic square wave if not.
	
	Algorithm:
	
	#Wait_for_Edge
	If state_line is falling
		Start timer - #Wait_for_Clock
		If cc_timer_done
			Get the state_line value - #Load_NL
			#Check
			If NL == OL
				Do Nothing
			Else
				If !NL
					Clear CF
				Else
					If !OL
						Do Nothing
					Else
						Load CF
			Load OL
			Back to #Wait_for_Clock
		Else
			#Wait_for_Clock
	Else
		#Wait_for_Edge
*/

module HM_10_Connection_Check(clock, reset, state_line, connection_flag, connection_warning_flag);
	/*
		I/Os
	*/
	input clock, reset;
	input state_line;
	output connection_flag, connection_warning_flag;
	
	/*
		FSM Parameters
	*/
	parameter Wait_for_Edge = 2'b00, Wait_for_Clock = 2'b01, Load_NL = 2'b10, Check = 2'b11;
	
	reg [1:0] cc_curr, cc_next;
	
	/*
		Wires
	*/
	wire r_r_connection_flag, l_r_connection_flag;
	
	wire edge_rising, edge_falling, either_edge;
	
	wire new_sl, original_sl;
	wire r_r_new_sl, l_r_new_sl;
	wire r_r_original_sl, l_r_original_sl;

	wire [19:0] cc_timer, n_cc_timer;
	wire l_r_cc_timer, r_r_cc_timer, cc_timer_done;
	parameter cc_limit = 20'd250000;
	
	assign connection_warning_flag = connection_flag & ~state_line;
	
	/*
		Edge Detector
	*/
	edge_detector_1bit TK(.clock(clock), .reset(reset), .signal(state_line), .rising(edge_rising), .falling(edge_falling), .either(either_edge));
	
	/*
		Registers
	*/
	assign r_r_new_sl = ~reset;
	assign l_r_new_sl = (cc_curr == Load_NL);
	register_1bit_enable_async r_new_sl(
		.clk(clock), .resetn(r_r_new_sl), 
		.enable(l_r_new_sl), .select(l_r_new_sl), 
		.d(state_line), .q(new_sl) 
	);
	
	assign r_r_original_sl = ~reset;
	assign l_r_original_sl = (cc_curr == Check);
	register_1bit_enable_async r_original_sl(
		.clk(clock), .resetn(r_r_original_sl), 
		.enable(l_r_original_sl), .select(l_r_original_sl), 
		.d(state_line), .q(original_sl) 
	);
	
	assign r_r_connection_flag = ~(reset | ~new_sl);
	assign l_r_connection_flag = ((cc_curr == Check) & new_sl & original_sl);
	register_1bit_enable_async r_connection_flag(
		.clk(clock), .resetn(r_r_connection_flag), 
		.enable(l_r_connection_flag), .select(l_r_connection_flag), 
		.d(1'b1), .q(connection_flag)
	);
	
	/*
		Timer
	*/
	assign r_r_cc_timer = ~(reset | (cc_curr == Load_NL) | either_edge);
	assign l_r_cc_timer = (cc_curr == Wait_for_Clock);
	adder_subtractor_20bit a_cc_timer(.a(cc_timer), .b(20'd1), .want_subtract(1'b0), .c_out(), .s(n_cc_timer) );
	register_20bit_enable_async r_cc_timer(.clk(clock), .resetn(r_r_cc_timer), .enable(l_r_cc_timer), .select(l_r_cc_timer), .d(n_cc_timer), .q(cc_timer) );
	assign cc_timer_done = (cc_timer == cc_limit) ? 1'b1 : 1'b0;
	
	/*
		FSM
	*/	
	always@(*)
	begin
		case(cc_curr)
			Wait_for_Edge:
			begin
				if(edge_falling)
					cc_next = Wait_for_Clock;
				else
					cc_next = Wait_for_Edge;
			end
			Wait_for_Clock:
			begin
				if(cc_timer_done)
					cc_next = Load_NL;
				else
					cc_next = Wait_for_Clock;
			end
			Load_NL:
			begin
				cc_next = Check;
			end
			Check:
			begin
				cc_next = Wait_for_Clock;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			cc_curr <= Wait_for_Edge;
		end
		else
		begin
			cc_curr <= cc_next;
		end
	end
endmodule
