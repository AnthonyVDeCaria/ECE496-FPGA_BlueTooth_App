/*
	Anthony De Caria - December 27, 2016

	This module creates the mux_select that will be used to select between datastreams in our ECE496 project.
*/
module master_switch_ece496(clock, resetn, want_at, bt_state, sending_flag, at_complete, timer_cap, selected_streams, mux_select);
	/*
		I/O
	*/
	input clock, resetn;
	input bt_state, want_at, sending_flag, at_complete;
	input [9:0] timer_cap;
	input [7:0] selected_streams;
	
	output reg[3:0] mux_select;
	
	/*
		FSM Wires
	*/
	parameter Idle = 3'b000, AT = 3'b111, Load_Shift = 3'b001, Find = 3'b010, Run = 3'b011;
	reg [2:0] curr, next;
	
	/*
		Timer
	*/
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (curr == Run);
	assign r_r_timer = ~( ~resetn | (curr == Find) );
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;
	
	/*
		Shift Register
	*/
	wire [7:0] shift;
	wire r_sr_shift, e_sr_shift, s_sr_shift;
	
	assign r_sr_shift = ~( ~resetn | (curr == Idle) );
	assign e_sr_shift = (curr == Load_Shift) | ((curr == Find) & ~shift[0]) | ((curr == Run) & timer_done);
	assign s_sr_shift = (curr == Load_Shift);
	
	cyclical_right_shift_register_8_async sr_shift(.clk(clock), .resetn(r_sr_shift), .enable(e_sr_shift), .select(s_sr_shift), .d(selected_streams), .q(shift) );
	
	/*
		i
	*/
	wire r_r_i, l_r_i;
	wire [2:0] i, n_i;
	
	assign r_r_i = ~( ~resetn | (curr == Idle) );
	assign l_r_i = ((curr == Find) & ~shift[0]) | ((curr == Run) & timer_done);
	
	adder_subtractor_3bit a_i(.a(i), .b(3'b001), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_3bit_enable_async r_i(.clk(clock), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			Idle: 
			begin
				mux_select <= 4'bZZZZ;
				
				if(sending_flag)
				begin
					if(want_at)
						next = AT;
					else
						next = Load_Shift;
				end
				else
					next = Idle;
			end
			AT:
			begin
				mux_select <= 4'b1000;
				
				if(at_complete)
					next = Idle;
				else
					next = AT;
			end
			Load_Shift:
			begin
				mux_select <= 4'bZZZZ;
				
				next = Find;
			end
			Find:
			begin
				mux_select <= 4'bZZZZ;
				
				if(bt_state)
				begin
					if(sending_flag)
					begin
						if(shift[0])
							next = Run;
						else
							next = Find;
					end
					else
						next = Idle;
				end
				else
					next = Idle;
			end
			Run:
			begin
				mux_select[3] <= 1'b0;
				mux_select[2:0] <= i;
				
				if(timer_done)
					next = Find;
				else
					next = Run;
			end
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= Idle; else curr <= next;
	end
endmodule
	