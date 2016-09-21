/*
Anthony De Caria - September 20, 2016

This is a test module for transmitting a byte serially.
*/

module test_transmission (clock_2p5Hz, resetn, tx);
	input clock_2p5Hz, resetn;
	output tx;
	
	wire [7:0] q_out;
	wire load, move;
	
	assign tx = q_out[7];
	
	Shift_Register_8_Enable_Async_OneLoad test_reg(.clk(clock_2p5Hz), .resetn(resetn), .enable(move), .select(load), .d(8'h8F), .q(q_out) );
	
	
	
endmodule
