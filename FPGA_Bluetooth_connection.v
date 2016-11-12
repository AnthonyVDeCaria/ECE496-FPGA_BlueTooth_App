/*
	Anthony De Caria - September 28, 2016

	This module creates a connection between an ion sensor and a HC-05 Bluetooth module.
	It assumes input and output wires created by Opal Kelly.
*/

module FPGA_Bluetooth_connection(
		clock, 
		bt_state, bt_enable, fpga_txd, fpga_rxd, 
		ep01wireIn, ep02wireIn, 
		ep20wireOut, 
		ep21wireOut, 
		ep22wireOut, ep23wireOut, 
		ep24wireOut, ep25wireOut, ep26wireOut, 
		ep27wireOut, ep28wireOut, ep29wireOut,
		ep30wireOut
	);
	
	/*
		I/Os
	*/
	input clock;
	
	input fpga_rxd, bt_state;
	output bt_enable, fpga_txd;

	input [15:0] ep01wireIn, ep02wireIn;

	output [15:0] ep20wireOut; 
	output [15:0] ep21wireOut;
	output [15:0] ep22wireOut, ep23wireOut; 
	output [15:0] ep24wireOut, ep25wireOut, ep26wireOut; 
	output [15:0] ep27wireOut, ep28wireOut, ep29wireOut;
	output [15:0] ep30wireOut;

	/*
		Wires 
	*/
	wire reset, want_at, begin_connection;
	wire user_data_loaded, user_knows_stored, user_data_done;
	wire RFIFO_access, user_received_data, finished_with_RFIFO; 
	wire start_tx, start_rx, tx_done, rx_done;
	wire [1:0] data_select;
	
	parameter TFIFO_end = 13'h000A;
	
	parameter clock_speed = 20'd1000000, baud_rate = 16'd38400;
	wire [9:0] cpd;

	/*
		Assignments
	*/
	assign reset = ep02wireIn[0];
	assign want_at = ep02wireIn[1];
	assign begin_connection = ep02wireIn[2];
	assign user_data_loaded = ep02wireIn[3];
	assign user_knows_stored = ep02wireIn[4];
	assign user_data_done = ep02wireIn[5];
	assign access_RFIFO = ep02wireIn[6];
	assign user_received_data = ep02wireIn[7];
	assign finished_with_RFIFO = ep02wireIn[8];

	assign data_select[0] = 1'b0;
	assign data_select[1] = 1'b0;
	
	assign bt_enable = ~((curr == Idle ) | (curr == Done));
	
	assign cpd = clock_speed / baud_rate;
	
	/*
		FSM wires
	*/
	parameter Idle = 4'b0000, Done = 4'b1111;
	parameter Wait_for_Data = 4'b0001, Load_TFIFO = 4'b0010, Rest_TFIFO = 4'b0011;
	parameter Load_Transmission = 4'b0100, Wait_for_Connection = 4'b0101, Begin_Transmission = 4'b0110, Rest_Transmission = 4'b0111;
	parameter Receive_AT_Response = 4'b1000, Load_RFIFO = 4'b1001, Rest_RFIFO = 4'b1010;
	parameter Wait_for_User_Demand = 4'b1011, Read_RFIFO = 4'b1100, Check_With_User = 4'b1101;
	reg [3:0] curr, next;
	
	parameter Beginning = 2'b00, Found_r = 2'b01, End = 2'b10;
	reg [1:0] c, n;
		
	/*
		Sensor
	*/
	wire [15:0]sensor_data;
	test_sensor_analog fake(.select(data_select), .d_out(sensor_data));
	
	/*
		FIFOs
	*/
	wire [15:0] TFIFO_in, RFIFO_out;
	wire [13:0] TFIFO_rd_count;
	wire [12:0] TFIFO_wr_count, RFIFO_wr_count;
	wire [11:0] RFIFO_rd_count;
	wire [7:0] TFIFO_out, RFIFO_in;
	wire TFIFO_full, TFIFO_empty, TFIFO_wr_en, TFIFO_rd_en;
	wire RFIFO_full, RFIFO_empty, RFIFO_wr_en, RFIFO_rd_en;
	
	mux_2_16bit TFIFO_input(.data0(sensor_data), .data1(ep01wireIn), .sel(want_at), .result(TFIFO_in) );
	
	assign TFIFO_wr_en = (curr == Load_TFIFO);
	assign TFIFO_rd_en = (curr == Load_Transmission);
	assign RFIFO_wr_en = (curr == Load_RFIFO);
	assign RFIFO_rd_en = (curr == Read_RFIFO);
	
	FIFO_8192_16in_8out TFIFO(
		.rst(reset),

		.wr_clk(clock),
		.rd_clk(clock),

		.wr_en(TFIFO_wr_en),
		.rd_en(TFIFO_rd_en),

		.din(TFIFO_in),
		.dout(TFIFO_out),

		.full(TFIFO_full),
		.empty(TFIFO_empty),

		.rd_data_count(TFIFO_rd_count),
		.wr_data_count(TFIFO_wr_count)
	);
	
	FIFO_8192_8in_16out RFIFO(
		.rst(reset),

		.wr_clk(clock),
		.rd_clk(clock),

		.wr_en(RFIFO_wr_en),
		.rd_en(RFIFO_rd_en),

		.din(RFIFO_in),
		.dout(RFIFO_out),

		.full(RFIFO_full),
		.empty(RFIFO_empty),

		.rd_data_count(RFIFO_rd_count),
		.wr_data_count(RFIFO_wr_count)
	);
	
	wire [7:0] check;
	wire l_c, r_c;
	
	assign l_c = (curr == Load_RFIFO);
	assign r_c = ~reset;
	
	register_8bit_enable_async r_check(
		.clk(clock), 
		.resetn(r_c), 
		.enable(l_c), 
		.select(l_c), 
		.d(RFIFO_in), 
		.q(check) 
	);
	
	/*
		Output
	*/
	wire [7:0] temp;
	wire l_t, r_t;
	
	assign l_t = (curr == Load_Transmission);
	assign r_t = ~reset;
	
	register_8bit_enable_async r_temp(
		.clk(clock), 
		.resetn(r_t), 
		.enable(l_t), 
		.select(l_t), 
		.d(TFIFO_out), 
		.q(temp) 
	);
	
	assign start_tx = (curr == Begin_Transmission);
	
	UART_tx tx(
		.clk(clock), 
		.resetn(~reset), 
		.start(start_tx), 
		.cycles_per_databit(cpd), 
		.tx_line(fpga_txd), 
		.tx_data(temp), 
		.tx_done(tx_done)
	);
	
	/*
		Input
	*/
	assign start_rx = (curr == Receive_AT_Response);
	
	UART_rx rx(
		.clk(clock), 
		.resetn(~reset), 
		.start(start_rx), 
		.cycles_per_databit(cpd), 
		.rx_line(fpga_rxd), 
		.rx_data(RFIFO_in), 
		.rx_data_valid(rx_done)
	);
	
	/*
		FSM
	*/
	
	// Loading TFIFO Signals
	wire data_ready, data_complete;
	
	mux_2_1bit m_dr(.data0(1'b1), .data1(user_data_loaded), .sel(want_at), .result(data_ready) );
	
	wire sensor_data_done;
	assign sensor_data_done = (TFIFO_wr_count >= TFIFO_end) ? 1'b1: 1'b0;
	
	mux_2_1bit m_dc(.data0(sensor_data_done), .data1(user_data_done), .sel(want_at), .result(data_complete) );
	
	// Rest_Transmission Signals
	wire i, n_i, all_data_sent, l_r_i, r_r_i;
	
	assign l_r_i = (curr == Rest_Transmission && TFIFO_empty);
	assign r_r_i = ~reset;
	
	full_adder_1bit a_i(.a(i), .b(1'b1), .c_in(1'b0), .c_out(), .s(n_i)); 
	D_FF_Enable_Async r_i(.clk(clock), .resetn(r_r_i), .enable(l_r_i), .d(n_i), .q(i) );
	
	assign all_data_sent = TFIFO_empty & i;
	
	// Rest_RFIFO Signals
	wire is_it_r, is_it_n;
	assign is_it_r = (check == 16'h00e0) ? 1'b1: 1'b0;
	assign is_it_n = (check == 16'h00e0) ? 1'b1: 1'b0;
	
	// Reading RFIFO Signals
	wire data_stored_for_user, data_ready_for_user;
	assign data_stored_for_user = (curr == Rest_TFIFO);
	assign data_ready_for_user = (curr == Check_With_User);
	
	always@(*)
	begin
		case(curr)
			Idle: 
			begin
				if(begin_connection)
					next = Wait_for_Data; 
				else
					next = Idle;
			end
			
			Wait_for_Data: 
			begin
				if(data_ready)
					next = Load_TFIFO;
				else
					next = Wait_for_Data;
			end
			
			Load_TFIFO:
			begin
				next = Rest_TFIFO;
			end
			
			Rest_TFIFO:
			begin
				if(want_at)
				begin
					if(user_knows_stored)
					begin
						if(data_complete)
							next = Load_Transmission;
						else
							next = Wait_for_Data;
					end
					else
						next = Rest_TFIFO;
				end
				else
				begin
					if(data_complete)
						next = Load_Transmission;
					else
						next = Wait_for_Data;
				end
			end
			
			Load_Transmission:
			begin
				if(want_at)
					next = Begin_Transmission;
				else
					next = Wait_for_Connection;
			end
			
			Wait_for_Connection:
			begin
				if(bt_state)
					next = Begin_Transmission;
				else
					next = Wait_for_Connection;
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
				if(all_data_sent)
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
					next = Load_RFIFO;
				else
					next = Receive_AT_Response;
			end
			
			Load_RFIFO:
			begin
				next = Rest_RFIFO;
			end
			
			Rest_RFIFO:
			begin
				if(c == End)
					next = Wait_for_User_Demand;
				else
					next = Receive_AT_Response;
			end
			
			Wait_for_User_Demand:
			begin
				if(access_RFIFO)
					next = Read_RFIFO;
				else
					next = Wait_for_User_Demand;
			end
			
			Read_RFIFO:
			begin
				next = Check_With_User;
			end
			
			Check_With_User:
			begin
				if(user_received_data)
				begin
					if(finished_with_RFIFO)
						next = Done;
					else
						next = Wait_for_User_Demand;
				end
				else
					next = Check_With_User;
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
	
	always@(*)
	begin
		case(c)
			Beginning:
			begin
				if(is_it_r)
					n = Found_r;
				else
					n = Beginning;
			end
			Found_r:
			begin
				if(is_it_n)
					n = End;
				else
					n = Beginning;
			end
			End:
			begin
				if(curr == Wait_for_User_Demand)
					n = Beginning;
				else
					n = End;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset) curr <= Idle; else curr <= next;
		if(reset) c <= Beginning; else c <= n;
	end
	
	/*
		Check Assignments
	*/
	assign ep20wireOut = RFIFO_out;
	
	assign ep21wireOut[0] = curr[0];
	assign ep21wireOut[1] = curr[1];
	assign ep21wireOut[2] = curr[2];
	assign ep21wireOut[3] = curr[3];
	assign ep21wireOut[4] = next[0];
	assign ep21wireOut[5] = next[1];
	assign ep21wireOut[6] = next[2];
	assign ep21wireOut[7] = next[3];
	assign ep21wireOut[8] = c[0];
	assign ep21wireOut[9] = c[1];
	assign ep21wireOut[10] = n[0];
	assign ep21wireOut[11] = n[1];
	assign ep21wireOut[12] = RFIFO_full;
	assign ep21wireOut[13] = RFIFO_empty;
	assign ep21wireOut[14] = RFIFO_wr_en;
	assign ep21wireOut[15] = RFIFO_rd_en;
	
	assign ep22wireOut = ep01wireIn;
	assign ep23wireOut = ep02wireIn;
	
	assign ep24wireOut = TFIFO_out;
	assign ep25wireOut = TFIFO_rd_count;
	assign ep26wireOut = TFIFO_wr_count;
	
	assign ep27wireOut = RFIFO_in;
	assign ep28wireOut = RFIFO_rd_count;
	assign ep29wireOut = RFIFO_wr_count;
	
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer;
	
	assign l_r_timer = (curr == Rest_Transmission);
	assign r_r_timer = ~reset;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign ep30wireOut = timer;
	
endmodule

