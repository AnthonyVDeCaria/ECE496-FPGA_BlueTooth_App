module test_sensor_analog (select, d_out);
	input	[1:0] select;
	output	[15:0] d_out;
	
	wire [15:0] set_0, set_1, set_2, set_3;
	
	assign set_0[15:0] = 16'hAAAA;
	assign set_1[15:0] = 16'h0000;
	assign set_2[15:0] = 16'hCCCC;
	assign set_3[15:0] = 16'hFFFF;
	
	mux_4_16bit mux_data(.data0(set_0), .data1(set_1), .data2(set_2), .data3(set_3), .sel(select), .result(d_out) );
endmodule
