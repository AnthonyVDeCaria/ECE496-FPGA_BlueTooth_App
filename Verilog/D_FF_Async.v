/*
Anthony De Caria - March 07, 2017

This is a D Flip Flop with an asynchronous reset.
*/

module D_FF_Async(clk, resetn, d, q);
	
	input clk;
	input resetn;
	input d;
	output reg q;
	
	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
		begin
			q <= 1'b0;
		end
		else
		begin
			q <= d;
		end
	end
	
endmodule
