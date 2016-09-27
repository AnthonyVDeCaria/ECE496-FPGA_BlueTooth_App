module FPGA_Bluetooth_connection(hi_in, hi_out, hi_inout, hi_aa, i2c_sda, i2c_scl, hi_muxsel, CLK1MHZ, ybusn, ybusp);
	
	/*
		Others
	*/
	input CLK1MHZ;
	output [1:0] ybusn; // 1-W22 , 0-T20
	output [1:0] ybusp; // 1-W20 , 0-T19
	
	parameter n = 0, at_end = "\r\n";
	
	/*
		FSM wires
	*/
	
	parameter Idle = 3'b000, Load_TFIFO = 3'b001, Start_Transmission = 3'b010, Receive_AT_Response = 3'b011, Complete = 3'b100;
	reg [2:0] curr, next;
	
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
	okTriggerIn	ep40 (.ok1(ok1), .ep_addr(8'h40), .ep_clk(CLK1MHZ), .ep_trigger(ep40trigIn));

	wire resetn, want_at, user_ready;
	assign resetn = ep40trigIn[0];
	assign want_at = ep40trigIn[1];
	assign user_ready = ep40trigIn[2];
	
	wire [1:0] data_select;
	assign data_select[0] = ep40trigIn[3];
	assign data_select[1] = ep40trigIn[4];
	
	// wires
	okWireIn ep01 (.ok1(ok1), .ep_addr(8'h01), .ep_dataout(ep01wireIn) );
	
	okWireOut ep20 (.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h20), .ep_datain(ep20wireOut) );
	okWireOut ep21 (.ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'h21), .ep_datain(ep21wireOut) );
	
	/*
		Wires
	*/
	wire bt_enable, bt_state, bt_txd, bt_rxd;
	wire fpga_txd, fpga_rxd;
	
	assign ybusp[0] = bt_state;
	assign ybusp[1] = bt_enable;
	assign ybusn[0] =  bt_rxd;
	assign ybusn[1] = bt_txd;
	
	assign bt_enable = want_at;

	assign bt_rxd = fpga_txd;
	assign bt_txd = fpga_rxd;
	
	wire sending_complete;
	
	assign ep20wireOut[0] = bt_state;
	assign ep20wireOut[1] = sending_complete;
	
	/*
		Sensor
	*/
	wire [15:0]sensor_data;
	test_sensor_analog fake(.select(data_select), .d_out(sensor_data));
	
	/*
		FIFOs
	*/
	wire [15:0] TFIFO_in, TFIFO_out, ATRFIFO_in, ATRFIFO_out;
	wire TFIFO_full, TFIFO_empty, ATRFIFO_full, ATRFIFO_empty;
	assign ep21wireOut = ATRFIFO_out;
	
	mux_2_16bit TFIFO_input(.data0(sensor_data), .data1(ep01wireIn), .sel(want_at), .result(TFIFO_in) );
	
	FIFO_4096x16 TFIFO(
	  .rst(resetn),
	  .wr_clk(CLK1MHZ),
	  .rd_clk(CLK1MHZ),
	  .din(TFIFO_in),
	  .wr_en((curr == Load_TFIFO)),
	  .rd_en((curr == Start_Transmission)),
	  .dout(TFIFO_out),
	  .full(TFIFO_full),
	  .wr_ack(),
	  .overflow(),
	  .empty(TFIFO_empty),
	  .valid(),
	  .underflow(),
	  .rd_data_count(),
	  .wr_data_count()
	);
	
	FIFO_4096x16 ATRFIFO(
	  .rst(resetn),
	  .wr_clk(CLK1MHZ),
	  .rd_clk(CLK1MHZ),
	  .din(ATRFIFO_in),
	  .wr_en((curr == Receive_AT_Response)),
	  .rd_en((curr == Done)),
	  .dout(ATRFIFO_out),
	  .full(ATRFIFO_full),
	  .wr_ack(),
	  .overflow(),
	  .empty(ATRFIFO_empty),
	  .valid(),
	  .underflow(),
	  .rd_data_count(),
	  .wr_data_count()
	);
	
	/*
		Output
	*/
	wire tx_done;
	serial_transmitter_16 tx(.clock(CLK1MHZ), .resetn(resetn), .start((curr == Start_Transmission)), .done(tx_done), .data(TFIFO_out), .more_data(TFIFO_empty), .line_out(fpga_txd) );
	
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
			Idle: if(user_ready) next = Load_TFIFO; else next = Idle;
			Load_TFIFO:
			begin
				if(want_at)
				begin
					if(TFIFO_in == at_end)
						next = Start_Transmission;
					else
						next = Load_TFIFO;
				end
				else
				begin
					if(TFIFO_full)
						next = Start_Transmission;
					else
						next = Load_TFIFO;
				end
			end
			Start_Transmission: 
			begin
				if(TFIFO_empty) 
				begin
					if(want_at)
					begin
						 next = Receive_AT_Response;
					end
					else
					begin
						next = Complete;
					end
				end
				else 
				begin
					next = Start_Transmission;
				end
			end
			Receive_AT_Response: if(ATRFIFO_in == at_end) next = Complete; else next = Receive_AT_Response;
			Complete: if(user_ready) next = Complete; else next = Idle;
		endcase
	end
	
	always@(posedge CLK1MHZ or negedge resetn)
	begin
		if(!resetn) curr <= Idle; else curr <= next;
	end
	
endmodule
