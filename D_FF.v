/*
Anthony De Caria - October 2, 2016

This is a simple D Flip Flop.
*/

module D_FF(clk, d, q);
	
	input clk;
	input d;
	output reg q;
	
	always @(posedge clk)
	begin
		q <= d;
	end
	
endmodule
