/*
Anthony De Caria - October 13, 2016

This is a D Flip Flop with a separate enable.
*/

module D_FF_Enable(clk, enable, d, q);
	
	input clk;
	input resetn;
	input enable;
	input d;
	output reg q;
	
	always @(posedge clk)
	begin
		if (enable)
		begin
			q <= d;
		end
	end
	
endmodule

