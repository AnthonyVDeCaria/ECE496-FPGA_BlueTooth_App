`timescale 1us / 1ps

module testingHandleAppCommands;

	// Inputs
	reg clock;
	reg reset;
	reg start;
	
	reg [15:0] half_word;
	reg user_data_on_line;
	reg user_data_done;
	
	wire [7:0] rx_data;
	wire data_line;
	
	wire rx_done;
	
	parameter uart_cpd = 10'd50;
	parameter uart_byte_spacing = 10'd12;

	// Outputs
	wire [7:0] stream_select;
	wire ds_sending_flag;
	
//	wire [1:0] ds_curr, ds_next;
//	wire [7:0] commands, operands;

	// Instantiate the Unit Under Test (UUT)
	handle_app_commands uut(
//		.ds_curr(ds_curr), 
//		.ds_next(ds_next),
//		.commands(commands),
//		.operands(operands),
		.clock(clock), 
		.reset(reset),
		.start(start), 
		.uart_done(rx_done),
		.uart_cpd(uart_cpd),
		.uart_byte_spacing(uart_byte_spacing),
		.uart_byte(rx_data),
		.stream_select(stream_select), 
		.ds_sending_flag(ds_sending_flag)
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
		.rx_collecting_data(),
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
		half_word = 16'h0000;
		user_data_on_line = 1'b0;
		user_data_done = 1'b0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 reset = 1'b0;
		#100 start = 1'b1;
		
		#102 half_word = 16'h0078;
		#102 user_data_on_line = 1'b1;
		#105 user_data_on_line = 1'b0;
		
		#122 half_word = 16'h0101;
		#122 user_data_on_line = 1'b1;
		#125 user_data_on_line = 1'b0;
		
		#142 half_word = 16'h00FF;
		#142 user_data_on_line = 1'b1;
		#145 user_data_on_line = 1'b0;
		
		#145 user_data_done = 1'b1;
		
		#20000 reset = 1'b1;
	end
	
endmodule

