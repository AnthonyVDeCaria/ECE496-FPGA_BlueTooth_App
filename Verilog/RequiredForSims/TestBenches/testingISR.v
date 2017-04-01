`timescale 1us / 1ps

module testingISR;

	// Inputs
	reg clock;
	reg resetn;
	reg [7:0] stream_active;

	// Outputs
	wire [7:0] i_s_request;

	// Instantiate the Unit Under Test (UUT)
	ion_sensor_requester uut(.clock(clock), .resetn(resetn), .stream_active(stream_active), .i_s_request(i_s_request));
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 0;
		stream_active = 0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 resetn = 1'b1;
		#0 stream_active = 8'hFF;
		
		#1000 stream_active = 8'h00;
		
		#2000 stream_active = 8'hAA;
	end
	
endmodule

