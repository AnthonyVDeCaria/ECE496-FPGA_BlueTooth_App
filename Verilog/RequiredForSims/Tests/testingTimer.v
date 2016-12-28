`timescale 1us / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:30:42 09/28/2016
// Design Name:   FPGA_Bluetooth_connection
// Module Name:   C:/Users/Anthony/Desktop/ECE496/t1_sim/t1.v
// Project Name:  t1_sim
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FPGA_Bluetooth_connection
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testingTimer;

	// Inputs
	reg clock;
	reg l_r_timer;
	reg r_r_timer;
	
	parameter timer_cap = 9'd12;

	// Outputs
	wire timer_done;

	// Instantiate the Unit Under Test (UUT)
	timer_10bit_async uut(
		.clock(clock),
		.l_r_timer(l_r_timer),
		.r_r_timer(r_r_timer),
		.timer_cap(timer_cap),
		.timer_done(timer_done)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		r_r_timer = 1'b0;
		l_r_timer = 1'b0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 r_r_timer = 1'b1;
	end
	
endmodule
