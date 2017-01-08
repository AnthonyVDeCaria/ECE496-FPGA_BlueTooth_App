/*
Anthony De Caria - September 28, 2016

This module creats Opal Kelly wires for FPGA_Bluetooth_connection.
As well as providing the FPGA pins.
*/

module HC_05(CLK1MHZ, LED, HC_05_STATE, HC_05_TXD, HC_05_ENABLE, HC_05_RXD, hi_in, hi_out, hi_inout, hi_aa, i2c_sda, i2c_scl, hi_muxsel);
	
	/*
		Others
	*/
	input CLK1MHZ;
	input HC_05_STATE, HC_05_TXD;
	output HC_05_ENABLE, HC_05_RXD;
	output [7:0] LED;
	
	assign HC_05_ENABLE = 1'b1;
	
	parameter uart_cpd = 10'd11;
	parameter uart_timer_cap = 10'd385;
	
	/*
		Opal Kelly
	*/
	input wire [7:0] hi_in;
	output wire [1:0] hi_out;
	inout wire [15:0] hi_inout;
	inout wire hi_aa;

	output wire i2c_sda;
	output wire i2c_scl;
	output wire hi_muxsel;
	
	/*
		FBC_w_OK
	*/	
	FBC_w_OK grand_central_station(
		.clock(CLK1MHZ),
		.bt_state(HC_05_STATE),
		.bt_txd(HC_05_TXD),
		.bt_rxd(HC_05_RXD),
		.uart_cpd(uart_cpd),
		.uart_timer_cap(uart_timer_cap),
		.lights(LED), 
		.hi_in(hi_in), 
		.hi_out(hi_out), 
		.hi_inout(hi_inout), 
		.hi_aa(hi_aa), 
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl), 
		.hi_muxsel(hi_muxsel)
	);
	
endmodule

