/*
Anthony De Caria - September 28, 2016

This module creats Opal Kelly wires for FPGA_Bluetooth_connection.
As well as providing the FPGA pins.
*/

module HM_10(CLK1MHZ, LED, HM_10_STATE, HM_10_TXD, HM_10_BREAK, HM_10_RXD, hi_in, hi_out, hi_inout, hi_aa, i2c_sda, i2c_scl, hi_muxsel);
	
	/*
		Others
	*/
	input CLK1MHZ;
	input HM_10_STATE, HM_10_TXD;
	output HM_10_BREAK, HM_10_RXD;
	output [7:0] LED;
	
	assign HM_10_BREAK = 1'b0;
	
	parameter uart_cpd = 10'd50;
	parameter uart_spacing_limit = 10'd12;
	
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
		.bt_state(HM_10_STATE),
		.bt_txd(HM_10_TXD),
		.bt_rxd(HM_10_RXD), 
		.lights(LED),
		.uart_cpd(uart_cpd),
		.uart_spacing_limit(uart_spacing_limit),
		.hi_in(hi_in), 
		.hi_out(hi_out), 
		.hi_inout(hi_inout), 
		.hi_aa(hi_aa), 
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl), 
		.hi_muxsel(hi_muxsel)
	);
	
endmodule

