/*
	Anthony De Caria - December 27, 2016

	This module creates the mux_select that will be used to select between datastreams in our ECE496 project.
	
	Algorithm
		See if we sending at all
			If we are
				Load the Shift Register
				Then - #Find
					Assuming we're still sending
						Determine the packet complete pc_rd_count values
						If the first bit in the shift register is 0 or has no data
							Loop to the next bit
							Add 1 to i
						Else the first bit in the shift register is 1 and it has data
							Set the mux_select to the index - #Run
							Set a timer
							If we've sent the full packet
								Do some checking - #Check
								If the channel has no more packets
									Add 1 to i
									And go back to #Find
								Else If the timer is finished
									Add 1 to i
									And go back to #Find
								Otherwise
									Keep the channel open for the next packet - #Run
							Else
								We keep the line open to finish sending it - #Run
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
		sending_flag, packet_sent,
		empty_fifo_flags, 
		selected_streams, 
		mux_select, select_ready
	);
	/*
		I/O
	*/
	input clock, resetn;
	input sending_flag, packet_sent;
	input [7:0] empty_fifo_flags;
	input [7:0] selected_streams;
	
	output reg [2:0] mux_select;
	output reg select_ready;
	
	parameter timer_cap = 32'd35000;
	
	/*
		FSM Wires
	*/
	parameter Idle = 3'b000, Load_Shift = 3'b001, Find = 3'b010, Run = 3'b011, Check = 3'b100;
	reg [2:0] ms_curr, ms_next;
	
	/*
		Interal Flags
	*/
	wire [7:0] i_is;
	wire shift_0_is_0_in_find, eff_i_is_1_in_find, eff_i_is_1_in_check, timer_done_in_check;
	
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
		Timer
	*/
	wire [31:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (ms_curr == Run) & ~timer_done;
	assign r_r_timer = ~( ~resetn | (ms_curr == Find) );
	
	adder_subtractor_32bit a_timer(.a(timer), .b(32'd1), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_32bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(ms_curr)
			Idle: 
			begin
				mux_select = 3'bZZZ;
				select_ready = 1'b0;
				
				if(sending_flag)
					ms_next = Load_Shift;
				else
					ms_next = Idle;
			end
			Load_Shift:
			begin
				mux_select = 3'bZZZ;
				select_ready = 1'b0;
				
				ms_next = Find;
			end
			Find:
			begin
				mux_select = 3'bZZZ;
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
				mux_select = i;
				select_ready = 1'b1;
				
				if(packet_sent)
					ms_next = Check;
				else
					ms_next = Run;
			end
			Check:
			begin
				mux_select = 3'bZZZ;
				select_ready = 1'b0;
				
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
			default:
			begin
				mux_select = 3'bZZZ;
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
	
