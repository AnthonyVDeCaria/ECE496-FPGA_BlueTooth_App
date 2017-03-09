/*
	Anthony De Caria - March 7, 2017
	
	This module takes a one bit signal
	and determines if the line is rising or falling.
*/
module edge_detector_1bit(clock, reset, signal, rising, falling, either);
	/*
		I/Os
	*/
	input clock, reset;
	input signal;
	output rising, falling, either;
	
	wire reg_signal;
	
	D_FF_Async edge_reg(.clk(clock), .resetn(~reset), .d(signal), .q(reg_signal));
	
	assign rising = signal & ~reg_signal;
	assign falling = ~signal & reg_signal;
	assign either = rising | falling;
	
endmodule
