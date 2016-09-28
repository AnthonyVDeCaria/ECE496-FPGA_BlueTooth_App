/*
Anthony De Caria - September 28, 2016

This module creats Opal Kelly wires for FPGA_Bluetooth_connection.
As well as providing the FPGA pins.
*/

module FBC_w_OK(hi_in, hi_out, hi_inout, hi_aa, i2c_sda, i2c_scl, hi_muxsel, CLK1MHZ, ybusn, ybusp);
	
	/*
		Others
	*/
	input CLK1MHZ;
	inout [1:0] ybusn; // 1-W22 , 0-T20
	inout [1:0] ybusp; // 1-W20 , 0-T19
	
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
	assign i2c_sda = 1'bz;
	assign i2c_scl = 1'bz;
	assign hi_muxsel = 1'b0;
	
	parameter num_ok_wires_pipes = 3;
	
	wire ti_clk;
	wire [30:0] ok1;
	wire [16:0] ok2;
	
	wire [15:0] ep01wireIn;
	wire [15:0] ep20wireOut;
	wire [15:0] ep21wireOut;
	wire [15:0] ep40trigIn;
	
	//--------------------------------
	// Instantiate the okHost and connect endpoints.
	// the n in the next line should match the N parameter for the wireOR below
	// and each 17 bits of this ok2x signal connects to a different wireOut or
	// pipeOut 
	wire [17*num_ok_wires_pipes-1:0] ok2x;
	okHost okHI (
		.hi_in(hi_in),
		.hi_out(hi_out),
		.hi_inout(hi_inout),
		.hi_aa(hi_aa),
		.ti_clk(ti_clk),
		.ok1(ok1),
		.ok2(ok2)
	);
	
	okWireOR # (.N(num_ok_wires_pipes)) wireOR (
		.ok2(ok2),
		.ok2s(ok2x)
	);

	// triggers
	okTriggerIn	ep40 (.ok1(ok1), .ep_addr(8'h40), .ep_clk(CLK1MHZ), .ep_trigger(ep40trigIn) );
	
	// wires
	okWireIn ep01 (.ok1(ok1), .ep_addr(8'h01), .ep_dataout(ep01wireIn) );
	
	okWireOut ep20 (.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h20), .ep_datain(ep20wireOut) );
	okWireOut ep21 (.ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'h21), .ep_datain(ep21wireOut) );
	
	/*
		FPGA
	*/
	FPGA_Bluetooth_connection master_of_puppets(
		.clock(CLK1MHZ),
		.bt_state(ybusp[0]),
		.bt_enable(ybusp[1]),
		.fpga_txd(ybusn[0]),
		.fpga_rxd(ybusn[1]), 
		.ep01wireIn(ep01wireIn),
		.ep40trigIn(ep40trigIn),
		.ep20wireOut(ep20wireOut),
		.ep21wireOut(ep21wireOut)
	);
	
	
endmodule
