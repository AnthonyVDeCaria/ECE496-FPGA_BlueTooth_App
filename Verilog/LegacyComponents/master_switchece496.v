module master_switchece496(clock, resetn, bt_state, sending_flag, timer_cap, open_streams, next_sel,
counter, counter_check, timer, n_timer, r_r_timer, should_we_reset, timer_done
);
	/*
		I/O
	*/
	input clock, resetn;
	input bt_state, sending_flag;
	input [9:0] timer_cap;
	input [7:0] open_streams;
	
	output reg[3:0] next_sel;
	
	/*
		Wires and Regs
	*/
//	output invalid_os;
	output [7:0] counter_check;
	
	output [9:0] timer, n_timer;
	output r_r_timer, timer_done;
	wire l_r_timer;
	output reg should_we_reset = 1'b0;
	
	output reg [2:0] counter = 3'b000;
	
	/*
		Wire Assignments
	*/
//	assign invalid_os = (open_streams == 2'h00) ? 1'b1 : 1'b0;
	
	assign counter_check[0] = (counter == 3'b000) ? 1'b1 : 1'b0;
	assign counter_check[1] = (counter == 3'b001) ? 1'b1 : 1'b0;
	assign counter_check[2] = (counter == 3'b010) ? 1'b1 : 1'b0;
	assign counter_check[3] = (counter == 3'b011) ? 1'b1 : 1'b0;
	assign counter_check[4] = (counter == 3'b100) ? 1'b1 : 1'b0;
	assign counter_check[5] = (counter == 3'b101) ? 1'b1 : 1'b0;
	assign counter_check[6] = (counter == 3'b110) ? 1'b1 : 1'b0;
	assign counter_check[7] = (counter == 3'b111) ? 1'b1 : 1'b0;
	
	assign l_r_timer = sending_flag & bt_state & ~timer_done;
	assign r_r_timer = ~should_we_reset & resetn;
	
	/*
		Timer
	*/
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;

	always@(*)
	begin
		if (!bt_state)
		begin
			next_sel <= 4'b1000;
			should_we_reset <= 1'b1;
			counter <= 3'b000;
		end
		else
		begin
			if (!sending_flag)
			begin
				next_sel <= 4'bZZZZ;
				should_we_reset <= 1'b1;
				counter <= 3'b000;
			end
			else
			begin
				if (timer_done)
				begin
					if (open_streams[0] && counter_check[0])
					begin
						next_sel <= 4'b0000;
						should_we_reset <= 1'b1;
						counter <= 3'b001;
					end
					else if (open_streams[1] && counter_check[1])
					begin
						next_sel <= 4'b0001;
						should_we_reset <= 1'b1;
						counter <= 3'b010;
					end
					else if (open_streams[2] && counter_check[2])
					begin
						next_sel <= 4'b0010;
						should_we_reset <= 1'b1;
						counter <= 3'b011;
					end
					else if (open_streams[3] && counter_check[3])
					begin
						next_sel <= 4'b0011;
						should_we_reset <= 1'b1;
						counter <= 3'b100;
					end
					else if (open_streams[4] && counter_check[4])
					begin
						next_sel <= 4'b0100;
						should_we_reset <= 1'b1;
						counter <= 3'b101;
					end
					else if (open_streams[5] && counter_check[5])
					begin
						next_sel <= 4'b0101;
						should_we_reset <= 1'b1;
						counter <= 3'b110;
					end
					else if (open_streams[6] && counter_check[6])
					begin
						next_sel <= 4'b0110;
						should_we_reset <= 1'b1;
						counter <= 3'b111;
					end
					else if (open_streams[7] && counter_check[7])
					begin
						next_sel <= 4'b0111;
						should_we_reset <= 1'b1;
						counter <= 3'b000;
					end
					else
					begin
						if (counter_check[7])
						begin 
							counter <= 3'b000;
						end
						else
						begin 
							counter <= counter + 3'b001;
						end
					end
				end
				else 
				begin
					next_sel <= next_sel;
					should_we_reset <= 1'b0;
					counter <= counter;
				end
			end
		end
	end

endmodule
	
