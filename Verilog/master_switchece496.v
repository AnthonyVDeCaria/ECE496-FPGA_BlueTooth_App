module master_switchece496(bt_state, timer_cap, open_streams, next_sel);
	input bt_state;
	input [9:0] timer_cap;
	input[7:0] open_streams;
	
	output reg[3:0] next_sel;
	
	reg[2:0] counter = 3'b000;

	//	Timer ~800ms 
	wire [9:0] timer, n_timer;
	wire l_r_timer, timer_done;
	reg r_r_timer = 1'b1;
	
	assign l_r_timer = bt_state;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;

	always@(*)
	begin
		
	end

	always@(*)
	begin
		if (bt_state == 1'b0)
		begin
			next_sel <= 4'b1000;
		end
		else
		begin
			if (timer_done == 1'b1)
			begin
				if (open_streams & 8'b00000001 == 8'b00000001 && counter == 3'b000)
				begin
					next_sel <= 4'b0000;
					r_r_timer <= 1'b0;
				end
				else if (open_streams & 8'b00000010 == 8'b00000010 && counter == 3'b001)
				begin
					next_sel <= 4'b0001;
					r_r_timer <= 1'b0;
				end
				else if (open_streams & 8'b00000100 == 8'b00000100  && counter == 3'b010)
				begin
					next_sel <= 4'b0010;
					r_r_timer <= 1'b0;
				end
				else if (open_streams & 8'b00001000 == 8'b00001000  && counter == 3'b011)
				begin
					next_sel <= 4'b0011;
					r_r_timer <= 1'b0;
				end
				else if (open_streams & 8'b00010000 == 8'b00010000  && counter == 3'b100)
				begin
					next_sel <= 4'b0100;
					r_r_timer <= 1'b0;
				end
				else if (open_streams & 8'b00100000 == 8'b00100000 && counter == 3'b101)
				begin
					next_sel <= 4'b0101;
					r_r_timer <= 1'b0;
				end
				else if (open_streams & 8'b01000000 == 8'b01000000  && counter == 3'b110)
				begin
					next_sel <= 4'b0110;
					r_r_timer <= 1'b0;
				end
				else if (open_streams & 8'b10000000 == 8'b10000000 && counter == 3'b111)
				begin
					next_sel <= 4'b0111;
					r_r_timer <= 1'b0;
				end
				else 
				begin 
					if (counter != 3'b111)
					begin 
						counter <= counter + 3'b001;
					end
					else
					begin 
						counter <= 3'b000;
					end
					r_r_timer <= 1'b1;
				end
			end
			else 
			begin
				r_r_timer <= 1'b1;
			end
		end
	end
endmodule
	
