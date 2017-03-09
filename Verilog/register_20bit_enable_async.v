/*
Anthony De Caria - February 21, 2017

This module creates a 20 bit Register with a separate enable signal.
This module uses asynchronous D Flip Flops.
*/

module register_20bit_enable_async(clk, resetn, enable, select, d, q);
	
	//Define the inputs and outputs
	input	clk;
	input	resetn;
	input	enable;
	input	select;
	input	[19:0] d;
	output	[19:0] q;
	
	wire	[19:0]mux_out;
	
	mux_2_1bit m_0( .data1(d[0]), .data0(q[0]), .sel(select), .result(mux_out[0]) );
	mux_2_1bit m_1( .data1(d[1]), .data0(q[1]), .sel(select), .result(mux_out[1]) );
	mux_2_1bit m_2( .data1(d[2]), .data0(q[2]), .sel(select), .result(mux_out[2]) );
	mux_2_1bit m_3( .data1(d[3]), .data0(q[3]), .sel(select), .result(mux_out[3]) );
	mux_2_1bit m_4( .data1(d[4]), .data0(q[4]), .sel(select), .result(mux_out[4]) );
	mux_2_1bit m_5( .data1(d[5]), .data0(q[5]), .sel(select), .result(mux_out[5]) );
	mux_2_1bit m_6( .data1(d[6]), .data0(q[6]), .sel(select), .result(mux_out[6]) );
	mux_2_1bit m_7( .data1(d[7]), .data0(q[7]), .sel(select), .result(mux_out[7]) );
	mux_2_1bit m_8( .data1(d[8]), .data0(q[8]), .sel(select), .result(mux_out[8]) );
	mux_2_1bit m_9( .data1(d[9]), .data0(q[9]), .sel(select), .result(mux_out[9]) );
	
	mux_2_1bit m_10( .data1(d[10]), .data0(q[10]), .sel(select), .result(mux_out[10]) );
	mux_2_1bit m_11( .data1(d[11]), .data0(q[11]), .sel(select), .result(mux_out[11]) );
	mux_2_1bit m_12( .data1(d[12]), .data0(q[12]), .sel(select), .result(mux_out[12]) );
	mux_2_1bit m_13( .data1(d[13]), .data0(q[13]), .sel(select), .result(mux_out[13]) );
	mux_2_1bit m_14( .data1(d[14]), .data0(q[14]), .sel(select), .result(mux_out[14]) );
	mux_2_1bit m_15( .data1(d[15]), .data0(q[15]), .sel(select), .result(mux_out[15]) );
	mux_2_1bit m_16( .data1(d[16]), .data0(q[16]), .sel(select), .result(mux_out[16]) );
	mux_2_1bit m_17( .data1(d[17]), .data0(q[17]), .sel(select), .result(mux_out[17]) );
	mux_2_1bit m_18( .data1(d[18]), .data0(q[18]), .sel(select), .result(mux_out[18]) );
	mux_2_1bit m_19( .data1(d[19]), .data0(q[19]), .sel(select), .result(mux_out[19]) );
	
	D_FF_Enable_Async d_0( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[0]), .q(q[0]) );
	D_FF_Enable_Async d_1( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[1]), .q(q[1]) );
	D_FF_Enable_Async d_2( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[2]), .q(q[2]) );
	D_FF_Enable_Async d_3( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[3]), .q(q[3]) );
	D_FF_Enable_Async d_4( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[4]), .q(q[4]) );
	D_FF_Enable_Async d_5( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[5]), .q(q[5]) );
	D_FF_Enable_Async d_6( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[6]), .q(q[6]) );
	D_FF_Enable_Async d_7( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[7]), .q(q[7]) );
	D_FF_Enable_Async d_8( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[8]), .q(q[8]) );
	D_FF_Enable_Async d_9( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[9]), .q(q[9]) );
	
	D_FF_Enable_Async d_10( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[10]), .q(q[10]) );
	D_FF_Enable_Async d_11( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[11]), .q(q[11]) );
	D_FF_Enable_Async d_12( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[12]), .q(q[12]) );
	D_FF_Enable_Async d_13( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[13]), .q(q[13]) );
	D_FF_Enable_Async d_14( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[14]), .q(q[14]) );
	D_FF_Enable_Async d_15( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[15]), .q(q[15]) );
	D_FF_Enable_Async d_16( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[16]), .q(q[16]) );
	D_FF_Enable_Async d_17( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[17]), .q(q[17]) );
	D_FF_Enable_Async d_18( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[18]), .q(q[18]) );
	D_FF_Enable_Async d_19( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[19]), .q(q[19]) );

endmodule
