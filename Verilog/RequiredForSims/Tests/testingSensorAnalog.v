`timescale 1us / 1ps

module testingSensorAnalog;

	// Inputs
	reg clock;
	reg reset;

	// wires
	wire [31:0] sensor_stream0;
	wire [15:0] sensor_stream1, sensor_stream2, sensor_stream3, sensor_stream4, sensor_stream5, sensor_stream6, sensor_stream7;
	wire [7:0] sensor_stream_ready;
	wire [15:0] sensor_timer, n_sensor_timer;
	wire sensor_timer_done;

	// Instantiate the Unit Under Test (UUT)
	sensor_analog uut(
		.clock(clock), .reset(reset),
		.sensor_stream0(sensor_stream0), .sensor_stream1(sensor_stream1), .sensor_stream2(sensor_stream2), .sensor_stream3(sensor_stream3), 
		.sensor_stream4(sensor_stream4), .sensor_stream5(sensor_stream5), .sensor_stream6(sensor_stream6), .sensor_stream7(sensor_stream7), 
		.sensor_stream_ready(sensor_stream_ready)
		
//		.sensor_timer(sensor_timer),
//		.n_sensor_timer(n_sensor_timer),
//		.sensor_timer_done(sensor_timer_done)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 reset = 1'b0;
		
	end
	
endmodule

