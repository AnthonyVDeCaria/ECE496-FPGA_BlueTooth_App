/*
Anthony De Caria - January 12, 2016

This module creates a 1 bit Register with a separate enable signal.
This module uses asynchronous D Flip Flops.
*/

module register_1bit_enable_async(clk, resetn, enable, select, d, q);
	
	//Define the inputs and outputs
	input	clk;
	input	resetn;
	input	enable;
	input	select;
	input	d;
	output	q;
	
	wire	mux_out;
	
	mux_2_1bit m_0( .data1(d), .data0(q), .sel(select), .result(mux_out) );
	
	D_FF_Enable_Async d_0( .clk(clk), .resetn(resetn), .enable(enable), .d(mux_out), .q(q) );

endmodule
