`timescale 1us / 1ps

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
	wire l_tx_timer, rn_tx_timer;
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
		.tx_done(done)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 0;
		ep01wireIn = 8'h00;
		start = 0;

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

