module sensor_analog (d_out);
	output [3:0]d_out;
	
	wire [3:0] set_0, set_1, set_2, set_3;
	
	wire [1:0] mux_sel;
	
	assign set_0[3:0] = 4'hA;
	assign set_1[3:0] = 4'h0;
	assign set_2[3:0] = 4'hF;
	assign set_3[3:0] = 4'hC;
	
	mux_4_4bit lol(.data0(set_0), .data1(set_1), .data2(set_2), .data3(set_3), .sel(2'b10), .result(d_out));
endmodule

module test(ybusn, ybusp)
	output [1:0] ybusn;
	output [1:0] ybusp;
	
	wire [3:0]sensor_data;
	wire bt_enable, bt_state, bt_txd, bt_rxd;
	
	assign bt_rxd = ybusn[0];
	assign bt_txd = ybusn[1];
	assign bt_rxd = ybusp[0];
	assign bt_txd = ybusp[1];
	
	sensor_analog test(.d_out(sensor_data));
	
	
	
endmodule
