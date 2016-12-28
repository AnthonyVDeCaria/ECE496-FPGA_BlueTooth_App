/*
	Anthony De Caria - September 28, 2016

	This module creates a connection between an ion sensor and a HC-05 Bluetooth module.
	It assumes input and output wires created by Opal Kelly.
*/

module FPGA_Bluetooth_connection(
		clock, 
		bt_state, bt_break, fpga_txd, fpga_rxd, 
		ep01wireIn, ep02wireIn, 
		ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut, ep24wireOut, 
		ep25wireOut, ep26wireOut, ep27wireOut, ep28wireOut, ep29wireOut,
		ep30wireOut
	);
	
	/*
		I/Os
	*/
	input clock;
	
	//	FPGA
	input fpga_rxd, bt_state;
	output fpga_txd, bt_break;
	
	// OK
	input [15:0] ep01wireIn, ep02wireIn;
	output [15:0] ep20wireOut; 
	output [15:0] ep21wireOut;
	output [15:0] ep22wireOut, ep23wireOut; 
	output [15:0] ep24wireOut, ep25wireOut, ep26wireOut; 
	output [15:0] ep27wireOut, ep28wireOut, ep29wireOut;
	output [15:0] ep30wireOut;
	
	// Sensor

	/*
		Wires 
	*/
	wire reset, want_at;
	wire user_data_loaded, user_knows_stored, user_data_done;
	wire RFIFO_access, user_received_data, finished_with_RFIFO; 
	
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
	
	parameter uart_cpd = 10'd50;
	parameter uart_timer_cap = 10'd12;
	parameter ms_timer_cap = 10'd100;
	
	assign bt_break = 1'b0;
	
	/*
		FSM wires
	*/
	parameter Idle = 4'b0000;
	parameter Load_AT_FIFO = 4'b0001, Rest_AT_FIFO = 4'b0010;
	parameter Load_Transmission = 4'b0011, Wait_for_Connection = 4'b0100, Begin_Transmission = 4'b0101, Rest_Transmission = 4'b0110;
	parameter Receive_AT_Response = 4'b0111;
	parameter Wait_for_User_Demand = 4'b1000, Read_RFIFO = 4'b1001, Check_With_User = 4'b1010;
	
	reg [3:0] curr, next;
	
	/*
		Output to Bluetooth
	*/
