`timescale 1us / 1ps

module testingUART_sender_for_testing;

	// Inputs
	reg clock;
	reg reset;
	reg user_data_on_line;
	reg user_data_done;
	reg [15:0] half_word;

	// Outputs
	wire tx_done;
	wire tx_line;
//	wire [2:0] fbc_curr, fbc_next;
	
	// Instantiate the Unit Under Test (UUT)
	UART_sender_for_testing uut(
//		.fbc_curr(fbc_curr), .fbc_next(fbc_next),
		.clock(clock),
		.reset(reset),
		.uart_cpd(10'd50),
		.uart_byte_spacing(10'd12),
		.user_data_on_line(user_data_on_line),
		.user_data_done(user_data_done),
		.tx_done(tx_done),
		.half_word(half_word),
		.tx_line(tx_line)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		user_data_on_line = 0;
		user_data_done = 0;
		half_word = 16'd0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 reset = 1'b0;
		
		#10 half_word = 16'h4154;
		#10 user_data_on_line = 1'b1;
		
		#11 user_data_on_line = 1'b0;
		
		#30 half_word = 16'h6174;
		#30 user_data_on_line = 1'b1;
		
		#40 user_data_on_line = 1'b0;
		#40 user_data_done = 1'b1;
	end
	
endmodule

