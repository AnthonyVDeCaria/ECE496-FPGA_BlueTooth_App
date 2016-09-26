module FPGA_Bluetooth_connection(hi_in, hi_out, hi_inout, hi_aa, i2c_sda, i2c_scl, hi_muxsel, CLK1MHZ, ybusn, ybusp);
	
	/*
		Others
	*/
	input CLK1MHZ;
	output [1:0] ybusn; // 1-W22 , 0-T20
	output [1:0] ybusp; // 1-W20 , 0-T19
	
	/*
		FSM wires
	*/
	
	parameter Idle = 3'b000, Send_Sensor_Data = 3'b001, Complete = 3'b101; //Load_Byte = 3'b010, Byte_Transmission = 3'b011, Restart_BT = 3'b100, ;
	reg [2:0] curr, next;
	
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
	assign i2c_sda = 1'bz;
	assign i2c_scl = 1'bz;
	assign hi_muxsel = 1'b0;
	
	parameter n = 1;
	
	wire			ti_clk;
	wire	[30:0]	ok1;
	wire	[16:0]	ok2;
	
//	wire	[15:0]	ep01wireIn;
	wire	[15:0]	ep20wireOut;
	wire	[15:0]	ep40trigIn;
	
	//--------------------------------
	// Instantiate the okHost and connect endpoints.
	// the n in the next line should match the N parameter for the wireOR below
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

	// triggers
	okTriggerIn	ep40 (.ok1(ok1),							.ep_addr(8'h40), .ep_clk(CLK1MHZ), .ep_trigger(ep40trigIn));

	wire resetn, want_at, user_ready;
	assign resetn = ep40trigIn[0];
//	assign want_at = ep40trigIn[1];
	assign user_ready = ep40trigIn[2];
	
	wire [1:0] data_select;
	assign data_select[0] = ep40trigIn[3];
	assign data_select[1] = ep40trigIn[4];
	
	// wires
//	okWireIn	ep01 (.ok1(ok1),							.ep_addr(8'h01), .ep_dataout(ep01wireIn));
	okWireOut	ep20 (.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h20), .ep_datain(ep20wireOut));
	
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
	
	wire sending_complete;
	
	assign ep20wireOut[0] = bt_state;
	assign ep20wireOut[1] = sending_complete;
	assign ep20wireOut[15:8] = sensor_data[7:0];
	
	/*
		Sensor
	*/
	test_sensor_analog fake(.select(data_select), .d_out(sensor_data));
	
	/*
		Output
	*/
	ece496_fpga_transmission tx(
									.clock(CLK1MHZ), .resetn(resetn), 
									.start((curr == Send_Sensor_Data)), .done(sending_complete), 
									.data(sensor_data), .data_size(5'b00001), 
									.line_out(fpga_txd)
								);
	
	/*
		Input
	*/
//	Shift_Register_8_Enable_Async_OneLoad rx(.clk(CLK1MHZ), .resetn(resetn), .enable(), .select(1'b0), .d(fpga_rxd), .q() );
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			Idle: if(user_ready) next = Send_Sensor_Data; else next = Idle;
			Send_Sensor_Data: if(sending_complete) next = Complete; else next = Idle;
			Complete: if(user_ready) next = Complete; else next = Idle;
		endcase
	end
	
	always@(posedge CLK1MHZ or negedge resetn)
	begin
		if(!resetn) curr <= Idle; else curr <= next;
	end
	
endmodule
