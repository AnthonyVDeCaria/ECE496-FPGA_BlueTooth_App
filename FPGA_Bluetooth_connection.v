/*
Anthony De Caria - September 28, 2016

This module creates a connection between an ion sensor and a HC-05 Bluetooth module.
It assumes input and output wires created by Opal Kelly.
*/

module FPGA_Bluetooth_connection(
		clock, 
		bt_state, bt_enable, fpga_txd, fpga_rxd, 
		ep01wireIn, ep02wireIn, ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut, 
		ep24wireOut, ep25wireOut, ep26wireOut, ep27wireOut
	);
	
	/*
		I/Os
	*/
	input clock;
	
	input fpga_rxd, bt_state;
	output bt_enable, fpga_txd;

	input [15:0] ep01wireIn, ep02wireIn;

	output [15:0] ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut, ep24wireOut, ep25wireOut, ep26wireOut, ep27wireOut;

	/*
		Wires 
	*/
	wire reset, user_data_loaded, user_data_done, AT_FIFO_access, finished_with_AT_FIFO; 
	wire start_tx, start_rx, tx_done, rx_done;
	wire begin_connection, want_at;
	wire [1:0] data_select;
	
	parameter AT_end = "\r\n";
	parameter TFIFO_end = 16'h000A;
	
	/*
		FSM wires
	*/
	parameter Idle = 4'b0000, Done = 4'b1111;
	parameter Wait_for_User_Data = 4'b0001, Load_T_WA = 4'b0010, Rest_T_WA = 4'b0011;
	parameter Load_T = 4'b0100, Rest_T = 4'b0101;
	parameter Load_Transmission = 4'b0110, Begin_Transmission = 4'b0111, Rest_Transmission = 4'b1000;
	parameter Receive_AT_Response = 4'b1001, Load_AT_FIFO = 4'b1010, Rest_AT_FIFO = 4'b1011;
	parameter Wait_for_User_Demand = 4'b1100, Read_AT_FIFO = 4'b1101, Rest_AT_User = 4'b1110;
	reg [3:0] curr, next;

	/*
		Assignments
	*/
	assign reset = ep02wireIn[0];
	assign want_at = ep02wireIn[1];
	assign begin_connection = ep02wireIn[2];
	assign user_data_loaded = ep02wireIn[3];
	assign user_data_done = ep02wireIn[4];
	assign AT_FIFO_access = ep02wireIn[5];
	assign finished_with_AT_FIFO = ep02wireIn[6];
