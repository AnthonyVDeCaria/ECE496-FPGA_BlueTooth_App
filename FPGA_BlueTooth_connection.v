module FPGA_Bluetooth_connection(CLK1MHZ, ybusn, ybusp)
	input CLK1MHZ;

	output [1:0] ybusn; // 1-W22 , 0-T20
	output [1:0] ybusp; // 1-W20 , 0-T19
	
	wire [7:0]sensor_data;
	
	wire ;
	
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
	Shift_Register_8_Enable_Async_OneLoad tx(.clk(CLK1MHZ), .resetn(/*user*/), .enable(), .select(/*user*/), .d(sensor_data), .q(fpga_txd) );
	
	/*
		Input
	*/
	Shift_Register_8_Enable_Async_OneLoad rx(.clk(CLK1MHZ), .resetn(/*user*/), .enable(), .select(1'b0), .d(fpga_rxd), .q() );
	
endmodule
