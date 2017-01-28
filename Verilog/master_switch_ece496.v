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
							Determine the triggers
							If the first bit in the shift register is 0
								Loop through until we find 1
								Keeping track of the index
							If the first bit in the shift register is 1
								And there's data there
									Set the mux_select to the index - #Run
									Set a timer
									If we finish sending the packet
										And the timer is finished
											Go to the next index
											And go back to #Find
										Otherwise
											Keep the channel open for the next packet
									Else
										Do nothing
								Else
									Keep looking
						If we aren't
							Do nothing
							Reset everything
			If we aren't
				Do nothing
				Reset everything
				
	A cycial shift register will make sure we never lose any information.
	It should go to the right so we can go through streams in ascending order: 0->1->2..->6->7->0...
*/
module master_switch_ece496(
		clock, resetn, 
		want_at, sending_flag, empty_fifo_flags, 
		selected_streams, 
		DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count,
		mux_select, select_ready,
		
		ms_curr, ms_next, rd_count_equals_trig, ds_rd_count_not_0,
		trig_DS0, trig_DS1, trig_DS2, trig_DS3, trig_DS4, trig_DS5, trig_DS6, trig_DS7
	);
	/*
		I/O
	*/
	input clock, resetn;
	input want_at, sending_flag;
	input [7:0] empty_fifo_flags;
	input [7:0] selected_streams;
	input [5:0] DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count;
	
	output reg [3:0] mux_select;
	output reg select_ready;
	
	parameter timer_cap = 10'd1000;
	
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
	
	output [7:0] rd_count_equals_trig, ds_rd_count_not_0;
	
	assign rd_count_equals_trig[0] = (DS0_rd_count == trig_DS0) ? 1'b1 : 1'b0;
	assign rd_count_equals_trig[1] = (DS1_rd_count == trig_DS1) ? 1'b1 : 1'b0;
	assign rd_count_equals_trig[2] = (DS2_rd_count == trig_DS2) ? 1'b1 : 1'b0;
	assign rd_count_equals_trig[3] = (DS3_rd_count == trig_DS3) ? 1'b1 : 1'b0;
	assign rd_count_equals_trig[4] = (DS4_rd_count == trig_DS4) ? 1'b1 : 1'b0;
	assign rd_count_equals_trig[5] = (DS5_rd_count == trig_DS5) ? 1'b1 : 1'b0;
	assign rd_count_equals_trig[6] = (DS6_rd_count == trig_DS6) ? 1'b1 : 1'b0;
	assign rd_count_equals_trig[7] = (DS7_rd_count == trig_DS7) ? 1'b1 : 1'b0;
	
	assign ds_rd_count_not_0[0] = (DS0_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[1] = (DS1_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[2] = (DS2_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[3] = (DS3_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[4] = (DS4_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[5] = (DS5_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[6] = (DS6_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[7] = (DS7_rd_count != 6'h00) ? 1'b1 : 1'b0;
	
	/*
		Trigger FIFO rd Values
	*/
	wire [5:0] n_trig_DS0, n_trig_DS1, n_trig_DS2, n_trig_DS3, n_trig_DS4, n_trig_DS5, n_trig_DS6, n_trig_DS7;
	output [5:0] trig_DS0, trig_DS1, trig_DS2, trig_DS3, trig_DS4, trig_DS5, trig_DS6, trig_DS7;
	wire [7:0] l_r_trig_DS, r_r_trig_DS;
	
	assign l_r_trig_DS[0] = ds_rd_count_not_0[0] & ((ms_curr == Find) | (rd_count_equals_trig[0] & ~timer_done & (ms_curr == Run)));
	assign l_r_trig_DS[1] = ds_rd_count_not_0[1] & ((ms_curr == Find) | (rd_count_equals_trig[1] & ~timer_done & (ms_curr == Run)));
	assign l_r_trig_DS[2] = ds_rd_count_not_0[2] & ((ms_curr == Find) | (rd_count_equals_trig[2] & ~timer_done & (ms_curr == Run)));
	assign l_r_trig_DS[3] = ds_rd_count_not_0[3] & ((ms_curr == Find) | (rd_count_equals_trig[3] & ~timer_done & (ms_curr == Run)));
	assign l_r_trig_DS[4] = ds_rd_count_not_0[4] & ((ms_curr == Find) | (rd_count_equals_trig[4] & ~timer_done & (ms_curr == Run)));
	assign l_r_trig_DS[5] = ds_rd_count_not_0[5] & ((ms_curr == Find) | (rd_count_equals_trig[5] & ~timer_done & (ms_curr == Run)));
	assign l_r_trig_DS[6] = ds_rd_count_not_0[6] & ((ms_curr == Find) | (rd_count_equals_trig[6] & ~timer_done & (ms_curr == Run)));
	assign l_r_trig_DS[7] = ds_rd_count_not_0[7] & ((ms_curr == Find) | (rd_count_equals_trig[7] & ~timer_done & (ms_curr == Run)));
	
	assign r_r_trig_DS[0] = resetn;
	assign r_r_trig_DS[1] = resetn;
	assign r_r_trig_DS[2] = resetn;
	assign r_r_trig_DS[3] = resetn;
	assign r_r_trig_DS[4] = resetn;
	assign r_r_trig_DS[5] = resetn;
	assign r_r_trig_DS[6] = resetn;
	assign r_r_trig_DS[7] = resetn;
	
	adder_subtractor_6bit a_trig_DS0(.a(6'd4), .b(DS0_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS0) );
	register_6bit_enable_async r_trig_DS0 (.clk(clock), .resetn(r_r_trig_DS[0]), .enable(l_r_trig_DS[0]), .select(l_r_trig_DS[0]), .d(n_trig_DS0), .q(trig_DS0) );
	
	adder_subtractor_6bit a_trig_DS1(.a(6'd4), .b(DS1_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS1) );
	register_6bit_enable_async r_trig_DS1 (.clk(clock), .resetn(r_r_trig_DS[1]), .enable(l_r_trig_DS[1]), .select(l_r_trig_DS[1]), .d(n_trig_DS1), .q(trig_DS1) );
	
	adder_subtractor_6bit a_trig_DS2(.a(6'd4), .b(DS2_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS2) );
	register_6bit_enable_async r_trig_DS2 (.clk(clock), .resetn(r_r_trig_DS[2]), .enable(l_r_trig_DS[2]), .select(l_r_trig_DS[2]), .d(n_trig_DS2), .q(trig_DS2) );
	
	adder_subtractor_6bit a_trig_DS3(.a(6'd4), .b(DS3_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS3) );
	register_6bit_enable_async r_trig_DS3 (.clk(clock), .resetn(r_r_trig_DS[3]), .enable(l_r_trig_DS[3]), .select(l_r_trig_DS[3]), .d(n_trig_DS3), .q(trig_DS3) );
	
	adder_subtractor_6bit a_trig_DS4(.a(6'd4), .b(DS4_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS4) );
	register_6bit_enable_async r_trig_DS4 (.clk(clock), .resetn(r_r_trig_DS[4]), .enable(l_r_trig_DS[4]), .select(l_r_trig_DS[4]), .d(n_trig_DS4), .q(trig_DS4) );
	
	adder_subtractor_6bit a_trig_DS5(.a(6'd4), .b(DS5_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS5) );
	register_6bit_enable_async r_trig_DS5 (.clk(clock), .resetn(r_r_trig_DS[5]), .enable(l_r_trig_DS[5]), .select(l_r_trig_DS[5]), .d(n_trig_DS5), .q(trig_DS5) );
	
	adder_subtractor_6bit a_trig_DS6(.a(6'd4), .b(DS6_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS6) );
	register_6bit_enable_async r_trig_DS6 (.clk(clock), .resetn(r_r_trig_DS[6]), .enable(l_r_trig_DS[6]), .select(l_r_trig_DS[6]), .d(n_trig_DS6), .q(trig_DS6) );
	
	adder_subtractor_6bit a_trig_DS7(.a(6'd4), .b(DS7_rd_count), .want_subtract(1'b1), .c_out(), .s(n_trig_DS7) );
	register_6bit_enable_async r_trig_DS7 (.clk(clock), .resetn(r_r_trig_DS[7]), .enable(l_r_trig_DS[7]), .select(l_r_trig_DS[7]), .d(n_trig_DS7), .q(trig_DS7) );
	
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
				
				if(rd_count_equals_trig[i])
				begin
					if(timer_done)
						ms_next = Find;
					else
						ms_next = Run;
				end
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
	
