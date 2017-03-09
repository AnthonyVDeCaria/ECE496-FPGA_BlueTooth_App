/*
	Anthony De Caria - March 4, 2017
	
	This module check's the HM-10 BLE module's State line
	to see if a device is connected.
	
	The line will either be solid if there's a connection
	And a periodic square wave if not.
	
	Algorithm:
	
	Reset Timer - #Wait_for_Line
	Get State Line Before_Edge
	If we have an edge change
		Start the clock - #Wait_for_Clock
		Get State Line After_Edge
		If sc_timer_done
			Compare Before_Edge and After_Edge - #Check_Edge
			If there is no change
				The edge change must have been a glitch - back to #Wait_for_Line
			Else
				#Master_Check
				If the New State Line (After_Edge) is 0 - meaning we have no connection
					Reset Connection_Flag
				Else
					If Old State Line is 0
						Do Nothing
					Else
						The line is 1 after a while, so we have a connection - Load Connection_Flag
				Load Old State Line
				Go back to #Wait_for_Line
		Else
			#Wait_for_Clock
	Else
		#Wait_for_Line
	
*/

module HM_10_State_Check(sc_curr, sc_next, original_sl, new_sl, after_edge, before_edge,
clock, reset, state_line, connection_flag);
	/*
		I/Os
	*/
	input clock, reset;
	input state_line;
	output connection_flag;
	
	/*
		FSM Parameters
	*/
	parameter Wait_for_Line = 2'b00, Wait_for_Clock = 2'b01, Check_Edge = 2'b10, Master_Check = 2'b11;
	
	output reg [1:0] sc_curr, sc_next;
	
	/*
		Wires
	*/
	wire r_r_connection_flag, l_r_connection_flag;
	
	wire edge_rising, edge_falling, either_edge;
	
	output original_sl, new_sl, after_edge, before_edge;
	wire r_r_original_sl, l_r_original_sl;
	wire r_r_after_edge, l_r_after_edge;
	wire r_r_before_edge, l_r_before_edge;
	wire same_edge;
	assign same_edge = (after_edge == before_edge) ? 1'b1 : 1'b0;
	
	//Timer
	wire [19:0] sc_timer, n_sc_timer;
	wire l_r_sc_timer, r_r_sc_timer, sc_timer_done;
	parameter sc_limit = 20'd250000;
	
	/*
		Edge Detector
	*/
	edge_detector_1bit TK(.clock(clock), .reset(reset), .signal(state_line), .rising(edge_rising), .falling(edge_falling), .either(either_edge));
	
	/*
		Registers
	*/
	assign r_r_before_edge = ~(reset);
	assign l_r_before_edge = (sc_curr == Wait_for_Line); 
	register_1bit_enable_async r_before_edge(
		.clk(clock), .resetn(r_r_before_edge), 
		.enable(l_r_before_edge), .select(l_r_before_edge), 
		.d(state_line), .q(before_edge)
	);
	
	assign r_r_after_edge = ~reset;
	assign l_r_after_edge = (sc_curr == Wait_for_Clock);
	register_1bit_enable_async r_after_edge(
		.clk(clock), .resetn(r_r_after_edge), 
		.enable(l_r_after_edge), .select(l_r_after_edge), 
		.d(state_line), .q(after_edge) 
	);
	
	assign r_r_new_sl = ~reset;
	assign l_r_new_sl = (sc_curr == Check_Edge) & ~same_edge;
	register_1bit_enable_async r_new_sl(
		.clk(clock), .resetn(r_r_new_sl), 
		.enable(l_r_new_sl), .select(l_r_new_sl), 
		.d(after_edge), .q(new_sl) 
	);
	
	assign r_r_original_sl = ~reset;
	assign l_r_original_sl = (sc_curr == Master_Check);
	register_1bit_enable_async r_original_sl(
		.clk(clock), .resetn(r_r_original_sl), 
		.enable(l_r_original_sl), .select(l_r_original_sl), 
		.d(state_line), .q(original_sl) 
	);
	
	assign r_r_connection_flag = ~(reset | ~new_sl);
	assign l_r_connection_flag = ((sc_curr == Master_Check) & new_sl & original_sl);
	register_1bit_enable_async r_connection_flag(
		.clk(clock), .resetn(r_r_connection_flag), 
		.enable(l_r_connection_flag), .select(l_r_connection_flag), 
		.d(1'b1), .q(connection_flag)
	);
	
	/*
		Timer
	*/
	assign r_r_sc_timer = ~(reset | (sc_curr == Wait_for_Line));
	assign l_r_sc_timer = (sc_curr == Wait_for_Clock);
	adder_subtractor_20bit a_sc_timer(.a(sc_timer), .b(20'd1), .want_subtract(1'b0), .c_out(), .s(n_sc_timer) );
	register_20bit_enable_async r_sc_timer(.clk(clock), .resetn(r_r_sc_timer), .enable(l_r_sc_timer), .select(l_r_sc_timer), .d(n_sc_timer), .q(sc_timer) );
	assign sc_timer_done = (sc_timer == sc_limit) ? 1'b1 : 1'b0;
	
	/*
		FSM
	*/	
	always@(*)
	begin
		case(sc_curr)
			Wait_for_Line:
			begin
				if(either_edge)
					sc_next = Wait_for_Clock;
				else
					sc_next = Wait_for_Line;
			end
			Wait_for_Clock:
			begin
				if(sc_timer_done)
					sc_next = Check_Edge;
				else
					sc_next = Wait_for_Clock;
			end
			Check_Edge:
			begin
				if(same_edge)
					sc_next = Wait_for_Line;
				else
					sc_next = Master_Check;
			end
			Master_Check:
			begin
				sc_next = Wait_for_Line;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			sc_curr <= Wait_for_Line;
		end
		else
		begin
			sc_curr <= sc_next;
		end
	end
endmodule
