/*
Anthony De Caria - December 28, 2016

This module creates a 8 bit Cyclical Right Shift Register using asynchronous D Flip Flops.
*/

module cyclical_right_shift_register_8_async(clk, resetn, enable, select, d, q);
	
	//Define the inputs and outputs
	input	clk;
	input	resetn;
	input	enable;
	input	select;
	input	[7:0] d;
	output	[7:0] q;
	
	wire	[7:0]mux_out;
	
	mux_2_1bit mux_0(.data1(d[0]), .data0(q[1]), .sel(select), .result(mux_out[0]) );
	mux_2_1bit mux_1(.data1(d[1]), .data0(q[2]), .sel(select), .result(mux_out[1]) );
	mux_2_1bit mux_2(.data1(d[2]), .data0(q[3]), .sel(select), .result(mux_out[2]) );
	mux_2_1bit mux_3(.data1(d[3]), .data0(q[4]), .sel(select), .result(mux_out[3]) );
	mux_2_1bit mux_4(.data1(d[4]), .data0(q[5]), .sel(select), .result(mux_out[4]) );
	mux_2_1bit mux_5(.data1(d[5]), .data0(q[6]), .sel(select), .result(mux_out[5]) );
	mux_2_1bit mux_6(.data1(d[6]), .data0(q[7]), .sel(select), .result(mux_out[6]) );
	mux_2_1bit mux_7(.data1(d[7]), .data0(q[0]), .sel(select), .result(mux_out[7]) );
	
	D_FF_Enable_Async d_0(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[0]), .q(q[0]) );
	D_FF_Enable_Async d_1(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[1]), .q(q[1]) );
	D_FF_Enable_Async d_2(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[2]), .q(q[2]) );
	D_FF_Enable_Async d_3(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[3]), .q(q[3]) );
	D_FF_Enable_Async d_4(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[4]), .q(q[4]) );
	D_FF_Enable_Async d_5(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[5]), .q(q[5]) );
	D_FF_Enable_Async d_6(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[6]), .q(q[6]) );
	D_FF_Enable_Async d_7(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[7]), .q(q[7]) );
	
endmodule
