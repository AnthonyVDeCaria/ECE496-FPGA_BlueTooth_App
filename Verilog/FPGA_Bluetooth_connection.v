/*
	Anthony De Caria - September 28, 2016

	This module creates a connection between an ion sensor and a Bluetooth module.
	It assumes input and output wires created by Opal Kelly, and the Bluetooth wires can be abstracted.
	
	Algorithm:
		Starting at #Idle
			If we want_at and the user_data_loaded
				Put the user data into AT_FIFO - #Load_AT_FIFO
				Check with the user - #Rest_AT_FIFO
					If the user doesn't know we stored
						Wait for their response (Stay in #Rest_AT_FIFO)
					If they do
						And they're done loading data
							Go to #Load_Transmission
						Otherwise
							Go to #Load_AT_FIFO to store it
			Or If we don't want_at, but the datastream_ready
				Put the data into the UART - #Load_Transmission
				If we are to send
					Send it - #Begin_Transmission
					Once the data is transmitted
						Set a timer - #Rest_Transmission
						If the timer does off
							And we have more data to send
								Go back to #Load_Transmission
							If we don't
								But we wanted AT
									#Receive_AT_Response from the receiver_centre
									Once we have it
										We wait for the user to access_RFIFO - #Wait_for_RFIFO_Request
											When they do
												#Read_RFIFO
												Check with the user - #Rest_RFIFO
												If the user doesn't know we pulled out the data
													Wait for their response (Stay in #Rest_RFIFO)
												If they do
													And they're done getting the data
														Go to #Idle
													Otherwise
														Go to #Wait_for_RFIFO_Request
						If it hasn't yet
							Wait for it (#Rest_Transmission)
				Else
					Go back to #Idle
			Else
				Stay in #Idle
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
	output [15:0] ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut, ep24wireOut; 
	output [15:0] ep25wireOut, ep26wireOut, ep27wireOut, ep28wireOut, ep29wireOut;
	output [15:0] ep30wireOut;
	
	// Sensor
	parameter sensor0 = 16'h4869, sensor1 = 16'h5B5D, sensor2 = 16'h6E49, sensor3 = 16'h3B29;
	parameter sensor4 = 16'h2829, sensor5 = 16'h3725, sensor6 = 16'h780A, sensor7 = 16'h7B2C;
	
	/*
		Wires 
	*/
	// General Wires
	wire reset, want_at, access_datastreams;
	wire user_data_loaded, user_knows_stored, user_data_done;
	wire RFIFO_access, user_received_data, finished_with_RFIFO;
	
	// Flags
	wire ds_sending_flag, at_sending_flag, we_are_sending, have_at_response, uart_timer_done, tx_done;

	// FIFO Wires
	wire [7:0] datastream0, datastream1, datastream2, datastream3, datastream4, datastream5, datastream6, datastream7;
	wire [7:0] at;
	wire [8:0] fifo_state_full, fifo_state_empty, wr_en, rd_en;	
	
	// Datastream Selector Wires
	wire [7:0] datastream;
	wire [7:0] streams_selected;
	wire [3:0] m_datastream_select;
	
	// UART Timer Wires
	wire [9:0] uart_timer, n_uart_timer;
	wire l_r_uart_timer, r_r_uart_timer;
	
	/*
		General Assignments
	*/
	assign reset = ep02wireIn[0];
	assign access_datastreams = ep02wireIn[1];
	assign want_at = ep02wireIn[2];
	assign user_data_loaded = ep02wireIn[3];
	assign user_knows_stored = ep02wireIn[4];
	assign user_data_done = ep02wireIn[5];
	assign access_RFIFO = ep02wireIn[6];
	assign user_received_data = ep02wireIn[7];
	assign finished_with_RFIFO = ep02wireIn[8];
	
	parameter uart_cpd = 10'd11;
	parameter uart_timer_cap = 10'd385;
	parameter ms_timer_cap = 10'd100;
	
	assign bt_break = 1'b1; // Not being used
	
	/*
		FSM Parameters
	*/
	parameter Idle = 4'b0000;
	parameter Load_AT_FIFO = 4'b0010, Rest_AT_FIFO = 4'b0011;
	parameter Load_Transmission = 4'b0100, Begin_Transmission = 4'b0101, Rest_Transmission = 4'b0110;
	parameter Receive_AT_Response = 4'b1000;
	parameter Wait_for_RFIFO_Request = 4'b1101, Read_RFIFO = 4'b1110, Rest_RFIFO = 4'b1111;
	
	reg [3:0] curr, next;
	
	/*
		Output to Bluetooth
	*/
	//	FIFO	
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
	assign rd_en[8] = (curr == Load_Transmission) & want_at;
	
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
		.AT_rd_count(ep28wireOut),
		.AT_wr_count(ep29wireOut),

		.write_enable(wr_en),
		.read_enable(rd_en),
		
		.full_flag(fifo_state_full), 
		.empty_flag(fifo_state_empty)
	);
	
	// Datastream Selector
	wire is_all_at_data_sent;
	assign is_all_at_data_sent = fifo_state_empty[8];
	
	assign ds_sending_flag = access_datastreams; // This should be replaced - it will be from the receiver_centre in the future.
	assign at_sending_flag = ~is_all_at_data_sent;
	
	mux_2_1bit m_sending_flag(.data0(ds_sending_flag), .data1(at_sending_flag), .sel(want_at), .result(we_are_sending) );
	
	assign streams_selected = 8'haa; // Will remove for final integration test
	
	master_switch_ece496 control_valve(
		.clock(clock),
		.resetn(~reset),
		.want_at(want_at),
		.sending_flag(we_are_sending),
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
	
	//	UART Timer
	assign l_r_uart_timer = (curr == Rest_Transmission);
	assign r_r_uart_timer = ~(reset | (curr == Idle) | (curr == Load_Transmission) ) ;
	
	adder_subtractor_10bit a_uart_timer(.a(uart_timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_uart_timer) );
	register_10bit_enable_async r_uart_timer(.clk(clock), .resetn(r_r_uart_timer), .enable(l_r_uart_timer), .select(l_r_uart_timer), .d(n_uart_timer), .q(uart_timer) );
	
	assign uart_timer_done = (uart_timer == uart_timer_cap) ? 1'b1 : 1'b0;

	//	UART
	wire start_tx;
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
	wire RFIFO_rd_en;
	
	assign RFIFO_rd_en = (curr == Read_RFIFO);
	
	receiver_centre Purolator(
		.clock(clock), 
		.reset(reset),

		.cpd(uart_cpd),
		.fpga_rxd(fpga_rxd),
		
		.at_response_flag(have_at_response),
		
		.RFIFO_rd_en(RFIFO_rd_en),
		.RFIFO_out(RFIFO_out), 
		.RFIFO_wr_count(RFIFO_wr_count), 
		.RFIFO_rd_count(RFIFO_rd_count), 
		.RFIFO_full(), 
		.RFIFO_empty(),
		
		.stream_select(),
		.ds_sending_flag(),
		
		.want_at(want_at),
		
		.commands(ep27wireOut[7:0]), .operands(ep27wireOut[15:8])
	);
	
	/*
		FSM
	*/
	// Idle Signals
	wire data_exists, datastream_ready;
	assign data_exists = (fifo_state_empty != 8'hFF) ? 1'b1 : 1'b0;
	assign datastream_ready = ds_sending_flag & data_exists;
	
	// Begin_Transmission Signals
	wire is_bt_done;
	assign is_bt_done = tx_done;
	
	// Rest_Transmission Signals
	wire all_data_sent;
	assign all_data_sent = (fifo_state_empty[7:0] == 9'h1FF) ? 1'b1 : 1'b0;
	
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
				if(we_are_sending)
					next = Begin_Transmission;
				else
					next = Idle;
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
				if(have_at_response)
					next = Wait_for_RFIFO_Request;
				else
					next = Receive_AT_Response;
			end
			
			Wait_for_RFIFO_Request:
			begin
				if(access_RFIFO)
					next = Read_RFIFO;
				else
					next = Wait_for_RFIFO_Request;
			end
			
			Read_RFIFO:
			begin
				next = Rest_RFIFO;
			end
			
			Rest_RFIFO:
			begin
				if(user_received_data)
				begin
					if(finished_with_RFIFO)
						next = Idle;
					else
						next = Wait_for_RFIFO_Request;
				end
				else
					next = Rest_RFIFO;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset) curr <= Idle; else curr <= next;
	end
	
	/*
		WireOut Assignments
	*/
	assign ep20wireOut = RFIFO_out;
	
	assign ep21wireOut[15:13] = 2'b00;
	assign ep21wireOut[12:0] = RFIFO_wr_count[12:0];
	
	assign ep22wireOut[15:12] = 3'b000;
	assign ep22wireOut[11:0] = RFIFO_rd_count[11:0];
	
	assign ep23wireOut = ep01wireIn;
	
	assign ep24wireOut = ep02wireIn;
	
	// User Signals
	wire data_stored_for_user, data_ready_for_user;
	assign data_stored_for_user = (curr == Rest_AT_FIFO);
	assign data_ready_for_user = (curr == Rest_RFIFO);
	
	assign ep25wireOut[0] = curr[0];
	assign ep25wireOut[1] = curr[1];
	assign ep25wireOut[2] = curr[2];
	assign ep25wireOut[3] = curr[3];
	assign ep25wireOut[4] = next[0];
	assign ep25wireOut[5] = next[1];
	assign ep25wireOut[6] = next[2];
	assign ep25wireOut[7] = next[3];
	assign ep25wireOut[8] = data_stored_for_user;
	assign ep25wireOut[9] = data_ready_for_user;
	assign ep25wireOut[15:10] = 6'h00;
	
	assign ep26wireOut[15:12] = m_datastream_select;
	assign ep26wireOut[11:9] = 3'h0;
	assign ep26wireOut[8] = ds_sending_flag;
	assign ep26wireOut[7:0] = datastream;

endmodule

