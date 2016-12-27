/*
Anthony De Caria - December 27, 2016

This module creates a 10 bit Timer using asynchronous D Flip Flops.
*/

module timer_10bit_async(clock, timer_cap, l_r_timer, r_r_timer, timer_done);
	
	//Define the inputs and outputs
	input	clock;
	input	l_r_timer, r_r_timer;
	input	[9:0] timer_cap;
	output	timer_done;
	
	wire [9:0] timer, n_timer;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;

endmodule
