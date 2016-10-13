/*
Anthony De Caria - October 2, 2016

This module creates a 16 bit edge detector.
*/

module edge_detector_16bit(clk, d, q, e);
	
	//Define the inputs and outputs
	input	clk;
	input	e;
	input	[15:0] d;
	output	[15:0] q;
	
	wire	[15:0]first_out;
	
	D_FF_Enable f_0( .clk(clk), .d(d[0]), .enable(e), .q(first_out[0]) );
	D_FF_Enable f_1( .clk(clk), .d(d[1]), .enable(e), .q(first_out[1]) );
	D_FF_Enable f_2( .clk(clk), .d(d[2]), .enable(e), .q(first_out[2]) );
	D_FF_Enable f_3( .clk(clk), .d(d[3]), .enable(e), .q(first_out[3]) );
	D_FF_Enable f_4( .clk(clk), .d(d[4]), .enable(e), .q(first_out[4]) );
	D_FF_Enable f_5( .clk(clk), .d(d[5]), .enable(e), .q(first_out[5]) );
	D_FF_Enable f_6( .clk(clk), .d(d[6]), .enable(e), .q(first_out[6]) );
	D_FF_Enable f_7( .clk(clk), .d(d[7]), .enable(e), .q(first_out[7]) );
	D_FF_Enable f_8( .clk(clk), .d(d[8]), .enable(e), .q(first_out[8]) );
	D_FF_Enable f_9( .clk(clk), .d(d[9]), .enable(e), .q(first_out[9]) );
	
	D_FF_Enable f_10( .clk(clk), .d(d[10]), .enable(e), .q(first_out[10]) );
	D_FF_Enable f_11( .clk(clk), .d(d[11]), .enable(e), .q(first_out[11]) );
	D_FF_Enable f_12( .clk(clk), .d(d[12]), .enable(e), .q(first_out[12]) );
	D_FF_Enable f_13( .clk(clk), .d(d[13]), .enable(e), .q(first_out[13]) );
	D_FF_Enable f_14( .clk(clk), .d(d[14]), .enable(e), .q(first_out[14]) );
	D_FF_Enable f_15( .clk(clk), .d(d[15]), .enable(e), .q(first_out[15]) );
	
	D_FF_Enable s_0( .clk(clk), .d(first_out[0]), .enable(e), .q(q[0]) );
	D_FF_Enable s_1( .clk(clk), .d(first_out[1]), .enable(e), .q(q[1]) );
	D_FF_Enable s_2( .clk(clk), .d(first_out[2]), .enable(e), .q(q[2]) );
	D_FF_Enable s_3( .clk(clk), .d(first_out[3]), .enable(e), .q(q[3]) );
	D_FF_Enable s_4( .clk(clk), .d(first_out[4]), .enable(e), .q(q[4]) );
	D_FF_Enable s_5( .clk(clk), .d(first_out[5]), .enable(e), .q(q[5]) );
	D_FF_Enable s_6( .clk(clk), .d(first_out[6]), .enable(e), .q(q[6]) );
	D_FF_Enable s_7( .clk(clk), .d(first_out[7]), .enable(e), .q(q[7]) );
	D_FF_Enable s_8( .clk(clk), .d(first_out[8]), .enable(e), .q(q[8]) );
	D_FF_Enable s_9( .clk(clk), .d(first_out[9]), .enable(e), .q(q[9]) );
	
	D_FF_Enable s_10( .clk(clk), .d(first_out[10]), .enable(e), .q(q[10]) );
	D_FF_Enable s_11( .clk(clk), .d(first_out[11]), .enable(e), .q(q[11]) );
	D_FF_Enable s_12( .clk(clk), .d(first_out[12]), .enable(e), .q(q[12]) );
	D_FF_Enable s_13( .clk(clk), .d(first_out[13]), .enable(e), .q(q[13]) );
	D_FF_Enable s_14( .clk(clk), .d(first_out[14]), .enable(e), .q(q[14]) );
	D_FF_Enable s_15( .clk(clk), .d(first_out[15]), .enable(e), .q(q[15]) );

endmodule
