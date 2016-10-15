/*
	Anthony De Caria - October 15, 2016

	This module creates a UART receiver.
*/

module UART_rx(clk, resetn, cycles_per_databit, rx_line, rx_data, rx_data_valid);
	/*
		I/Os
	*/
	input clk, resetn;	
	input [9:0] cycles_per_bit; //Allows for 1024 cycles between each databit
	input rx_line;

	output rx_data_valid;
	output [7:0] rx_data;
	
	/*
		FSM
	*/
	reg [] curr, next;
	parameter Idle = ;

endmodule

