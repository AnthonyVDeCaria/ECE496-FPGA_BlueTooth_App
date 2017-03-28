`timescale 1us / 1ps

module testingAT;

	// Inputs
	reg clock;
	reg resetn;
	reg bt_state;
	reg [15:0] ep01wireIn;
	reg [15:0] ep02wireIn;
	
	parameter uart_cpd = 10'd50;
	parameter uart_spacing_limit = 10'd12;
	
	reg [7:0] AT_response_byte;
	reg start;

	// Outputs
	wire fpga_txd;
	wire fpga_rxd;
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
	wire tx_done;

	// Instantiate the Unit Under Test (UUT)
	FPGA_Bluetooth_connection uut (
		.clock(clock), 
		.bt_state(bt_state), 
		.fpga_txd(fpga_txd), 
		.fpga_rxd(fpga_rxd), 
		.uart_cpd(uart_cpd),
		.uart_byte_spacing_limit(uart_spacing_limit),
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
	
	UART_tx santas_little_helper(
			.clk(clock), 
			.resetn(resetn), 
			.start(start), 
			.cycles_per_databit(uart_cpd), 
			.tx_line(fpga_rxd),
			.tx_data(AT_response_byte),
			.tx_done(tx_done)
		);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 1'b0;
		bt_state = 0;
		ep01wireIn = 0;
		ep02wireIn = 0;
		start = 1'b0;
		AT_response_byte = 8'h00;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 resetn = 1'b1;
		#0 ep02wireIn = 16'h0001;
		
		#50 ep02wireIn = 16'h0004;
		
		#100 ep01wireIn = "AT";
		#100 ep02wireIn = 16'h000C;
		
		#150 ep02wireIn = 16'h0014;
		
		#200 ep01wireIn = "+N";
		#200 ep02wireIn = 16'h000C;
		
		#250 ep02wireIn = 16'h0014;		
		
		#300 ep01wireIn = "AM";
		#300 ep02wireIn = 16'h000C;
		
		#350 ep02wireIn = 16'h0014;
		
		#400 ep01wireIn = "E=";
		#400 ep02wireIn = 16'h000C;
		
		#450 ep02wireIn = 16'h0014;
		
		#500 ep01wireIn = "OP";
		#500 ep02wireIn = 16'h000C;
		
		#550 ep02wireIn = 16'h0034;
		
		#6000 AT_response_byte = "O";
		#6000 start = 1'b1;
		#6005 start = 1'b0;
		
		#6050 AT_response_byte = "K";
		#6050 start = 1'b1;
		#6055 start = 1'b0;
		
	end
	
endmodule

