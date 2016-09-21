module test_sensor_analog (select, d_out);
	input	[1:0] select;
	output	[3:0] d_out;
	
	wire [3:0] set_0, set_1, set_2, set_3;
	
	assign set_0[3:0] = 8'hAA;
	assign set_1[3:0] = 8'h00;
	assign set_2[3:0] = 8'hFF;
	assign set_3[3:0] = 8'hCC;
	
	mux_4_8bit mux_data(.data0(set_0), .data1(set_1), .data2(set_2), .data3(set_3), .sel(select), .result(d_out) );
endmodule
