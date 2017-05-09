`timescale 1us / 1ps

module testingHandleATResponse;
	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg RFIFO_rd_en;
	
	reg [15:0] half_word;
	reg user_data_on_line;
	reg user_data_done;
	
	wire [7:0] rx_data;
	wire data_line;
	
	wire rx_done;
	wire rx_collecting_data;
	
	parameter uart_cpd = 10'd50;
	parameter uart_byte_spacing = 10'd12;

	// Outputs
	wire at_response_flag;
	wire [15:0] RFIFO_out;
	wire [7:0] RFIFO_wr_count; 
	wire [6:0] RFIFO_rd_count;
	
	wire [9:0] atr_timer_limit;
	wire [1:0] at_curr, at_next;
	wire l_atr_timer, rn_atr_timer, atr_timer_done;
	
	// Instantiate the Unit Under Test (UUT)
	handle_at_response uut(
		.clock(clock), 
		.reset(reset),
		.start(start), 
		.uart_done(rx_done), 
		.uart_collecting_data(rx_collecting_data),
		.RFIFO_in(rx_data), 
		.RFIFO_out(RFIFO_out), 
		.RFIFO_rd_en(RFIFO_rd_en), 
		.RFIFO_rd_count(RFIFO_rd_count), 
		.RFIFO_wr_count(RFIFO_wr_count), 
		.RFIFO_full(RFIFO_full), 
		.RFIFO_empty(RFIFO_empty),
		.uart_byte_spacing(uart_byte_spacing),
		.uart_cpd(uart_cpd),
		.at_response_flag(at_response_flag)
	);
	
	UART_sender_for_testing help(
		.clock(clock), 
		.reset(reset),
		.uart_cpd(uart_cpd), 
		.uart_byte_spacing(uart_byte_spacing),
		.user_data_on_line(user_data_on_line), 
		.user_data_done(user_data_done),
		.tx_done(tx_done),
		.half_word(half_word),
		.tx_line(data_line)
	);
	
	UART_rx rx(
		.clk(clock),
		.resetn(~reset),
		.cycles_per_databit(uart_cpd),
		.rx_line(data_line),
		.rx_data(rx_data),
		.rx_collecting_data(rx_collecting_data),
		.rx_data_valid(rx_done)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1'b1;
		start = 1'b0;
		user_data_done = 1'b0;
		half_word = 16'h00;
		user_data_on_line = 1'b0;
		RFIFO_rd_en = 1'b0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 reset = 1'b0;
		#100 start = 1'b1;
		
		#110 half_word = "OK";
		#110 user_data_on_line = 1'b1;
		#111 user_data_on_line = 1'b0;
		
		#220 half_word = "AT";
		#220 user_data_on_line = 1'b1;
		#221 user_data_on_line = 1'b0;
		
		#300 user_data_done = 1'b1;
		
		#5000 RFIFO_rd_en = 1'b1;
		
		#7500 reset = 1'b1;
	end
	
endmodule

