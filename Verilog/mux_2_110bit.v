/*
Anthony De Caria - January 29, 2017

This module creates a 110-bit two input Mux.
*/

module mux_2_110bit(data0, data1, sel, result);
	input [109:0] data0, data1;
	input sel;
	output reg [109:0] result;
	
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