//	parameter sensor0 = 16'h4869, sensor1 = 16'h5B5D, sensor2 = 16'h6E49, sensor3 = 16'h3B29;
//	parameter sensor4 = 16'h2829, sensor5 = 16'h3725, sensor6 = 16'h780A, sensor7 = 16'h7B2C;

	parameter sensor0 = 16'h4869, sensor1 = 16'h0000, sensor2 = 16'h6E49, sensor3 = 16'h00FF;
	parameter sensor4 = 16'h2829, sensor5 = 16'hF00F, sensor6 = 16'h780A, sensor7 = 16'hFFFF;
	
	wire [3:0] m_datastream_select;
	wire all_data_sent;
	
	//	FIFO
	wire [7:0] datastream0, datastream1, datastream2, datastream3, datastream4, datastream5, datastream6, datastream7;
	wire [7:0] at;
	wire [8:0] fifo_state_full, fifo_state_empty, wr_en, rd_en;
	
	assign wr_en[0] = ~fifo_state_full[0];
	assign rd_en[0] = (curr == Load_Transmission) & (m_datastream_select == 3'b000);
	
	assign wr_en[1] = ~fifo_state_full[1];
	assign rd_en[1] = (curr == Load_Transmission) & (m_datastream_select == 3'b001);
	
	assign wr_en[2] = ~fifo_state_full[2];
	assign rd_en[2] = (curr == Load_Transmission) & (m_datastream_select == 3'b010);
	
	assign wr_en[3] = ~fifo_state_full[3];
	assign rd_en[3] = (curr == Load_Transmission) & (m_datastream_select == 3'b011);
	
	assign wr_en[4] = ~fifo_state_full[4];
	assign rd_en[4] = (curr == Load_Transmission) & (m_datastream_select == 3'b100);
	
	assign wr_en[5] = ~fifo_state_full[5];
	assign rd_en[5] = (curr == Load_Transmission) & (m_datastream_select == 3'b101);
	
	assign wr_en[6] = ~fifo_state_full[6];
	assign rd_en[6] = (curr == Load_Transmission) & (m_datastream_select == 3'b110);
	
	assign wr_en[7] = ~fifo_state_full[7];
	assign rd_en[7] = (curr == Load_Transmission) & (m_datastream_select == 3'b111);
	
	assign wr_en[8] = (curr == Load_AT_FIFO);
	assign rd_en[8] = (curr == Load_Transmission) & ~bt_state;
	
	FIFO_centre warehouse(
		.read_clock(clock),
		.write_clock(clock),
		.reset(reset),
		
		.DS0_in(sensor0), .DS1_in(sensor1), .DS2_in(sensor2), .DS3_in(sensor3), 
		.DS4_in(sensor4), .DS5_in(sensor5), .DS6_in(sensor6), .DS7_in(sensor7),
		.DS0_out(datastream0), .DS1_out(datastream1), .DS2_out(datastream2), .DS3_out(datastream3), 
		.DS4_out(datastream4), .DS5_out(datastream5), .DS6_out(datastream6), .DS7_out(datastream7),
		.DS0_rd_count(), .DS1_rd_count(), .DS2_rd_count(), .DS3_rd_count(), 
		.DS4_rd_count(), .DS5_rd_count(), .DS6_rd_count(), .DS7_rd_count(),
		.DS0_wr_count(), .DS1_wr_count(), .DS2_wr_count(), .DS3_wr_count(), 
		.DS4_wr_count(), .DS5_wr_count(), .DS6_wr_count(), .DS7_wr_count(),
		
		.AT_in(ep01wireIn),
		.AT_out(at),
		.AT_rd_count(),
		.AT_wr_count(),

		.write_enable(wr_en),
		.read_enable(rd_en),
		
		.full_flag(fifo_state_full), 
		.empty_flag(fifo_state_empty)
	);
	
	// Datastream Selector
	wire [7:0] datastream;
	wire [7:0] streams_selected;
	assign streams_selected = 8'haa;
	
	master_switch_ece496 control_valve(
		.clock(clock),
		.resetn(~reset),
		.bt_state(bt_state),
		.sending_flag(are_we_sending),
		.want_at(want_at),
		.at_complete(all_data_sent),
		.timer_cap(ms_timer_cap),
		.selected_streams(streams_selected),
		.mux_select(m_datastream_select)
	);

	mux_9_8bit m_datastream(
		.data0(datastream0), 
		.data1(datastream1), 
		.data2(datastream2), 
		.data3(datastream3), 
		.data4(datastream4), 
		.data5(datastream5), 
		.data6(datastream6), 
		.data7(datastream7),
		.data8(at),
		.sel(m_datastream_select), 
		.result(datastream) 
	);
	
	//	UART uart_timer
	wire [9:0] uart_timer, n_uart_timer;
	wire l_r_uart_timer, r_r_uart_timer, uart_timer_done;
	
	assign l_r_uart_timer = (curr == Rest_Transmission);
	assign r_r_uart_timer = ~(reset | (curr == Idle) | (curr == Load_Transmission) ) ;
	
	adder_subtractor_10bit a_uart_timer(.a(uart_timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_uart_timer) );
	register_10bit_enable_async r_uart_timer(.clk(clock), .resetn(r_r_uart_timer), .enable(l_r_uart_timer), .select(l_r_uart_timer), .d(n_uart_timer), .q(uart_timer) );
	
	assign uart_timer_done = (uart_timer == uart_timer_cap) ? 1'b1 : 1'b0;

	//	UART
	wire start_tx, tx_done;
	
	assign start_tx = (curr == Begin_Transmission);
	
	UART_tx tx(
		.clk(clock), 
		.resetn(~reset), 
		.start(start_tx), 
		.cycles_per_databit(uart_cpd), 
		.tx_line(fpga_txd), 
		.tx_data(datastream), 
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
	
	assign RFIFO_rd_en = (curr == Read_RFIFO);
	
	wire did_at_finish, are_we_sending;
	
	assign are_we_sending = 1'b1;
	
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
		
		.stream_select(),
		.sending_flag(),
		
		.bt_state(bt_state)
	);
	
	/*
		FSM
	*/
	wire data_exists, datastream_ready;
	assign data_exists = (fifo_state_empty != 9'h1FF) ? 1'b1 : 1'b0;
	assign datastream_ready = are_we_sending & data_exists;
	
	// Begin_Transmission Signals
	wire is_bt_done;
	assign is_bt_done = tx_done;
	
	// Rest_Transmission Signals
	wire all_at_data_sent, all_ds_data_sent;
	assign all_ds_data_sent = (fifo_state_empty[7:0] == 8'hFF) ? 1'b1 : 1'b0;
	assign all_at_data_sent = fifo_state_empty[8];
	assign all_data_sent = all_at_data_sent | all_ds_data_sent;
	
	// User Signals
	wire data_stored_for_user, data_ready_for_user;
	assign data_stored_for_user = (curr == Rest_AT_FIFO);
	assign data_ready_for_user = (curr == Check_With_User);
	
	always@(*)
	begin
		case(curr)
			Idle: 
			begin
				if(want_at)
				begin
					if(user_data_loaded)
						next = Load_AT_FIFO;
					else
						next = Idle;
				end
				else
				begin
					if(datastream_ready)
						next = Load_Transmission;
					else
						next = Idle;
				end
			end
			
			Load_AT_FIFO:
			begin
				next = Rest_AT_FIFO;
			end
			
			Rest_AT_FIFO:
			begin
				if(user_knows_stored)
				begin
					if(user_data_done)
						next = Load_Transmission;
					else
						next = Idle;
				end
				else
					next = Rest_AT_FIFO;
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
					if(are_we_sending)
						next = Begin_Transmission;
					else
						next = Idle;
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
				if(uart_timer_done)
				begin
					if(all_data_sent)
					begin
						if(want_at)
							next = Receive_AT_Response; 
						else
							next = Idle;
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
						next = Idle;
					else
						next = Wait_for_User_Demand;
				end
				else
					next = Check_With_User;
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
	assign ep20wireOut[8] = data_stored_for_user;
	assign ep20wireOut[9] = data_ready_for_user;
	assign ep20wireOut[15:10] = 6'h00;
	
	assign ep21wireOut = ep01wireIn;
	assign ep22wireOut = ep02wireIn;
	
	assign ep23wireOut = m_datastream_select;
	
	assign ep24wireOut = sensor6;
	
	assign ep25wireOut[7:0] = datastream6;
	assign ep25wireOut[15:8] = datastream;
	
	assign ep26wireOut = wr_en;
	assign ep27wireOut = rd_en;
	
endmodule

