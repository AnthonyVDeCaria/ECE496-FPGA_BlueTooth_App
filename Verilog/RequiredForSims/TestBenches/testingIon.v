`timescale 1us / 1ps

module testingIon;

	// Inputs
	reg clock;
	reg reset;

	// Outputs
	wire sensor_stream_ready;
	wire [109:0] data_out;
	wire [5:0] i0;

	// Instantiate the Unit Under Test (UUT)
	ion uut(
		.clock(clock),
		.reset(reset),
		.data_request(request),
		.data_valid(sensor_stream_ready),
		.i(i0)
	);
	
	DS0 stream0(.index(i0), .data(data_out));
	
	wire request;
	wire [31:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done, timer_reset;
	wire r_r_request, e_r_request;
	parameter timer_cap = 32'd500000, timer_reset_cap = 32'd500001;
	assign l_r_timer = 1'b1;
	assign r_r_timer = ~(reset | timer_reset);
	adder_subtractor_32bit a_timer(.a(timer), .b(32'd1), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_32bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;
	assign timer_reset = (timer == timer_reset_cap) ? 1'b1 : 1'b0;
	assign r_r_request = ~reset;
	assign e_r_request = timer_done;
	T_FF_Enable_Async r_request(.clk(clock), .resetn(r_r_request), .enable(e_r_request), .q(request));
	
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

