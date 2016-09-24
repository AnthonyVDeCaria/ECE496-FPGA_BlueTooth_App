module FPGA_Bluetooth_connection(hi_in, hi_out, hi_inout, hi_aa, i2c_sda, i2c_scl, hi_muxsel, LED, 
									CLK1MHZ, ybusn, ybusp);
	/*
		Opal Kelly
	*/
	input  wire	[7:0]	hi_in;
	output wire	[1:0]	hi_out;
	inout  wire	[15:0]	hi_inout;
	inout  wire			hi_aa;

	output wire			i2c_sda;
	output wire			i2c_scl;
	output wire			hi_muxsel;
	output wire	[7:0]	LED;
	
	parameter n;
	
	assign i2c_sda = 1'bz;
	assign i2c_scl = 1'bz;
	assign hi_muxsel = 1'b0;
	
	wire			ti_clk;
	wire	[30:0]	ok1;
	wire	[16:0]	ok2;
	
	//--------------------------------
	// Instantiate the okHost and connect endpoints.
	// the 2 in the next line should match the N parameter for the wireOR below
	// and each 17 bits of this ok2x signal connects to a different wireOut or
	// pipeOut 
	wire [17*n-1:0]  ok2x;
	okHost okHI (
		.hi_in(hi_in),
		.hi_out(hi_out),
		.hi_inout(hi_inout),
		.hi_aa(hi_aa),
		.ti_clk(ti_clk),
		.ok1(ok1),
		.ok2(ok2)
	);
	
	okWireOR # (.N(n)) wireOR (
		.ok2(ok2),
		.ok2s(ok2x)
	);
	
	/*
		Others
	*/
	input CLK1MHZ;
	output [1:0] ybusn; // 1-W22 , 0-T20
	output [1:0] ybusp; // 1-W20 , 0-T19
	
	/*
		Wires
	*/
	wire [7:0]sensor_data;
	
	wire bt_enable, bt_state, bt_txd, bt_rxd;
	wire fpga_txd, fpga_rxd;
	
	assign bt_state = ybusp[0];
	assign bt_enable = ybusp[1];
	assign bt_rxd = ybusn[0];
	assign bt_txd = ybusn[1];

	assign fpga_txd = bt_rxd;
	assign fpga_rxd = bt_txd;
	
	/*
		Sensor
	*/
	sensor_analog fake(.select(), .d_out(sensor_data));
	
	/*
		Output
	*/
//	Shift_Register_8_Enable_Async_OneLoad tx(.clk(CLK1MHZ), .resetn(/*user*/), .enable(), .select(/*user*/), .d(sensor_data), .q(fpga_txd) );

	ece496_fpga_transmission tx(.clock(CLK1MHZ), .resetn(/*user*/), .start(/*user*/), .done(), .data(), .data_size(5'b00001), .line_out(fpga_txd) );
	
	/*
		Input
	*/
	Shift_Register_8_Enable_Async_OneLoad rx(.clk(CLK1MHZ), .resetn(/*user*/), .enable(), .select(1'b0), .d(fpga_rxd), .q() );
	
endmodule
