`timescale 1us / 1ps

module testingIon;

	// Inputs
	reg clock;
	reg resetn;

	// Outputs
	wire [7:0] sensor_stream_ready;
	wire [109:0] data_out;

	// Instantiate the Unit Under Test (UUT)
	ion uut(
		.clock(clock),
		.resetn(resetn),
		.ready(sensor_stream_ready),
		.data_out(data_out)
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

