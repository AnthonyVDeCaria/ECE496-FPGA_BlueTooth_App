/*
Anthony De Caria - September 28, 2016

This module creates a connection between an ion sensor and a HC-05 Bluetooth module.
It assumes input and output wires created by Opal Kelly.
*/

module FPGA_Bluetooth_connection(clock, bt_state, bt_enable, fpga_txd, fpga_rxd, ep01wireIn, ep40trigIn, ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut);
	
	/*
		I/Os
	*/
	input clock;
	
	input fpga_rxd, bt_state;
	output bt_enable, fpga_txd;

	input [15:0] ep01wireIn;
	input [15:0] ep40trigIn;

	output [15:0] ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut;

	/*
		Wires 
	*/
	wire resetn, want_at, user_ready, at_ready, tx_done, rx_done;
	wire [1:0] data_select;
	wire [15:0] calmed_ep40trigIn;
	
	/*
		FSM wires
	*/
	
	parameter Idle = 3'b000, Load_TFIFO = 3'b001, FIFO_Breather = 3'b010, Start_Transmission = 3'b011; 
	parameter Receive_AT_Response = 3'b100, Complete = 3'b110;
	reg [2:0] curr, next;

	/*
		Assignments
	*/
	edge_detector_16bit triggers(.clk(clock), .d(ep40trigIn), .q(calmed_ep40trigIn) );
	
	assign resetn = calmed_ep40trigIn[0];
	assign want_at = calmed_ep40trigIn[1];
	assign user_ready = calmed_ep40trigIn[2];
	assign at_ready = calmed_ep40trigIn[3];
	
	assign data_select[0] = calmed_ep40trigIn[4];
	assign data_select[1] = calmed_ep40trigIn[5];
	
	assign bt_enable = want_at;
	
	assign ep20wireOut[0] = bt_state;
	assign ep20wireOut[1] = tx_done;
	assign ep20wireOut[2] = rx_done;
	assign ep20wireOut[3] = curr[0];
	assign ep20wireOut[4] = curr[1];
	assign ep20wireOut[5] = curr[2];
	assign ep20wireOut[6] = next[0];
	assign ep20wireOut[7] = next[1];
	assign ep20wireOut[8] = next[2];
	assign ep20wireOut[9] = bt_enable;
	assign ep20wireOut[10] = fpga_txd;
	assign ep20wireOut[11] = fpga_rxd;
	assign ep20wireOut[12] = want_at;
	assign ep20wireOut[13] = 1'b1;
	assign ep20wireOut[14] = TFIFO_full;
	assign ep20wireOut[15] = TFIFO_empty;
	
	assign ep23wireOut = calmed_ep40trigIn;
	
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
	assign ep22wireOut = TFIFO_in;
	
	mux_2_16bit TFIFO_input(.data0(sensor_data), .data1(ep01wireIn), .sel(want_at), .result(TFIFO_in) );
	
	FIFO_4096x16 TFIFO(
	  .rst(~resetn),
	  .wr_clk(clock),
	  .rd_clk(clock),
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
	  .wr_clk(clock),
	  .rd_clk(clock),
	  .din(ATRFIFO_in),
	  .wr_en((curr == Receive_AT_Response)),
	  .rd_en((curr == Complete)),
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
	serial_transmitter_16 tx(
		.clock(clock), 
		.resetn(resetn), 
		.start((curr == Start_Transmission)), 
		.done(tx_done), 
		.data(TFIFO_out), 
		.more_data(~TFIFO_empty), 
		.line_out(fpga_txd)
	);
	
	/*
		Input
	*/
	serial_receiver_16 rx(
		.clock(clock), 
		.resetn(resetn), 
		.start((curr == Receive_AT_Response)), 
		.done(rx_done), 
		.data(ATRFIFO_in), 
		.more_data((ATRFIFO_in == at_end)), 
		.line_in(fpga_rxd) 
	);
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			Idle: if(user_ready) next = Load_TFIFO; else next = Idle;
			Load_TFIFO: next = FIFO_Breather;
			FIFO_Breather:
			begin
				if(want_at)
				begin
					if(at_ready)
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
				if(tx_done) 
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
			Receive_AT_Response: if(rx_done) next = Complete; else next = Receive_AT_Response;
			Complete: if(user_ready) next = Complete; else next = Idle;
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= Idle; else curr <= next;
	end
	
endmodule

