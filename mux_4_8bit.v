/*
Anthony De Caria - September 24, 2016

This module creates a 8-bit four input Mux.
*/

module mux_4_8bit(data0, data1, data2, data3, sel, result);
	input [7:0] data0, data1, data2, data3;
	input [1:0] sel;
	output reg [7:0] result;
	
	always@(*)
	begin
		if (sel == 2'b00)
		begin
			result <= data0;
		end
		else if (sel == 2'b01)
		begin
			result <= data1;
		end
		else if (sel == 2'b10)
		begin
			result <= data2;
		end
		else if (sel == 2'b11)
		begin
			result <= data3;
		end
	end
endmodule

