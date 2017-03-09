/*
Anthony De Caria - January 28, 2017

This module creates a 8-bit two input Mux.
*/

module mux_2_8bit(data0, data1, sel, result);
	input [7:0] data0, data1;
	input sel;
	output reg [7:0] result;
	
	always@(*)
	begin
		if (~sel)
		begin
			result = data0;
		end
		else
		begin
			result = data1;
		end
	end
endmodule
