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

module testingMS;

	// Inputs
	reg clock;
	reg resetn;
	reg [7:0] open_streams;
	reg sending_flag;

	// Outputs
	wire [3:0] n_s;
	
//	wire invalid_os;
	wire [9:0] timer, n_timer;
	wire [7:0] counter_check;
	wire [2:0] counter;
	wire r_r_timer; 
	wire should_we_reset;
	wire timer_done;
	
	parameter bt_state = 1'b1;
	parameter timer_cap = 10'd12;

	// Instantiate the Unit Under Test (UUT)
	master_switchece496 uut(
		.clock(clock),
		.resetn(resetn),
		.bt_state(bt_state), 
		.sending_flag(sending_flag),
		.timer_cap(timer_cap), 
		.open_streams(open_streams), 
		.next_sel(n_s),
		
//		.invalid_os(invalid_os),
		.counter(counter),
		.counter_check(counter_check),
		.timer(timer),
		.n_timer(n_timer),
		.r_r_timer(r_r_timer),
		.should_we_reset(should_we_reset),
		.timer_done(timer_done)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 1'b0;
		open_streams = 8'h00;
		sending_flag = 1'b0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 open_streams = 8'haa;
		#100 sending_flag = 1'b1;
		#100 resetn = 1'b1;
		#200 open_streams = 8'h01;
		#300 open_streams = 8'h11;
		#400 open_streams = 8'hC3;
		#500 open_streams = 8'h03;
		#600 open_streams = 8'h06;
		#700 open_streams = 8'h05;
	end
	
endmodule

