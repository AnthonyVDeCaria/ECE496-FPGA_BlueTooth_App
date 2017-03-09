/*
Feb 23, 2017 Ming

This module creates a 8bit 16 input Mux.
*/

module mux_16_8bit(data0, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, data13, data14, data15, sel, result);
	input [7:0] data0, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, data13, data14, data15;
	input [3:0] sel;
	output reg [7:0] result;

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
    else if (sel == 4'b1001)
    begin
      result = data9;
    end
    else if (sel == 4'b1010)
    begin
      result = data10;
    end
    else if (sel == 4'b1011)
    begin
      result = data11;
    end
    else if (sel == 4'b1100)
    begin
      result = data12;
    end
    else if (sel == 4'b1101)
    begin
      result = data13;
    end
    else if (sel == 4'b1110)
    begin
      result = data14;
    end
    else if (sel == 4'b1111)
    begin
      result = data15;
    end
	end
endmodule
