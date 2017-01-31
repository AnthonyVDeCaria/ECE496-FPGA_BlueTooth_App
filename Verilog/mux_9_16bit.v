/*
Anthony De Caria - December 1, 2016

This module creates a 16-bit nine input Mux.
*/

module mux_9_16bit(data0, data1, data2, data3, data4, data5, data6, data7, data8, sel, result);
	input [15:0] data0, data1, data2, data3, data4, data5, data6, data7, data8;
	input [3:0] sel;
	output reg [15:0] result;
	
	always@(*)
	begin
		if (sel == 4'b0000)
		begin
			result = data0;
		end
		else if (sel == 4'b0001)
		begin
			result = data1;
		end
		else if (sel == 4'b0010)
		begin
			result = data2;
		end
		else if (sel == 4'b0011)
		begin
			result = data3;
		end
		else if (sel == 4'b0100)
		begin
			result = data4;
		end
		else if (sel == 4'b0101)
		begin
			result = data5;
		end
		else if (sel == 4'b0110)
		begin
			result = data6;
		end
		else if (sel == 4'b0111)
		begin
			result = data7;
		end
		else if (sel == 4'b1000)
		begin
			result = data8;
		end
		else
		begin
			result = 16'hzzzz;
		end
	end
endmodule

