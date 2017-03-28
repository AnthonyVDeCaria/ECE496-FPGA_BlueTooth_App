`timescale 1us / 1ps

module testingUARTrx;
	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg [7:0] tx_data;
	
	// Outputs
	wire [7:0] rx_data;
	wire data_line;
	wire collecting_data;
	wire rx_data_valid;
	wire tx_done;
	wire [3:0] i, n_i;
	
//	parameter cpd = 10'd50;
//	parameter timer_cap = 10'd12;

	parameter cpd = 10'd11;
	parameter timer_cap = 10'd385;
	
	UART_rx uut(
			.i(i),
			.n_i(n_i),
	
	
			.clk(clock), 
			.resetn(~reset), 
			.cycles_per_databit(cpd), 
			.rx_line(data_line), 
			.rx_data(rx_data), 
			.collecting_data(collecting_data), 
			.rx_data_valid(rx_data_valid)
		);
	
	UART_tx santas_little_helper(
			.clk(clock), 
			.resetn(~reset), 
			.start(start), 
			.cycles_per_databit(cpd), 
			.tx_line(data_line), 
			.tx_data(tx_data), 
			.tx_done(tx_done)
		);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		start = 1'b0;
		tx_data = 8'h00;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 reset = 1'b0;
		#100 tx_data = 8'hF0;
		#110 start = 1'b1;
		#150 start = 1'b0;
		
		#600 tx_data = 8'hE1;
		#610 start = 1'b1;
		#650 start = 1'b0;
		
		#1100 tx_data = 8'hD2;
		#1110 start = 1'b1;
		#1150 start = 1'b0;
		
		#1600 tx_data = 8'hC3;
		#1610 start = 1'b1;
		#1650 start = 1'b0;
			
		#2100 tx_data = 8'hB4;
		#2110 start = 1'b1;
		#2150 start = 1'b0;
		
		#2600 tx_data = 8'hA5;
		#2610 start = 1'b1;
		#2650 start = 1'b0;
		
		#3100 tx_data = 8'h96;
		#3110 start = 1'b1;
		#3150 start = 1'b0;
		
		#3600 tx_data = 8'h87;
		#3610 start = 1'b1;
		#3650 start = 1'b0;
		
		#4100 tx_data = 8'h78;
		#4110 start = 1'b1;
		#4150 start = 1'b0;
			
		#4600 tx_data = 8'h69;
		#4610 start = 1'b1;
		#4650 start = 1'b0;
		
		#5100 tx_data = 8'h5A;
		#5110 start = 1'b1;
		#5150 start = 1'b0;
		
		#5600 tx_data = 8'h4B;
		#5610 start = 1'b1;
		#5650 start = 1'b0;
		
		#6100 tx_data = 8'h3C;
		#6110 start = 1'b1;
		#6150 start = 1'b0;
		
		#6600 tx_data = 8'h2D;
		#6610 start = 1'b1;
		#6650 start = 1'b0;
			
		#7100 tx_data = 8'h1E;
		#7110 start = 1'b1;
		#7150 start = 1'b0;
		
		#7600 tx_data = 8'h0F;
		#7610 start = 1'b1;
		#7650 start = 1'b0;
		#7655 reset = 1'b1;
	end
	
endmodule

