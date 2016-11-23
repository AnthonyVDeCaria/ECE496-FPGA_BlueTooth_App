/*
Anthony De Caria - September 26, 2016

This module creates a 16-bit two input Mux.
*/

module mux_2_16bit(data0, data1, sel, result);
	input [15:0] data0, data1;
	input sel;
	output reg [15:0] result;
	
	always@(*)
	begin
		if (sel == 1'b0)
		begin
			result <= data0;
		end
		else if (sel == 1'b1)
		begin
			result <= data1;
		end
	end
endmodule

