/*
	Anthony De Caria - March 26, 2017
	
	This module handles requests made to the ion sensor
	by creating 8 isr_stream modules
	and seeding them with correct offset and period values.
*/
module ion_sensor_requester(clock, resetn, stream_active, i_s_request);
	/*
		I/Os
	*/
	input clock, resetn;
	input [7:0] stream_active;
	output [7:0] i_s_request;

	/*
		Parameters
	*/
	parameter period0 = 16'd21600, period1 = 16'd21600, period2 = 16'd21600, period3 = 16'd21600;
	parameter period4 = 16'd21600, period5 = 16'd21600, period6 = 16'd21600, period7 = 16'd21600;
	
	parameter offset0 = 16'd0, offset1 = 16'd0, offset2 = 16'd0, offset3 = 16'd0;
	parameter offset4 = 16'd0, offset5 = 16'd0, offset6 = 16'd0, offset7 = 16'd0;
	
	/*
		ISR_Streams
	*/
	isr_stream isrs0(.clock(clock), .resetn(resetn), .period(period0), .offset(offset0), .stream_active(stream_active[0]), .i_s_request(i_s_request[0]));
	isr_stream isrs1(.clock(clock), .resetn(resetn), .period(period1), .offset(offset1), .stream_active(stream_active[1]), .i_s_request(i_s_request[1]));
	isr_stream isrs2(.clock(clock), .resetn(resetn), .period(period2), .offset(offset2), .stream_active(stream_active[2]), .i_s_request(i_s_request[2]));
	isr_stream isrs3(.clock(clock), .resetn(resetn), .period(period3), .offset(offset3), .stream_active(stream_active[3]), .i_s_request(i_s_request[3]));
	isr_stream isrs4(.clock(clock), .resetn(resetn), .period(period4), .offset(offset4), .stream_active(stream_active[4]), .i_s_request(i_s_request[4]));
	isr_stream isrs5(.clock(clock), .resetn(resetn), .period(period5), .offset(offset5), .stream_active(stream_active[5]), .i_s_request(i_s_request[5]));
	isr_stream isrs6(.clock(clock), .resetn(resetn), .period(period6), .offset(offset6), .stream_active(stream_active[6]), .i_s_request(i_s_request[6]));
	isr_stream isrs7(.clock(clock), .resetn(resetn), .period(period7), .offset(offset7), .stream_active(stream_active[7]), .i_s_request(i_s_request[7]));
endmodule
