/*
Anthony De Caria - February 10, 2017

This module creates a 110-bit eight input Mux.
*/

module mux_8_110bit(data0, data1, data2, data3, data4, data5, data6, data7, sel, result);
	input [109:0] data0, data1, data2, data3, data4, data5, data6, data7;
	input [2:0] sel;
	output reg [109:0] result;
	
	always@(*)
	begin
		if (sel == 3'b000)
		begin
			result = data0;
		end
		else if (sel == 3'b001)
		begin
			result = data1;
		end
		else if (sel == 3'b010)
		begin
			result = data2;
		end
		else if (sel == 3'b011)
		begin
			result = data3;
		end
		else if (sel == 3'b100)
		begin
			result = data4;
		end
		else if (sel == 3'b101)
		begin
			result = data5;
		end
		else if (sel == 3'b110)
		begin
			result = data6;
		end
		else if (sel == 3'b111)
		begin
			result = data7;
		end
	end
endmodule