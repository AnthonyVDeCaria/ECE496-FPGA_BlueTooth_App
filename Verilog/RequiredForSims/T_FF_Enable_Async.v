/*
	Anthony De Caria - November 04, 2014

	This is a T Flip Flop that has an enable and an asynchronous reset.
	
	March 4, 2017 Edit - Removed reference to an input d
*/

module T_FF_Enable_Async(clk, resetn, enable, q);
	
	input clk;
	input resetn;
	input enable;
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
				q <= !q;
			end
		end
	end
	
endmodule
