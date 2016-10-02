/*
Anthony De Caria - October 2, 2016

This module creates a 16 bit edge detector.
*/

module edge_detector_16bit(clk, d, q);
	
	//Define the inputs and outputs
	input	clk;
	input	[15:0] d;
	output	[15:0] q;
	
	wire	[15:0]first_out;
	
	D_FF f_0( .clk(clk), .d(d[0]), .q(first_out[0]) );
	D_FF f_1( .clk(clk), .d(d[1]), .q(first_out[1]) );
	D_FF f_2( .clk(clk), .d(d[2]), .q(first_out[2]) );
	D_FF f_3( .clk(clk), .d(d[3]), .q(first_out[3]) );
	D_FF f_4( .clk(clk), .d(d[4]), .q(first_out[4]) );
	D_FF f_5( .clk(clk), .d(d[5]), .q(first_out[5]) );
	D_FF f_6( .clk(clk), .d(d[6]), .q(first_out[6]) );
	D_FF f_7( .clk(clk), .d(d[7]), .q(first_out[7]) );
	D_FF f_8( .clk(clk), .d(d[8]), .q(first_out[8]) );
	D_FF f_9( .clk(clk), .d(d[9]), .q(first_out[9]) );
	
	D_FF f_10( .clk(clk), .d(d[10]), .q(first_out[10]) );
	D_FF f_11( .clk(clk), .d(d[11]), .q(first_out[11]) );
	D_FF f_12( .clk(clk), .d(d[12]), .q(first_out[12]) );
	D_FF f_13( .clk(clk), .d(d[13]), .q(first_out[13]) );
	D_FF f_14( .clk(clk), .d(d[14]), .q(first_out[14]) );
	D_FF f_15( .clk(clk), .d(d[15]), .q(first_out[15]) );
	
	D_FF s_0( .clk(clk), .d(first_out[0]), .q(q[0]) );
	D_FF s_1( .clk(clk), .d(first_out[1]), .q(q[1]) );
	D_FF s_2( .clk(clk), .d(first_out[2]), .q(q[2]) );
	D_FF s_3( .clk(clk), .d(first_out[3]), .q(q[3]) );
	D_FF s_4( .clk(clk), .d(first_out[4]), .q(q[4]) );
	D_FF s_5( .clk(clk), .d(first_out[5]), .q(q[5]) );
	D_FF s_6( .clk(clk), .d(first_out[6]), .q(q[6]) );
	D_FF s_7( .clk(clk), .d(first_out[7]), .q(q[7]) );
	D_FF s_8( .clk(clk), .d(first_out[8]), .q(q[8]) );
	D_FF s_9( .clk(clk), .d(first_out[9]), .q(q[9]) );
	
	D_FF s_10( .clk(clk), .d(first_out[10]), .q(q[10]) );
	D_FF s_11( .clk(clk), .d(first_out[11]), .q(q[11]) );
	D_FF s_12( .clk(clk), .d(first_out[12]), .q(q[12]) );
	D_FF s_13( .clk(clk), .d(first_out[13]), .q(q[13]) );
	D_FF s_14( .clk(clk), .d(first_out[14]), .q(q[14]) );
	D_FF s_15( .clk(clk), .d(first_out[15]), .q(q[15]) );

endmodule
