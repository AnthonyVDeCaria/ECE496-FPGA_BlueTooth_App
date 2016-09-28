/*
Anthony De Caria - September 27, 2016

This module creates a 16 bit Shift Register with a separate enable signal.
This module uses asynchronous D Flip Flops.
It also can allow data to be put into the flip flops before shifting.
*/

module Shift_Register_16_Enable_Async_OneLoad(clk, resetn, enable, select, d, q);
	
	//Define the inputs and outputs
	input	clk;
	input	resetn;
	input	enable;
	input	select;
	input	[15:0] d;
	output	[15:0] q;
	
	wire	[15:1]mux_out;
	
	mux_2_1bit mux_1(.data1(d[1]), .data0(q[0]), .sel(select), .result(mux_out[1]) );
	mux_2_1bit mux_2(.data1(d[2]), .data0(q[1]), .sel(select), .result(mux_out[2]) );
	mux_2_1bit mux_3(.data1(d[3]), .data0(q[2]), .sel(select), .result(mux_out[3]) );
	mux_2_1bit mux_4(.data1(d[4]), .data0(q[3]), .sel(select), .result(mux_out[4]) );
	mux_2_1bit mux_5(.data1(d[5]), .data0(q[4]), .sel(select), .result(mux_out[5]) );
	mux_2_1bit mux_6(.data1(d[6]), .data0(q[5]), .sel(select), .result(mux_out[6]) );
	mux_2_1bit mux_7(.data1(d[7]), .data0(q[6]), .sel(select), .result(mux_out[7]) );
	mux_2_1bit mux_8(.data1(d[8]), .data0(q[7]), .sel(select), .result(mux_out[8]) );
	mux_2_1bit mux_9(.data1(d[9]), .data0(q[8]), .sel(select), .result(mux_out[9]) );
	
	mux_2_1bit mux_10(.data1(d[10]), .data0(q[9]), .sel(select), .result(mux_out[10]) );
	
	mux_2_1bit mux_11(.data1(d[11]), .data0(q[10]), .sel(select), .result(mux_out[11]) );
	mux_2_1bit mux_12(.data1(d[12]), .data0(q[11]), .sel(select), .result(mux_out[12]) );
	mux_2_1bit mux_13(.data1(d[13]), .data0(q[12]), .sel(select), .result(mux_out[13]) );
	mux_2_1bit mux_14(.data1(d[14]), .data0(q[13]), .sel(select), .result(mux_out[14]) );
	mux_2_1bit mux_15(.data1(d[15]), .data0(q[14]), .sel(select), .result(mux_out[15]) );
	
	
	
	D_FF_Enable_Async d_0(.clk(clk), .resetn(resetn), .enable(enable), .d(d[0]), .q(q[0]) );
	
	D_FF_Enable_Async d_1(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[1]), .q(q[1]) );
	D_FF_Enable_Async d_2(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[2]), .q(q[2]) );
	D_FF_Enable_Async d_3(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[3]), .q(q[3]) );
	D_FF_Enable_Async d_4(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[4]), .q(q[4]) );
	D_FF_Enable_Async d_5(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[5]), .q(q[5]) );
	D_FF_Enable_Async d_6(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[6]), .q(q[6]) );
	D_FF_Enable_Async d_7(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[7]), .q(q[7]) );
	D_FF_Enable_Async d_8(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[8]), .q(q[8]) );
	D_FF_Enable_Async d_9(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[9]), .q(q[9]) );
	
	D_FF_Enable_Async d_10(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[10]), .q(q[10]) );
	D_FF_Enable_Async d_11(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[11]), .q(q[11]) );
	D_FF_Enable_Async d_12(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[12]), .q(q[12]) );
	D_FF_Enable_Async d_13(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[13]), .q(q[13]) );
	D_FF_Enable_Async d_14(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[14]), .q(q[14]) );
	D_FF_Enable_Async d_15(.clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[15]), .q(q[15]) );
	
endmodule
