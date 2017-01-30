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
							Determine the packet complete pc_rd_count values
							If the first bit in the shift register is 0 or has no data
								Loop to the next bit
								Add 1 to i
							If the first bit in the shift register is 1 and it has data
								Set the mux_select to the index - #Run
								Set a timer
								If we've sent both chars
									Do some checking - #Check
									If we've finished sending the packet
										And there's nothing left or the timer is finished
											Add 1 to i
											And go back to #Find
										Otherwise
											Keep the channel open for the next packet - #Run
									Else
										We keep the line open to send the next one - #Run
								Else
									Do nothing
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
		want_at, sending_flag, both_chars_sent,
		empty_fifo_flags, 
		selected_streams, 
		DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count,
		mux_select, select_ready
	);
	/*
		I/O
	*/
	input clock, resetn;
	input want_at, sending_flag, both_chars_sent;
	input [7:0] empty_fifo_flags;
	input [7:0] selected_streams;
	input [5:0] DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count;
	
	output reg [3:0] mux_select;
	output reg select_ready;
	
	parameter timer_cap = 10'd1000;
	
	/*
		FSM Wires
	*/
	parameter Idle = 3'b000, AT = 3'b111, Load_Shift = 3'b001, Find = 3'b010, Run = 3'b011, Check = 3'b100;
	reg [2:0] ms_curr, ms_next;
	
	/*
		Interal Flags
	*/
	wire [7:0] rd_equals_pc, ds_rd_count_not_0, i_is;
	wire shift_0_is_0_in_find, eff_i_is_1_in_find, eff_i_is_1_in_check, timer_done_in_check;
	
	assign ds_rd_count_not_0[0] = (DS0_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[1] = (DS1_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[2] = (DS2_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[3] = (DS3_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[4] = (DS4_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[5] = (DS5_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[6] = (DS6_rd_count != 6'h00) ? 1'b1 : 1'b0;
	assign ds_rd_count_not_0[7] = (DS7_rd_count != 6'h00) ? 1'b1 : 1'b0;
	
	assign rd_equals_pc[0] = (new_rd_count0 == pc_rd_count0) ? 1'b1 : 1'b0;
	assign rd_equals_pc[1] = (new_rd_count1 == pc_rd_count1) ? 1'b1 : 1'b0;
	assign rd_equals_pc[2] = (new_rd_count2 == pc_rd_count2) ? 1'b1 : 1'b0;
	assign rd_equals_pc[3] = (new_rd_count3 == pc_rd_count3) ? 1'b1 : 1'b0;
	assign rd_equals_pc[4] = (new_rd_count4 == pc_rd_count4) ? 1'b1 : 1'b0;
	assign rd_equals_pc[5] = (new_rd_count5 == pc_rd_count5) ? 1'b1 : 1'b0;
	assign rd_equals_pc[6] = (new_rd_count6 == pc_rd_count6) ? 1'b1 : 1'b0;
	assign rd_equals_pc[7] = (new_rd_count7 == pc_rd_count7) ? 1'b1 : 1'b0;
	
	assign i_is[0] = (i == 3'b000) ? 1'b1 : 1'b0;
	assign i_is[1] = (i == 3'b001) ? 1'b1 : 1'b0;
	assign i_is[2] = (i == 3'b010) ? 1'b1 : 1'b0;
	assign i_is[3] = (i == 3'b011) ? 1'b1 : 1'b0;
	assign i_is[4] = (i == 3'b100) ? 1'b1 : 1'b0;
	assign i_is[5] = (i == 3'b101) ? 1'b1 : 1'b0;
	assign i_is[6] = (i == 3'b110) ? 1'b1 : 1'b0;
	assign i_is[7] = (i == 3'b111) ? 1'b1 : 1'b0;
	
	assign shift_0_is_0_in_find = ((ms_curr == Find) & ~shift[0]);
	assign eff_i_is_1_in_find = ((ms_curr == Find) & empty_fifo_flags[i]);
	assign eff_i_is_1_in_check = ((ms_curr == Check) & empty_fifo_flags[i]);
	assign timer_done_in_check = ((ms_curr == Check) & timer_done);
	
	/*
		Shift Register
	*/
	wire [7:0] shift;
	wire r_sr_shift, e_sr_shift, s_sr_shift;
	
	assign r_sr_shift = ~( ~resetn | (ms_curr == Idle) );
	assign e_sr_shift = (ms_curr == Load_Shift) | shift_0_is_0_in_find | eff_i_is_1_in_find | eff_i_is_1_in_check | timer_done_in_check;
	assign s_sr_shift = (ms_curr == Load_Shift);
	
	cyclical_right_shift_register_8_async sr_shift(.clk(clock), .resetn(r_sr_shift), .enable(e_sr_shift), .select(s_sr_shift), .d(selected_streams), .q(shift) );
	
	/*
		i
	*/
	wire r_r_i, l_r_i;
	wire [2:0] i, n_i;
	
	assign r_r_i = ~( ~resetn | (ms_curr == Idle) );
	assign l_r_i = shift_0_is_0_in_find | eff_i_is_1_in_find | eff_i_is_1_in_check | timer_done_in_check;
	
	adder_subtractor_3bit a_i(.a(i), .b(3'b001), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_3bit_enable_async r_i(.clk(clock), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		RD_Count Values
	*/
	wire [5:0] n_pc_rd_count0, n_pc_rd_count1, n_pc_rd_count2, n_pc_rd_count3, n_pc_rd_count4, n_pc_rd_count5, n_pc_rd_count6, n_pc_rd_count7;
	wire [5:0] pc_rd_count0, pc_rd_count1, pc_rd_count2, pc_rd_count3, pc_rd_count4, pc_rd_count5, pc_rd_count6, pc_rd_count7;
	wire [7:0] l_r_pc_rd_count, r_r_pc_rd_count;
	
	assign l_r_pc_rd_count[0] = ds_rd_count_not_0[0] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[0]) & rd_equals_pc[0] & ~empty_fifo_flags[0] & ~timer_done));
	assign l_r_pc_rd_count[1] = ds_rd_count_not_0[1] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[1]) & rd_equals_pc[1] & ~empty_fifo_flags[1] & ~timer_done));
	assign l_r_pc_rd_count[2] = ds_rd_count_not_0[2] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[2]) & rd_equals_pc[2] & ~empty_fifo_flags[2] & ~timer_done));
	assign l_r_pc_rd_count[3] = ds_rd_count_not_0[3] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[3]) & rd_equals_pc[3] & ~empty_fifo_flags[3] & ~timer_done));
	assign l_r_pc_rd_count[4] = ds_rd_count_not_0[4] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[4]) & rd_equals_pc[4] & ~empty_fifo_flags[4] & ~timer_done));
	assign l_r_pc_rd_count[5] = ds_rd_count_not_0[5] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[5]) & rd_equals_pc[5] & ~empty_fifo_flags[5] & ~timer_done));
	assign l_r_pc_rd_count[6] = ds_rd_count_not_0[6] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[6]) & rd_equals_pc[6] & ~empty_fifo_flags[6] & ~timer_done));
	assign l_r_pc_rd_count[7] = ds_rd_count_not_0[7] & ((ms_curr == Find) | ((ms_curr == Check) & (i_is[7]) & rd_equals_pc[7] & ~empty_fifo_flags[7] & ~timer_done));
	
	assign r_r_pc_rd_count[0] = resetn;
	assign r_r_pc_rd_count[1] = resetn;
	assign r_r_pc_rd_count[2] = resetn;
	assign r_r_pc_rd_count[3] = resetn;
	assign r_r_pc_rd_count[4] = resetn;
	assign r_r_pc_rd_count[5] = resetn;
	assign r_r_pc_rd_count[6] = resetn;
	assign r_r_pc_rd_count[7] = resetn;
	
	adder_subtractor_6bit a_pc_rd_count0(.a(6'd4), .b(DS0_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count0) );
	register_6bit_enable_async r_pc_rd_count0 (.clk(clock), .resetn(r_r_pc_rd_count[0]), .enable(l_r_pc_rd_count[0]), .select(l_r_pc_rd_count[0]), .d(n_pc_rd_count0), .q(pc_rd_count0) );
	
	adder_subtractor_6bit a_pc_rd_count1(.a(6'd4), .b(DS1_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count1) );
	register_6bit_enable_async r_pc_rd_count1 (.clk(clock), .resetn(r_r_pc_rd_count[1]), .enable(l_r_pc_rd_count[1]), .select(l_r_pc_rd_count[1]), .d(n_pc_rd_count1), .q(pc_rd_count1) );
	
	adder_subtractor_6bit a_pc_rd_count2(.a(6'd4), .b(DS2_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count2) );
	register_6bit_enable_async r_pc_rd_count2 (.clk(clock), .resetn(r_r_pc_rd_count[2]), .enable(l_r_pc_rd_count[2]), .select(l_r_pc_rd_count[2]), .d(n_pc_rd_count2), .q(pc_rd_count2) );
	
	adder_subtractor_6bit a_pc_rd_count3(.a(6'd4), .b(DS3_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count3) );
	register_6bit_enable_async r_pc_rd_count3 (.clk(clock), .resetn(r_r_pc_rd_count[3]), .enable(l_r_pc_rd_count[3]), .select(l_r_pc_rd_count[3]), .d(n_pc_rd_count3), .q(pc_rd_count3) );
	
	adder_subtractor_6bit a_pc_rd_count4(.a(6'd4), .b(DS4_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count4) );
	register_6bit_enable_async r_pc_rd_count4 (.clk(clock), .resetn(r_r_pc_rd_count[4]), .enable(l_r_pc_rd_count[4]), .select(l_r_pc_rd_count[4]), .d(n_pc_rd_count4), .q(pc_rd_count4) );
	
	adder_subtractor_6bit a_pc_rd_count5(.a(6'd4), .b(DS5_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count5) );
	register_6bit_enable_async r_pc_rd_count5 (.clk(clock), .resetn(r_r_pc_rd_count[5]), .enable(l_r_pc_rd_count[5]), .select(l_r_pc_rd_count[5]), .d(n_pc_rd_count5), .q(pc_rd_count5) );
	
	adder_subtractor_6bit a_pc_rd_count6(.a(6'd4), .b(DS6_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count6) );
	register_6bit_enable_async r_pc_rd_count6 (.clk(clock), .resetn(r_r_pc_rd_count[6]), .enable(l_r_pc_rd_count[6]), .select(l_r_pc_rd_count[6]), .d(n_pc_rd_count6), .q(pc_rd_count6) );
	
	adder_subtractor_6bit a_pc_rd_count7(.a(6'd4), .b(DS7_rd_count), .want_subtract(1'b1), .c_out(), .s(n_pc_rd_count7) );
	register_6bit_enable_async r_pc_rd_count7 (.clk(clock), .resetn(r_r_pc_rd_count[7]), .enable(l_r_pc_rd_count[7]), .select(l_r_pc_rd_count[7]), .d(n_pc_rd_count7), .q(pc_rd_count7) );
	
	wire [7:0] l_r_new_rd_count, r_r_new_rd_count;
	wire [5:0] new_rd_count0, new_rd_count1, new_rd_count2, new_rd_count3, new_rd_count4, new_rd_count5, new_rd_count6, new_rd_count7;
	
	assign l_r_new_rd_count[0] = (ms_curr == Run) & (i_is[0]);
	assign l_r_new_rd_count[1] = (ms_curr == Run) & (i_is[1]);
	assign l_r_new_rd_count[2] = (ms_curr == Run) & (i_is[2]);
	assign l_r_new_rd_count[3] = (ms_curr == Run) & (i_is[3]);
	assign l_r_new_rd_count[4] = (ms_curr == Run) & (i_is[4]);
	assign l_r_new_rd_count[5] = (ms_curr == Run) & (i_is[5]);
	assign l_r_new_rd_count[6] = (ms_curr == Run) & (i_is[6]);
	assign l_r_new_rd_count[7] = (ms_curr == Run) & (i_is[7]);
	
	assign r_r_new_rd_count[0] = resetn;
	assign r_r_new_rd_count[1] = resetn;
	assign r_r_new_rd_count[2] = resetn;
	assign r_r_new_rd_count[3] = resetn;
	assign r_r_new_rd_count[4] = resetn;
	assign r_r_new_rd_count[5] = resetn;
	assign r_r_new_rd_count[6] = resetn;
	assign r_r_new_rd_count[7] = resetn;
	
	register_6bit_enable_async r_new_rd_count0 (.clk(clock), .resetn(r_r_new_rd_count[0]), .enable(l_r_new_rd_count[0]), .select(l_r_new_rd_count[0]), .d(DS0_rd_count), .q(new_rd_count0) );
	register_6bit_enable_async r_new_rd_count1 (.clk(clock), .resetn(r_r_new_rd_count[1]), .enable(l_r_new_rd_count[1]), .select(l_r_new_rd_count[1]), .d(DS1_rd_count), .q(new_rd_count1) );
	register_6bit_enable_async r_new_rd_count2 (.clk(clock), .resetn(r_r_new_rd_count[2]), .enable(l_r_new_rd_count[2]), .select(l_r_new_rd_count[2]), .d(DS2_rd_count), .q(new_rd_count2) );
	register_6bit_enable_async r_new_rd_count3 (.clk(clock), .resetn(r_r_new_rd_count[3]), .enable(l_r_new_rd_count[3]), .select(l_r_new_rd_count[3]), .d(DS3_rd_count), .q(new_rd_count3) );
	register_6bit_enable_async r_new_rd_count4 (.clk(clock), .resetn(r_r_new_rd_count[4]), .enable(l_r_new_rd_count[4]), .select(l_r_new_rd_count[4]), .d(DS4_rd_count), .q(new_rd_count4) );
	register_6bit_enable_async r_new_rd_count5 (.clk(clock), .resetn(r_r_new_rd_count[5]), .enable(l_r_new_rd_count[5]), .select(l_r_new_rd_count[5]), .d(DS5_rd_count), .q(new_rd_count5) );
	register_6bit_enable_async r_new_rd_count6 (.clk(clock), .resetn(r_r_new_rd_count[6]), .enable(l_r_new_rd_count[6]), .select(l_r_new_rd_count[6]), .d(DS6_rd_count), .q(new_rd_count6) );
	register_6bit_enable_async r_new_rd_count7 (.clk(clock), .resetn(r_r_new_rd_count[7]), .enable(l_r_new_rd_count[7]), .select(l_r_new_rd_count[7]), .d(DS7_rd_count), .q(new_rd_count7) );
	
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
				
				if(both_chars_sent)
					ms_next = Check;
				else
					ms_next = Run;
			end
			Check:
			begin
				mux_select = 4'bZZZZ;
				select_ready = 1'b0;
				
				if(rd_equals_pc[i])
				begin
					if(!empty_fifo_flags[i])
					begin
						if(timer_done)
							ms_next = Find;
						else
							ms_next = Run;
					end
					else
						ms_next = Find;
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
	
