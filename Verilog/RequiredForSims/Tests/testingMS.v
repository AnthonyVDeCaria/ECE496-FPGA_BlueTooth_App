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
	reg [7:0] selected_streams;
	reg sending_flag;
	reg at_complete;

	// Outputs
	wire [3:0] mux_select;
	
	wire [9:0] timer, n_timer;
	wire [2:0] curr, next;
	wire [2:0] i, n_i;
	wire [7:0] shift;
	
	parameter bt_state = 1'b1;
	parameter timer_cap = 10'd12;

	// Instantiate the Unit Under Test (UUT)
	master_switch_ece496 uut(
		.clock(clock), 
		.resetn(resetn), 
		.want_at(want_at), 
		.bt_state(bt_state), 
		.sending_flag(sending_flag), 
		.at_complete(at_complete), 
		.timer_cap(timer_cap), 
		.selected_streams(selected_streams), 
		.mux_select(mux_select),
		
		.curr(curr), 
		.next(next), 
		.timer(timer), 
		.n_timer(n_timer), 
		.i(i), 
		.n_i(n_i), 
		.shift(shift)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 1'b0;
		selected_streams = 8'h00;
		sending_flag = 1'b0;
		at_complete = 1'b0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 resetn = 1'b1;
		
		#100 selected_streams = 8'haa;
		#100 sending_flag = 1'b1;
		
		#200 sending_flag = 1'b0;
		#200 selected_streams = 8'h01;
		#201 sending_flag = 1'b1;
		
		#300 sending_flag = 1'b0;
		#300 selected_streams = 8'h11;
		#301 sending_flag = 1'b1;
		
		#400 sending_flag = 1'b0;
		#400 selected_streams = 8'hC3;
		#400 sending_flag = 1'b1;
		
		#500 sending_flag = 1'b0;
		#500 selected_streams = 8'h03;
		#500 sending_flag = 1'b1;
		
		#600 sending_flag = 1'b0;
		#600 selected_streams = 8'h06;
		#600 sending_flag = 1'b1;
		
		#700 sending_flag = 1'b0;
		#700 selected_streams = 8'h05;
		#700 sending_flag = 1'b1;
	end
	
endmodule

