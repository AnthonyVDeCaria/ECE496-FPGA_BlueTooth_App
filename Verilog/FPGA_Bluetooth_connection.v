/*
	Anthony De Caria - September 28, 2016

	This module creates a connection between an ion sensor and a HC-05 Bluetooth module.
	It assumes input and output wires created by Opal Kelly.
*/

module FPGA_Bluetooth_connection(
		clock, 
		bt_state, bt_break, fpga_txd, fpga_rxd, 
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
	output fpga_txd, bt_break;

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
	
	parameter uart_cpd = 10'd11;
	
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
	
	/*
		FSM wires
	*/
	parameter Idle = 4'b0000, Done = 4'b1111;
	parameter Wait_for_Data = 4'b0001, Load_TFIFO = 4'b0010, Rest_TFIFO = 4'b0011;
	parameter Load_Transmission = 4'b0100, Wait_for_Connection = 4'b0101, Begin_Transmission = 4'b0110, Rest_Transmission = 4'b0111;
	parameter Receive_AT_Response = 4'b1000;
	parameter Wait_for_User_Demand = 4'b1011, Read_RFIFO = 4'b1100, Check_With_User = 4'b1101;
	
	reg [3:0] curr, next;
		
	/*
		Sensor
	*/
	parameter datastream0 = 16'h4869, datastream1 = 16'h5B5D, datastream2 = 16'h6E49, datastream3 = 16'h3B29;
	parameter datastream4 = 16'h2829, datastream5 = 16'h3725, datastream6 = 16'h780A, datastream7 = 16'h7B2C;

	/*
		Output to Bluetooth
	*/
	//	Timer
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (curr == Rest_Transmission);
	assign r_r_timer = ~(reset | (curr == Idle) | (curr == Load_Transmission) ) ;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	parameter timer_cap = 10'd385;
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;
	
	// Selecting datastream
	wire [15:0] datastream;
	wire [7:0] m_datastream_select;
	wire [3:0] datastream_select;
	
	master_switchece496 control_valve(
		.bt_state(bt_state),
		.timer_cap(timer_cap),
		.open_streams(m_datastream_select),
		.next_sel(datastream_select)
	);

	mux_9_16bit m_datastream(
		.data0(datastream0), 
		.data1(datastream1), 
		.data2(datastream2), 
		.data3(datastream3), 
		.data4(datastream4), 
		.data5(datastream5), 
		.data6(datastream6), 
		.data7(datastream7),
		.data8(ep01wireIn),
		.sel(datastream_select), 
		.result(datastream) 
	);
	
	//	FIFO
	wire [15:0] TFIFO_in;
	wire [13:0] TFIFO_rd_count;
	wire [12:0] TFIFO_wr_count;
	wire [7:0] TFIFO_out;
	wire TFIFO_full, TFIFO_empty, TFIFO_wr_en, TFIFO_rd_en;
	
	assign TFIFO_wr_en = (curr == Load_TFIFO);
	assign TFIFO_rd_en = (curr == Load_Transmission);
	
	assign TFIFO_in = datastream;
	
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

	//	UART
	wire start_tx, tx_done;
	
	assign start_tx = (curr == Begin_Transmission);
	
	UART_tx tx(
		.clk(clock), 
		.resetn(~reset), 
		.start(start_tx), 
		.cycles_per_databit(uart_cpd), 
		.tx_line(fpga_txd), 
		.tx_data(TFIFO_out), 
		.tx_done(tx_done)
	);
	
	/*
		Input from Bluetooth
	*/	
	wire [15:0] RFIFO_out;
	wire [12:0] RFIFO_wr_count;
	wire [11:0] RFIFO_rd_count;
	wire [7:0] RFIFO_in;
	wire RFIFO_full, RFIFO_empty, RFIFO_rd_en;
	wire did_at_finish, sending_flag;
	
	assign RFIFO_rd_en = (curr == Read_RFIFO);
	
	receiver_centre Purolator(
		.clock(clock), 
		.reset(reset),

		.cpd(uart_cpd),
		.fpga_rxd(fpga_rxd),
		
		.at_complete(did_at_finish),
		
		.RFIFO_rd_en(RFIFO_rd_en),
		.RFIFO_out(RFIFO_out), 
		.RFIFO_wr_count(RFIFO_wr_count), 
		.RFIFO_rd_count(RFIFO_rd_count), 
		.RFIFO_full(RFIFO_full), 
		.RFIFO_empty(RFIFO_empty),
		
		.stream_select(m_datastream_select),
		.are_we_sending(sending_flag),
		
		.bt_state(bt_state)
	);
	
	/*
		FSM
	*/
	
	// Loading TFIFO Signals
	wire data_ready, data_complete;
	
	mux_2_1bit m_dr(.data0(1'b1), .data1(user_data_loaded), .sel(want_at), .result(data_ready) );
	
	wire sensor_data_done;
	assign sensor_data_done = 1'b1;
	
	mux_2_1bit m_dc(.data0(sensor_data_done), .data1(user_data_done), .sel(want_at), .result(data_complete) );
	
	// Begin_Transmission Signals
	wire is_bt_done;
	assign is_bt_done = tx_done;
	
	// Rest_Transmission Signals
	wire i, n_i, l_r_i, r_r_i;
	
	assign l_r_i = (curr == Rest_Transmission) & TFIFO_empty;
	assign r_r_i = ~reset;
	
	full_adder_1bit a_i(.a(i), .b(1'b1), .c_in(1'b0), .c_out(), .s(n_i)); 
	D_FF_Enable_Async r_i(.clk(clock), .resetn(r_r_i), .enable(l_r_i), .d(n_i), .q(i) );
	
	wire all_data_sent;
	assign all_data_sent = TFIFO_empty & i;
	
	// User Signals
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
				begin
					if(sending_flag)
						next = Begin_Transmission;
					else
						next = Wait_for_Connection;
				end
				else
					next = Wait_for_Connection;
			end
			
			Begin_Transmission:
			begin
				if(is_bt_done)
					next = Rest_Transmission;
				else
					next = Begin_Transmission;
			end
			
			Rest_Transmission:
			begin
				if(timer_done)
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
				else
					next = Rest_Transmission;
			end
			
			Receive_AT_Response:
			begin
				if(did_at_finish)
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
	
	always@(posedge clock or posedge reset)
	begin
		if(reset) curr <= Idle; else curr <= next;
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
	assign ep21wireOut[8] = data_stored_for_user;
	assign ep21wireOut[9] = data_ready_for_user;
	assign ep21wireOut[15:10] = 6'h00;
	
	assign ep22wireOut = ep01wireIn;
	assign ep23wireOut = ep02wireIn;
	
	assign ep24wireOut = TFIFO_out;
	assign ep25wireOut = TFIFO_rd_count;
	assign ep26wireOut = TFIFO_wr_count;
	
	assign ep27wireOut = RFIFO_out;
	assign ep28wireOut = RFIFO_rd_count;
	assign ep29wireOut = RFIFO_wr_count;
	
endmodule