//	assign data_select[0] = ep02wireIn[7];
//	assign data_select[1] = ep02wireIn[8];

	assign data_select[0] = 1'b1;
	assign data_select[1] = 1'b1;
	
	assign bt_enable = ~want_at;
		
	/*
		Sensor
	*/
	wire [15:0]sensor_data;
	test_sensor_analog fake(.select(data_select), .d_out(sensor_data));
	
	/*
		FIFOs
	*/
	wire [15:0] TFIFO_in, TFIFO_out, AT_FIFO_in, AT_FIFO_out;
	wire [11:0] TFIFO_rd_count, TFIFO_wr_count, AT_FIFO_rd_count, AT_FIFO_wr_count;
	wire TFIFO_full, TFIFO_empty, TFIFO_wr_en, TFIFO_rd_en;
	wire AT_FIFO_full, AT_FIFO_empty, AT_FIFO_wr_en, AT_FIFO_rd_en;
	
	mux_2_16bit TFIFO_input(.data0(sensor_data), .data1(ep01wireIn), .sel(want_at), .result(TFIFO_in) );
	
	assign TFIFO_wr_en = (curr == Load_T_WA) || (curr == Load_T);
	assign TFIFO_rd_en = (curr == Load_Transmission);
	assign AT_FIFO_wr_en = (curr == Load_AT_FIFO);
	assign AT_FIFO_rd_en = (curr == Read_AT_FIFO);
	
	FIFO_4096x16 TFIFO(
		.rst(reset),

		.wr_clk(clock),
		.rd_clk(clock),

		.wr_en(TFIFO_wr_en),
		.rd_en(TFIFO_rd_en),

		.din(TFIFO_in),
		.dout(TFIFO_out),

		.full(TFIFO_full),
		.empty(TFIFO_empty),

		.wr_ack(),
		.overflow(),

		.valid(),
		.underflow(),

		.rd_data_count(TFIFO_rd_count),
		.wr_data_count(TFIFO_wr_count)
	);
	
	FIFO_4096x16 AT_FIFO(
		.rst(reset),

		.wr_clk(clock),
		.rd_clk(clock),

		.wr_en(AT_FIFO_wr_en),
		.rd_en(AT_FIFO_rd_en),

		.din(AT_FIFO_in),
		.dout(AT_FIFO_out),

		.full(AT_FIFO_full),
		.empty(AT_FIFO_empty),

		.wr_ack(),
		.overflow(),

		.valid(),
		.underflow(),

		.rd_data_count(AT_FIFO_rd_count),
		.wr_data_count(AT_FIFO_wr_count)
	);
	
	wire [15:0] last_stored;
	wire l_s_e;
	assign l_s_e = (curr == Load_AT_FIFO);
	
	register_16bit_enable_async r_last_stored(
		.clk(clock), 
		.resetn(~reset), 
		.enable(l_s_e), 
		.select(l_s_e), 
		.d(AT_FIFO_in), 
		.q(last_stored)
	);
	
	/*
		Output
	*/
	assign start_tx = (curr == Begin_Transmission);
	
	serializer_16bit tx(
		.clock(clock), 
		.resetn(~reset), 
		.data(TFIFO_out), 
		.start_transmission(start_tx), 
		.finish_transmission(tx_done), 
		.tx(fpga_txd) 
	);
	
	/*
		Input
	*/
	assign start_rx = (curr == Receive_AT_Response);
	
	deserializer_16bit rx(
		.clock(clock), 
		.resetn(~reset), 
		.line_in(fpga_rxd), 
		.start_receiving(start_rx), 
		.finish_receiving(rx_done), 
		.data_out(AT_FIFO_in)
	);
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			Idle: 
			begin
				if(begin_connection)
				begin
					if(want_at)
						next = Wait_for_User_Data; 
					else
						next = Load_T;
				end
				else
					next = Idle;
			end
			
			Wait_for_User_Data: 
			begin
				if(user_data_loaded)
					next = Load_T_WA;
				else
					next = Wait_for_User_Data;
			end
			
			Load_T_WA:
			begin
				next = Rest_T_WA;
			end
			
			Rest_T_WA:
			begin
				if(user_data_done)
					next = Load_Transmission;
				else
					next = Wait_for_User_Data;
			end
			
			Load_T:
			begin
				next = Rest_T;
			end

			Rest_T:
			begin
				if((TFIFO_wr_count == TFIFO_end) ? 1'b1: 1'b0)
					next = Load_Transmission;
				else
					next = Load_T;
			end
			
			Load_Transmission:
			begin
				next = Begin_Transmission;
			end
			
			Begin_Transmission:
			begin
				if(tx_done)
					next = Rest_Transmission;
				else
					next = Begin_Transmission;
			end
			
			Rest_Transmission:
			begin
				if(TFIFO_empty)
				begin
					if(want_at)
						next = Receive_AT_Response;
					else
						next = Done;
				end
				else
					next = Load_Transmission;
			end
			
			Receive_AT_Response:
			begin
				if(rx_done)
					next = Load_AT_FIFO;
				else
					next = Receive_AT_Response;
			end
			
			Load_AT_FIFO:
			begin
				next = Rest_AT_FIFO;
			end
			
			Rest_AT_FIFO:
			begin
				if( (last_stored == AT_end) ? 1'b1: 1'b0)
					next = Receive_AT_Response;
				else
					next = Wait_for_User_Demand;
			end
			
			Wait_for_User_Demand:
			begin
				if(AT_FIFO_access)
					next = Read_AT_FIFO;
				else
					next = Wait_for_User_Demand;
			end
			
			Read_AT_FIFO:
			begin
				next = Rest_AT_User;
			end
			
			Rest_AT_User:
			begin
				if(finished_with_AT_FIFO)
					next = Done;
				else
					next = Wait_for_User_Demand;
			end
			
			Done:
			begin
				if(begin_connection)
					next = Done;
				else
					next = Idle;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset) curr <= Idle; else curr <= next;
	end
	
	/*
		Check Assignments
	*/
	
	assign ep20wireOut[0] = curr[0];
	assign ep20wireOut[1] = curr[1];
	assign ep20wireOut[2] = curr[2];
	assign ep20wireOut[3] = curr[3];
	assign ep20wireOut[4] = next[0];
	assign ep20wireOut[5] = next[1];
	assign ep20wireOut[6] = next[2];
	assign ep20wireOut[7] = next[3];
	assign ep20wireOut[8] = tx_done;
	assign ep20wireOut[9] = rx_done;
	assign ep20wireOut[10] = TFIFO_full;
	assign ep20wireOut[11] = TFIFO_empty;
	assign ep20wireOut[12] = TFIFO_wr_en;
	assign ep20wireOut[13] = TFIFO_rd_en;
	assign ep20wireOut[14] = fpga_txd;
	assign ep20wireOut[15] = fpga_rxd;
	
	assign ep21wireOut = AT_FIFO_in;
	assign ep22wireOut = TFIFO_out;
	
	assign ep23wireOut = ep02wireIn;
	
	assign ep24wireOut = TFIFO_rd_count;
	assign ep25wireOut = TFIFO_wr_count;
	assign ep26wireOut = AT_FIFO_rd_count;
	assign ep27wireOut = AT_FIFO_wr_count;
	
endmodule

