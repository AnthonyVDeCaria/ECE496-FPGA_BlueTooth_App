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

module testingUARTtx;

	// Inputs
	reg clock;
	reg resetn;
	reg start;
	reg [7:0] ep01wireIn;
	reg [9:0] cpd;

	// Outputs
	wire fpga_txd;
	wire done;
	wire at_cpd;
	wire [9:0] timer;
	wire [9:0] n_timer;
	wire [2:0] c;
	wire [2:0] n;

	// Instantiate the Unit Under Test (UUT)
	UART_tx uut(
		.clk(clock), 
		.resetn(resetn), 
		.start(start), 
		.cycles_per_databit(cpd), 
		.tx_line(fpga_txd), 
		.tx_data(ep01wireIn), 
		.tx_done(done),
		.timer(timer), 
		.n_timer(n_timer), 
		.at_cpd(at_cpd), 
		.curr(c), 
		.next(n)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 0;
		ep01wireIn = 8'h00;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 ep01wireIn = 8'h45;
		#0 resetn = 1'b1;
		
		#10 cpd = 10'h00d;
		
		#50 start = 1'b1;
		
		#150 start = 1'b0;
	end
	
endmodule

