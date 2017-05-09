/*
	Anthony De Caria - November 29, 2016

	This module handles the receiver logic for the ECE496-FPGA_Bluetooth_App
	by calling the modules handle_at_response and handle_app_commands.
*/

module receiver_centre(
		clock, reset, fpga_rxd,
		want_at, at_command_sent,
		uart_cpd, uart_byte_spacing,
		at_response_flag,
		RFIFO_rd_en, RFIFO_out, RFIFO_wr_count, RFIFO_rd_count, RFIFO_full, RFIFO_empty,
		stream_select, ds_sending_flag
	);
	/*
		I/Os
	*/
	// General
	input clock, reset, fpga_rxd;
	input want_at, at_command_sent;
	
	// UART
	input [9:0] uart_cpd;
	input [9:0] uart_byte_spacing;
	
	// Output Flags
	output at_response_flag;
	output [7:0] stream_select;
	output ds_sending_flag;
	
	// RFIFO
	input RFIFO_rd_en;
	output [15:0] RFIFO_out;
	output [6:0] RFIFO_rd_count;
	output [7:0] RFIFO_wr_count; 
	output RFIFO_full;
	output RFIFO_empty;
	
	/*
		Wires
	*/	
	// General
	wire at_start, ds_start;
	wire [9:0] byte_spacing_limit, full_byte_limit;
	
	// UART
	wire [7:0] rx_data;
	wire rx_collecting_data, rx_done;
	
	/*
		Assignments
	*/
	assign at_start = want_at & at_command_sent;
	assign ds_start = ~want_at & ~reset;
	
	/*
		Modules
	*/
	UART_rx rx(
		.clk(clock),
		.resetn(~reset),
		.cycles_per_databit(uart_cpd),
		.rx_line(fpga_rxd),
		.rx_data(rx_data),
		.rx_collecting_data(rx_collecting_data),
		.rx_data_valid(rx_done)
	);
	
	handle_at_response BLE_handler(
		.clock(clock), 
		.reset(reset),
		.start(at_start), 
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
	
	handle_app_commands app_handler(	
		.clock(clock), 
		.reset(reset),
		.start(ds_start), 
		.uart_done(rx_done),
		.uart_byte_spacing(uart_byte_spacing), 
		.uart_cpd(uart_cpd),
		.uart_byte(rx_data),
		.stream_select(stream_select), 
		.ds_sending_flag(ds_sending_flag)
	);
	
endmodule
