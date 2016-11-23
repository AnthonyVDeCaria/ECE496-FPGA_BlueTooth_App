/*
Anthony De Caria - November 04, 2014

This is a D Flip Flop with a separate enable and an asynchronous reset.
*/

module D_FF_Enable_Async(clk, resetn, enable, d, q);
	
	input clk;
	input resetn;
	input enable;
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
			if (enable)
			begin
				q <= d;
			end
		end
	end
	
endmodule
