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

module testingAT;

	// Inputs
	reg clock;
	reg bt_state;
	reg fpga_rxd;
	reg [15:0] ep01wireIn;
	reg [15:0] ep02wireIn;

	// Outputs
	wire bt_break;
	wire fpga_txd;
	wire [15:0] ep20wireOut;
	wire [15:0] ep21wireOut;
	wire [15:0] ep22wireOut;
	wire [15:0] ep23wireOut;
	wire [15:0] ep24wireOut;
	wire [15:0] ep25wireOut;
	wire [15:0] ep26wireOut;
	wire [15:0] ep27wireOut;
	wire [15:0] ep28wireOut;
	wire [15:0] ep29wireOut;
	wire [15:0] ep30wireOut;

	// Instantiate the Unit Under Test (UUT)
	FPGA_Bluetooth_connection uut (
		.clock(clock), 
		.bt_state(bt_state), 
		.bt_break(bt_break), 
		.fpga_txd(fpga_txd), 
		.fpga_rxd(fpga_rxd), 
		.ep01wireIn(ep01wireIn), 
		.ep02wireIn(ep02wireIn),
		.ep20wireOut(ep20wireOut), 
		.ep21wireOut(ep21wireOut),
		.ep22wireOut(ep22wireOut),
		.ep23wireOut(ep23wireOut),
		.ep24wireOut(ep24wireOut), 
		.ep25wireOut(ep25wireOut),
		.ep26wireOut(ep26wireOut),
		.ep27wireOut(ep27wireOut),
		.ep28wireOut(ep28wireOut),
		.ep29wireOut(ep29wireOut),
		.ep30wireOut(ep30wireOut)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		bt_state = 0;
		fpga_rxd = 1;
		ep01wireIn = 0;
		ep02wireIn = 0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 ep02wireIn = 16'h0001;
		
		#50 ep02wireIn = 16'h0006;
		
		#100 ep01wireIn = "AT";
		#100 ep02wireIn = 16'h000E;
		
		#150 ep02wireIn = 16'h0016;
		
		#200 ep01wireIn = "\r\n";
		#200 ep02wireIn = 16'h000E;
		
		#275 ep02wireIn = 16'h0036;
		
		#2000 fpga_rxd = 1'b0;
		#2003 fpga_rxd = 1'b1;
		#2010 fpga_rxd = 1'b0;
		#2017 fpga_rxd = 1'b1;
		
		#3000 ep02wireIn = 16'h0046;
		#3010 ep02wireIn = 16'h0086;
		#3050 ep02wireIn = 16'h0046;
		#3100 ep02wireIn = 16'h0186;
	end
	
endmodule

