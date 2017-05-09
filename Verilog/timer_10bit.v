/*
Anthony De Caria - April 2, 2017

This module is a 10 bit timer.
It counts up to a final value before saying it's done.
It expects whoever is using it to reset and set the module properly.

*/

module timer_10bit(clock, resetn_timer, timer_active, timer_final_value, timer_done);
	/*
		I/Os
	*/
	input clock, resetn_timer, timer_active;
	input [9:0] timer_final_value;
	output timer_done;

	/*
		Wires
	*/
	// Declarations
	wire [9:0] timer, n_timer;
	
	//Assignments
	assign timer_done = (timer == timer_final_value) ? 1'b1 : 1'b0;
	
	/*
		Modules
	*/
	adder_subtractor_10bit a_timer(.a(timer), .b(10'd1), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(resetn_timer), .enable(timer_active), .select(timer_active), .d(n_timer), .q(timer) );
  
endmodule
