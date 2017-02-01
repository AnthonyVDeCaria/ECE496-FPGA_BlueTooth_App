/*
	Anthony De Caria - January 31, 2017

	This module creates a 8-bit three input Mux.
*/

module mux_3_8bit(data0, data1, data2, sel, result);
	input [7:0] data0, data1, data2;
	input [1:0] sel;
	output reg [7:0] result;
	
	always@(*)
	begin
		if (sel == 2'b00)
		begin
			result = data0;
		end
		else if (sel == 2'b01)
		begin
			result = data1;
		end
		else if (sel == 2'b10)
		begin
			result = data2;
		end
		else
		begin
			result = 8'hzz;
		end
	end
endmodule
