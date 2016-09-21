/*
Anthony De Caria - November 04, 2014

This module creates a 1-bit two input Mux.
*/

module mux_2_1bit(data0, data1, sel, result);
	input data0, data1;
	input sel;
	output reg result;
	
	always@(*)
	begin
		if (~sel)
		begin
			result <= data0;
		end
		else
		begin
			result <= data1;
		end
	end
endmodule
