/*
Anthony De Caria - December 28, 2016

This module creates a 3 bit Register with a separate enable signal.
This module uses asynchronous D Flip Flops.
*/

module register_3bit_enable_async(clk, resetn, enable, select, d, q);
	
	//Define the inputs and outputs
	input	clk;
	input	resetn;
	input	enable;
	input	select;
	input	[2:0] d;
	output	[2:0] q;
	
	wire	[2:0]mux_out;
	
	mux_2_1bit m_0( .data1(d[0]), .data0(q[0]), .sel(select), .result(mux_out[0]) );
	mux_2_1bit m_1( .data1(d[1]), .data0(q[1]), .sel(select), .result(mux_out[1]) );
	mux_2_1bit m_2( .data1(d[2]), .data0(q[2]), .sel(select), .result(mux_out[2]) );
	
	D_FF_Enable_Async d_0( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[0]), .q(q[0]) );
	D_FF_Enable_Async d_1( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[1]), .q(q[1]) );
	D_FF_Enable_Async d_2( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out[2]), .q(q[2]) );

endmodule
