`timescale 1ns / 1ps

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

module t1;

	// Inputs
	reg clock;
	reg bt_state;
	reg fpga_rxd;
	reg [15:0] ep01wireIn;
	reg [15:0] ep40trigIn;

	// Outputs
	wire bt_enable;
	wire fpga_txd;
	wire [15:0] ep20wireOut;
	wire [15:0] ep21wireOut;
	wire [15:0] ep22wireOut;
	wire [15:0] ep23wireOut;

	// Instantiate the Unit Under Test (UUT)
	FPGA_Bluetooth_connection uut (
		.clock(clock), 
		.bt_state(bt_state), 
		.bt_enable(bt_enable), 
		.fpga_txd(fpga_txd), 
		.fpga_rxd(fpga_rxd), 
		.ep01wireIn(ep01wireIn), 
		.ep40trigIn(ep40trigIn), 
		.ep20wireOut(ep20wireOut), 
		.ep21wireOut(ep21wireOut),
		.ep22wireOut(ep22wireOut),
		.ep23wireOut(ep23wireOut)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		bt_state = 0;
		fpga_rxd = 0;
		ep01wireIn = 0;
		ep40trigIn = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#0 ep40trigIn = 16'h0000;
		#5 ep40trigIn = 16'h0007;
		#1 ep01wireIn = "AT";
		#8 ep01wireIn = "\r\n";
		#100 fpga_rxd = 1'b1;
		#108 fpga_rxd = 1'b0;
		#130 fpga_rxd = 1'b0;
		#135 fpga_rxd = 1'b1;
		#137 fpga_rxd = 1'b0;
		#138 fpga_rxd = 1'b1;
		#139 fpga_rxd = 1'b0;
		#143 fpga_rxd = 1'b1;
		#144 fpga_rxd = 1'b0;
		#145 fpga_rxd = 1'b1;
		#146 fpga_rxd = 1'b0;
		#160 ep40trigIn = 16'h0000;
	end
	
endmodule

