`timescale 1us / 1ps

module testingIon;

	// Inputs
	reg clock;
	reg resetn;

	// Outputs
	wire sensor_stream_ready;
	wire [109:0] data_out, data_in;//, data_out1, data_out2, data_out3, data_out4, data_out5, data_out6, data_out7;
	wire [5:0] i0;//, i1, i2, i3;
//	wire [5:0] i4, i5, i6, i7;
	wire [1:0] ion_curr, ion_next;
	wire timer_done;
	wire [19:0] timer0;//, timer1, timer2, timer3, timer4, timer5, timer6, timer7;

	// Instantiate the Unit Under Test (UUT)
	ion uut(
		.clock(clock),
		.resetn(resetn),
		.ready(sensor_stream_ready),
		.data_out(data_out),
//		.data_out1(data_out1),
//		.data_out2(data_out2),
//		.data_out3(data_out3),
//		.data_out4(data_out4),
//		.data_out5(data_out5),
//		.data_out6(data_out6),
//		.data_out7(data_out7),
		.i0(i0),
		.data_in(data_in),
		.timer_cap0(20'h77800),
//		.i1(i1),
//		.i2(i2),
//		.i3(i3),
//		.i4(i4),
//		.i5(i5),
//		.i6(i6),
//		.i7(i7),
		.ion_curr(ion_curr),
		.ion_next(ion_next),
		.timer_done(timer_done),
		.timer0(timer0)//, 
//		.timer1(timer1), 
//		.timer2(timer2), 
//		.timer3(timer3), 
//		.timer4(timer4), 
//		.timer5(timer5), 
//		.timer6(timer6), 
//		.timer7(timer7)
	);
	
	DS0 stream0(.index(i0), .data(data_in));
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 resetn = 1'b1;
	end
	
endmodule

