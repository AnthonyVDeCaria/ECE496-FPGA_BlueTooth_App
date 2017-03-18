`timescale 1us / 1ps

module testingIon;

	// Inputs
	reg clock;
	reg reset;
	reg ack;
	reg request;

	// Outputs
	wire sensor_stream_ready;
	wire [109:0] data_out;
	wire [5:0] i0;
	wire l_r_i, r_r_i;

	// Instantiate the Unit Under Test (UUT)
	ion uut(
		.l_r_i(l_r_i), 
		.r_r_i(r_r_i),
		.clock(clock),
		.reset(reset),
		.data_request(request), 
		.data_ack(ack), 
		.data_valid(sensor_stream_ready),
		.i(i0)
	);
	
	DS0 stream0(.index(i0), .data(data_out));
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		request = 0;
		ack = 0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 reset = 1'b0;
		
		#100 request = 1'b1;
		
		#200 ack = 1'b1;
	end
	
endmodule

