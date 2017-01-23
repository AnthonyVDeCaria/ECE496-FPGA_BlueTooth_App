/*
	Anthony De Caria - December 27, 2016

	This module creates the mux_select that will be used to select between datastreams in our ECE496 project.
	
	Algorithm
		See if we sending at all
			If we are
				and we're in AT
					Set the mux_select to 4'b1000
					Until we're not sending anymore
				and we're in DS
					Load the Shift Register
					Then - #Find
						Assuming we're still sending
							If the first bit in the shift register is 0
								Loop through until we find 1
								Keeping track of the index
							If the first bit in the shift register is 1
								And there's data there
									Set the mux_select to the index
									Set a timer
									When the timer is finished
										Go to the ms_next index
										And go back to #Find
								Else
									Keep looking
			If we aren't
				Do nothing
				Reset everything
				
	A cycial shift register will make sure we never lose any information.
	It should go to the right so we can go through streams in ascending order: 0->1->2..->6->7->0...
*/
module master_switch_ece496(
		clock, resetn, 
		timer_cap,
		want_at, sending_flag, empty_fifo_flags, selected_streams, 
		mux_select, select_ready,
		
		ms_curr, ms_next
	);
	/*
		I/O
	*/
	input clock, resetn;
	input [9:0] timer_cap;
	input want_at, sending_flag;
	input [7:0] empty_fifo_flags;
	input [7:0] selected_streams;
	
	output reg [3:0] mux_select;
	output reg select_ready;
	
	/*
		FSM Wires
	*/
	parameter Idle = 3'b000, AT = 3'b111, Load_Shift = 3'b001, Find = 3'b010, Run = 3'b011;
	output reg [2:0] ms_curr, ms_next;
	
	/*
		Interal Flags
	*/
	wire shift_0_is_0_in_find, eff_i_is_1_in_find, timer_done_in_run;
	assign shift_0_is_0_in_find = ((ms_curr == Find) & ~shift[0]);
	assign eff_i_is_1_in_find = ((ms_curr == Find) & empty_fifo_flags[i]);
	assign timer_done_in_run = ((ms_curr == Run) & timer_done);
	
	/*
		Timer
	*/
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (ms_curr == Run);
	assign r_r_timer = ~( ~resetn | (ms_curr == Find) );
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;
	
	/*
		Shift Register
	*/
	wire [7:0] shift;
	wire r_sr_shift, e_sr_shift, s_sr_shift;
	
	assign r_sr_shift = ~( ~resetn | (ms_curr == Idle) );
	assign e_sr_shift = (ms_curr == Load_Shift) | shift_0_is_0_in_find | eff_i_is_1_in_find | timer_done_in_run;
	assign s_sr_shift = (ms_curr == Load_Shift);
	
	cyclical_right_shift_register_8_async sr_shift(.clk(clock), .resetn(r_sr_shift), .enable(e_sr_shift), .select(s_sr_shift), .d(selected_streams), .q(shift) );
	
	/*
		i
	*/
	wire r_r_i, l_r_i;
	wire [2:0] i, n_i;
	
	assign r_r_i = ~( ~resetn | (ms_curr == Idle) );
	assign l_r_i = shift_0_is_0_in_find | eff_i_is_1_in_find | timer_done_in_run;
	
	adder_subtractor_3bit a_i(.a(i), .b(3'b001), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_3bit_enable_async r_i(.clk(clock), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(ms_curr)
			Idle: 
			begin
				mux_select = 4'bZZZZ;
				select_ready = 1'b0;
				
				if(sending_flag)
				begin
					if(want_at)
						ms_next = AT;
					else
						ms_next = Load_Shift;
				end
				else
					ms_next = Idle;
			end
			AT:
			begin
				mux_select = 4'b1000;
				select_ready = 1'b1;
				
				if(sending_flag)
					ms_next = AT;
				else
					ms_next = Idle;
			end
			Load_Shift:
			begin
				mux_select = 4'bZZZZ;
				select_ready = 1'b0;
				
				ms_next = Find;
			end
			Find:
			begin
				mux_select = 4'bZZZZ;
				select_ready = 1'b0;
	
				if(sending_flag)
				begin
					if(shift[0])
					begin
						if(!empty_fifo_flags[i])
							ms_next = Run;
						else
							ms_next = Find;
					end
					else
						ms_next = Find;
				end
				else
					ms_next = Idle;
			end
			Run:
			begin
				mux_select[3] = 1'b0;
				mux_select[2:0] = i;
				select_ready = 1'b1;
				
				if(timer_done)
					ms_next = Find;
				else
					ms_next = Run;
			end
			default:
			begin
				mux_select = 4'bzzzz;
				select_ready = 1'b0;
				ms_next = Idle;
			end
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) ms_curr <= Idle; else ms_curr <= ms_next;
	end
endmodule
	
