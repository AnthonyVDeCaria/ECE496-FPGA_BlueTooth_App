`timescale 1us / 1ps

module testingTimer;

	// Inputs
	reg clock;
	reg l_timer;
	reg resetn_timer;
	
	parameter timer_cap = 10'd12;

	// Outputs
	wire timer_done;

	// Instantiate the Unit Under Test (UUT)
	timer_10bit uut(
		.clock(clock),
		.resetn_timer(resetn_timer), 
		.timer_active(l_timer),
		.timer_final_value(timer_cap),
		.timer_done(timer_done)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn_timer = 1'b0;
		l_timer = 1'b0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 resetn_timer = 1'b1;
		#100 l_timer = 1'b1;
		
		#200 l_timer = 1'b1;
		
		#300 resetn_timer =1'b0;
	end
	
endmodule

