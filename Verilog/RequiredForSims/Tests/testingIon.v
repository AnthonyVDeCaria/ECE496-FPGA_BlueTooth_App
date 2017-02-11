`timescale 1us / 1ps

module testingIon;

	// Inputs
	reg clock;
	reg resetn;

	// Outputs
	wire [7:0] sensor_stream_ready;
	//wire [5:0] index;
	wire [109:0] data_out;
	wire [5:0] i0, i1, i2, i3;
	wire [5:0] i4, i5, i6, i7;

	// Instantiate the Unit Under Test (UUT)
	ion uut(
		.clock(clock),
		.resetn(resetn),
		.ready(sensor_stream_ready),
		.data_out(data_out),
		.i0(i0),
		.i1(i1),
		.i2(i2),
		.i3(i3),
		.i4(i4),
		.i5(i5),
		.i6(i6),
		.i7(i7)
	);
	
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

