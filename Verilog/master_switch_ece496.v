/*
	Anthony De Caria - December 27, 2016

	This module creates the mux_select that will be used to select between datastreams in our ECE496 project.
	
	Algorithm
		See if we sending at all - #Idle
			If we are
				Load the Shift Register - #Load_Shift
				Then - #Find
					Assuming we're still sending
						If the first bit in the shift register is 1 and it has data
							Wait for the FBC to let us know when to run - #Wait
							If we get the signal
								Set the mux_select to the index - #Run
								If we've sent the full packet
									Add 1 to i
									And go back to #Find
								Else
									We keep the line open to finish sending it - #Run
							Else
								#Wait
						Else
							Loop to the next bit
							Add 1 to i
							Back to #Find
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
		sending_flag, packet_sent, ready_to_send,
		empty_fifo_flags, 
		selected_streams, 
		mux_select, select_ready
	);
	/*
		I/O
	*/
	input clock, resetn;
	input sending_flag, packet_sent, ready_to_send;
	input [7:0] empty_fifo_flags;
	input [7:0] selected_streams;
	
	output reg [2:0] mux_select;
	output reg select_ready;
	
	/*
		FSM Wires
	*/
	parameter Idle = 3'b000, Load_Shift = 3'b001, Find = 3'b010, Wait = 3'b011, Run = 3'b100;
	reg [2:0] ms_curr, ms_next;
	
	/*
		Interal Flags
	*/
	wire shift_0_is_0_in_find, eff_i_is_1_in_find, packet_sent_in_run;
	
	assign shift_0_is_0_in_find = (ms_curr == Find) & ~shift[0];
	assign eff_i_is_1_in_find = (ms_curr == Find) & empty_fifo_flags[i];
	assign packet_sent_in_run = (ms_curr == Run) & packet_sent;
	
	/*
		Shift Register
	*/
	wire [7:0] shift;
	wire r_sr_shift, e_sr_shift, s_sr_shift;
	
	assign r_sr_shift = ~( ~resetn | (ms_curr == Idle) );
	assign e_sr_shift = (ms_curr == Load_Shift) | shift_0_is_0_in_find | eff_i_is_1_in_find | packet_sent_in_run;
	assign s_sr_shift = (ms_curr == Load_Shift);
	
	cyclical_right_shift_register_8_async sr_shift(
		.clk(clock), 
		.resetn(r_sr_shift), 
		.enable(e_sr_shift), 
		.select(s_sr_shift), 
		.d(selected_streams), 
		.q(shift)
	);
	
	/*
		i
	*/
	wire r_r_i, l_r_i;
	wire [2:0] i, n_i;
	
	assign r_r_i = ~( ~resetn | (ms_curr == Idle) );
	assign l_r_i = shift_0_is_0_in_find | eff_i_is_1_in_find | packet_sent_in_run;
	
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
							ms_next = Wait;
						else
							ms_next = Find;
					end
					else
						ms_next = Find;
				end
				else
					ms_next = Idle;
			end
			Wait:
			begin
				mux_select = 3'bZZZ;
				select_ready = 1'b0;
				
				if(ready_to_send)
					ms_next = Run;
				else
					ms_next = Wait;
			end
			Run:
			begin
				mux_select = i;
				select_ready = 1'b1;
				
				if(packet_sent)
					ms_next = Find;
				else
					ms_next = Run;
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
		if(!resetn) 
			ms_curr <= Idle;
		else 
			ms_curr <= ms_next;
	end
endmodule
	
