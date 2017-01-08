/*
Anthony De Caria - September 28, 2016

This module creats Opal Kelly wires for FPGA_Bluetooth_connection.
As well as providing the FPGA pins.
*/

module FBC_w_OK(
		clock, bt_state, bt_txd, bt_rxd, lights, uart_cpd, uart_timer_cap,
		hi_in, hi_out, hi_inout, hi_aa, i2c_sda, i2c_scl, hi_muxsel
	);
	
	/*
		Others
	*/
	input clock;
	input bt_state, bt_txd;
	output bt_rxd;
	output [7:0] lights;
	
	input [9:0] uart_cpd, uart_timer_cap;
	
	input wire [7:0] hi_in;
	output wire [1:0] hi_out;
	inout wire [15:0] hi_inout;
	inout wire hi_aa;

	output wire i2c_sda;
	output wire i2c_scl;
	output wire hi_muxsel;
	
	/*
		Opal Kelly
	*/
	assign i2c_sda = 1'bz;
	assign i2c_scl = 1'bz;
	assign hi_muxsel = 1'b0;
	
	parameter num_ok_outs = 11;
	
	wire ti_clk;
	wire [30:0] ok1;
	wire [16:0] ok2;
	
	wire [15:0] ep01wireIn;
	wire [15:0] ep02wireIn;
	
	wire [15:0] ep20wireOut;
	wire [15:0] ep21wireOut;
	wire [15:0] ep22wireOut;
	wire [15:0] ep23wireOut;
	wire [15:0] ep24wireOut;
	wire [15:0] ep25wireOut;
	
	/*
		Not being used - Legacy Testing wires.
	*/
	wire [15:0] ep26wireOut;
	wire [15:0] ep27wireOut;
	wire [15:0] ep28wireOut;
	wire [15:0] ep29wireOut;
	wire [15:0] ep30wireOut;
	
	//--------------------------------
	// Instantiate the okHost and connect endpoints.
	// the n in the next line should match the N parameter for the wireOR below
	// and each 17 bits of this ok2x signal connects to a different wireOut or
	// pipeOut 
	wire [17*num_ok_outs-1:0] ok2x;
	okHost okHI (
		.hi_in(hi_in),
		.hi_out(hi_out),
		.hi_inout(hi_inout),
		.hi_aa(hi_aa),
		.ti_clk(ti_clk),
		.ok1(ok1),
		.ok2(ok2)
	);
	
	okWireOR # (.N(num_ok_outs)) wireOR (
		.ok2(ok2),
		.ok2s(ok2x)
	);

	// wires
	okWireIn ep01 (.ok1(ok1), .ep_addr(8'h01), .ep_dataout(ep01wireIn) );
	okWireIn ep02 (.ok1(ok1), .ep_addr(8'h02), .ep_dataout(ep02wireIn) );
	
	okWireOut ep20 (.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h20), .ep_datain(ep20wireOut) );
	okWireOut ep21 (.ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'h21), .ep_datain(ep21wireOut) );
	okWireOut ep22 (.ok1(ok1), .ok2(ok2x[ 2*17 +: 17 ]), .ep_addr(8'h22), .ep_datain(ep22wireOut) );
	okWireOut ep23 (.ok1(ok1), .ok2(ok2x[ 3*17 +: 17 ]), .ep_addr(8'h23), .ep_datain(ep23wireOut) );
	okWireOut ep24 (.ok1(ok1), .ok2(ok2x[ 4*17 +: 17 ]), .ep_addr(8'h24), .ep_datain(ep24wireOut) );
	
	okWireOut ep25 (.ok1(ok1), .ok2(ok2x[ 5*17 +: 17 ]), .ep_addr(8'h25), .ep_datain(ep25wireOut) );
	okWireOut ep26 (.ok1(ok1), .ok2(ok2x[ 6*17 +: 17 ]), .ep_addr(8'h26), .ep_datain(ep26wireOut) );
	okWireOut ep27 (.ok1(ok1), .ok2(ok2x[ 7*17 +: 17 ]), .ep_addr(8'h27), .ep_datain(ep27wireOut) );
	okWireOut ep28 (.ok1(ok1), .ok2(ok2x[ 8*17 +: 17 ]), .ep_addr(8'h28), .ep_datain(ep28wireOut) );
	okWireOut ep29 (.ok1(ok1), .ok2(ok2x[ 9*17 +: 17 ]), .ep_addr(8'h29), .ep_datain(ep29wireOut) );
	
	okWireOut ep30 (.ok1(ok1), .ok2(ok2x[ 10*17 +: 17 ]), .ep_addr(8'h30), .ep_datain(ep30wireOut) );
	
	/*
		FPGA
	*/	
	FPGA_Bluetooth_connection master_of_puppets(
		.clock(clock),
		.bt_state(bt_state),
		.fpga_txd(bt_rxd),
		.fpga_rxd(bt_txd),
		.uart_cpd(uart_cpd),
		.uart_timer_cap(uart_timer_cap),
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
	
	assign lights[3:0] = ~ep25wireOut[3:0];
	assign lights[7:4] = ~ep25wireOut[7:4];
	
endmodule

