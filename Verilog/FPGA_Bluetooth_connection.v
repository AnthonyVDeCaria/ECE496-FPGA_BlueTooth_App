/*
	Anthony De Caria - September 28, 2016

	This module creates a connection between an ion sensor_stream and a Bluetooth module.
	It assumes input and output wires created by Opal Kelly, and the Bluetooth wires can be abstracted.
	
	Algorithm:
		Starting at #Idle
			If we want_at and there's user_data_on_line
				Put the user data into AT_FIFO - #Load_AT_FIFO
				Check with the user - #Rest_AT_FIFO
					If the user doesn't know we stored
						Wait for their response (Stay in #Rest_AT_FIFO)
					If they do
						And they're done loading data
							Go to #Wait_for_Clearance
						Otherwise
							Go to #Load_AT_FIFO to store it
			Or If we don't want_at, but the datastream_ready
				Let the Master Switch settle down - #Wait_for_Clearance
				If it is
					Access the Data from the FIFO - #Release_from_FIFO
					If we don't want AT
						Put the packet into the buffer - #Load_Buffer
						Wait for the multiplexer to pick the correct byte - #Rest_byte_i
					Else
						Go to #Send_Byte
					If sending_flag is still active
						Send it - #Send_Byte
						Once the byte is transmitted
							Set a byte timer and a packet timer - #Rest_Transmission
							If we're in DS
								If we haven't sent a full packet
									If the byte timer is done
										Add 1 to byte_i
										Go to #Rest_byte_i
									Else
										Wait for the timer #Rest_Transmission
								Else a packet is through
									If we're done
										Back to #Idle
									Else
										If the packet timer is done
											Wait for the next packet channel to open #Wait_for_Clearance
										Else
											Wait for the packet timer #Rest_Transmission
							If we're in AT
								If we've haven't sent the full command
									If the byte timer is not done
										Wait for it #Rest_Transmission
									Else
										Get the next byte #Release_from_FIFO
								Otherwise
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
									Else
										Go back to #Idle
							Else
								Wait for it (#Rest_Transmission)
					Else
						Go back to #Idle
				Else
					Wait for it (#Wait_for_Clearance)
			Else
				Stay in #Idle
*/

module FPGA_Bluetooth_connection(
		clock, 
		bt_state, fpga_txd, fpga_rxd,
//		sensor_stream0, sensor_stream1, sensor_stream2, sensor_stream3, sensor_stream4, sensor_stream5, sensor_stream6, sensor_stream7,
//		sensor_stream_ready, access_sensor_stream,
		ep01wireIn, ep02wireIn, 
		ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut, ep24wireOut, 
		ep25wireOut, ep26wireOut, ep27wireOut, ep28wireOut, ep29wireOut,
		ep30wireOut,
		uart_cpd, uart_byte_spacing_limit
	);
	
	/*
		I/Os
	*/
	//	FPGA
	input clock;
	input fpga_rxd, bt_state;
	output fpga_txd;
	
	// OK
	input [15:0] ep01wireIn, ep02wireIn;
	output [15:0] ep20wireOut, ep21wireOut, ep22wireOut, ep23wireOut, ep24wireOut; 
	output [15:0] ep25wireOut, ep26wireOut, ep27wireOut, ep28wireOut, ep29wireOut;
	output [15:0] ep30wireOut;
	
	// Sensor
	wire [109:0] sensor_stream0, sensor_stream1, sensor_stream2, sensor_stream3, sensor_stream4, sensor_stream5, sensor_stream6, sensor_stream7; //input
	wire [7:0] sensor_stream_ready; //input
	wire [7:0] access_sensor_stream; //output
	
	// Other
	input [9:0] uart_cpd, uart_byte_spacing_limit;
	
	/*
		Wires 
	*/
	// General Wires
	wire reset, want_at, access_datastreams;
	wire user_data_on_line, user_knows_stored, user_data_done;
	wire RFIFO_access, user_received_data, finished_with_RFIFO;
	
	// Flags
	wire ds_sending_flag, at_sending_flag, sending_flag, have_at_response, uart_byte_timer_done, tx_done, select_ready, command_from_app, packet_sent;

	// Sensor Wires
	wire [127:0] expanded_stream0, expanded_stream1, expanded_stream2, expanded_stream3, expanded_stream4, expanded_stream5, expanded_stream6, expanded_stream7;
	wire [127:0] datastream0, datastream1, datastream2, datastream3, datastream4, datastream5, datastream6, datastream7;
	wire [7:0] at;
	wire [8:0] fifo_state_full, fifo_state_empty, wr_en, rd_en;
	
	// Datastream Selector Wires
	wire [127:0] datastream;
	wire [7:0] bytestream, uart_input;
	wire [7:0] streams_selected;
	wire [2:0] m_datastream_select;
	
	// UART Timer Wires
	wire [15:0] uart_packet_timer, n_uart_packet_timer;
	wire [9:0] uart_byte_timer, n_uart_byte_timer;
	wire l_r_uart_byte_timer, l_r_uart_packet_timer;
	wire r_r_uart_byte_timer, r_r_uart_packet_timer;
	
	/*
		General Assignments
	*/
	assign reset = ep02wireIn[0];
	assign access_datastreams = ep02wireIn[1];
	assign want_at = ep02wireIn[2];
	assign user_data_on_line = ep02wireIn[3];
	assign user_knows_stored = ep02wireIn[4];
	assign user_data_done = ep02wireIn[5];
	assign access_RFIFO = ep02wireIn[6];
	assign user_received_data = ep02wireIn[7];
	assign finished_with_RFIFO = ep02wireIn[8];
	
	/*
		FSM Parameters
	*/
	parameter Idle = 4'b0000;
	parameter Load_AT_FIFO = 4'b0001, Rest_AT_FIFO = 4'b0010;
	parameter Wait_for_Clearance = 4'b0011;
	parameter Release_from_FIFO = 4'b0100;
	parameter Load_Buffer = 4'b0101, Rest_byte_i = 4'b0110;
	parameter Send_Byte = 4'b1000, Rest_Transmission = 4'b1001;
	parameter Receive_AT_Response = 4'b1100, Wait_for_RFIFO_Request = 4'b1101, Read_RFIFO = 4'b1110, Rest_RFIFO = 4'b1111;
	
	reg [3:0] fbc_curr, fbc_next;
	
	/*
		Ion Sensors - to be removed when properly integrated.
	*/
    wire [5:0] i0, i1, i2, i3, i4, i5, i6, i7;
	
	ion sensor0(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[0]),
		.data_valid(sensor_stream_ready[0]),
        .i(i0)
	);
	
	ion sensor1(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[1]),
		.data_valid(sensor_stream_ready[1]),
        .i(i1)
	);
	
	ion sensor2(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[2]),
		.data_valid(sensor_stream_ready[2]),
        .i(i2)
    );
    
    ion sensor3(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[3]),
		.data_valid(sensor_stream_ready[3]),
        .i(i3)
    );
    
    ion sensor4(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[4]),
		.data_valid(sensor_stream_ready[4]),
        .i(i4)
    );
    
    ion sensor5(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[5]),
		.data_valid(sensor_stream_ready[5]),
        .i(i5)
    );
    
    ion sensor6(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[6]),
		.data_valid(sensor_stream_ready[6]),
        .i(i6)
    );
    
    ion sensor7(
        .clock(clock),
        .reset(reset),
		.data_request(access_sensor_stream[7]),
		.data_valid(sensor_stream_ready[7]),
        .i(i7)
    );
	
	DS0 stream0(.index(i0), .data(sensor_stream0));
    DS1 stream1(.index(i1), .data(sensor_stream1));
    DS2 stream2(.index(i2), .data(sensor_stream2));
    DS3 stream3(.index(i3), .data(sensor_stream3));
    DS4 stream4(.index(i4), .data(sensor_stream4));
    DS5 stream5(.index(i5), .data(sensor_stream5));
    DS6 stream6(.index(i6), .data(sensor_stream6));
    DS7 stream7(.index(i7), .data(sensor_stream7));
	
	/*
		Output to Bluetooth
	*/
	// Request the streams
	wire [7:0] start_isr;
	assign start_isr[0] = streams_selected[0] & access_datastreams & command_from_app;
	assign start_isr[1] = streams_selected[1] & access_datastreams & command_from_app;
	assign start_isr[2] = streams_selected[2] & access_datastreams & command_from_app;
	assign start_isr[3] = streams_selected[3] & access_datastreams & command_from_app;
	assign start_isr[4] = streams_selected[4] & access_datastreams & command_from_app;
	assign start_isr[5] = streams_selected[5] & access_datastreams & command_from_app;
	assign start_isr[6] = streams_selected[6] & access_datastreams & command_from_app;
	assign start_isr[7] = streams_selected[7] & access_datastreams & command_from_app;
	ion_sensor_requester gofer(.clock(clock), .resetn(~reset), .stream_active(start_isr), .i_s_request(access_sensor_stream));
	
	// Expand the streams
	assign expanded_stream0[7:0] = 8'h00;
	assign expanded_stream0[117:8] = sensor_stream0;
	assign expanded_stream0[119:118] = 2'b00;
	assign expanded_stream0[127:120] = 8'h00;
	
	assign expanded_stream1[7:0] = 8'h01;
	assign expanded_stream1[117:8] = sensor_stream1;
	assign expanded_stream1[119:118] = 2'b00;
	assign expanded_stream1[127:120] = 8'h01;
	
	assign expanded_stream2[7:0] = 8'h02;
	assign expanded_stream2[117:8] = sensor_stream2;
	assign expanded_stream2[119:118] = 2'b00;
	assign expanded_stream2[127:120] = 8'h02;
	
	assign expanded_stream3[7:0] = 8'h03;
	assign expanded_stream3[117:8] = sensor_stream3;
	assign expanded_stream3[119:118] = 2'b00;
	assign expanded_stream3[127:120] = 8'h03;
	
	assign expanded_stream4[7:0] = 8'h04;
	assign expanded_stream4[117:8] = sensor_stream4;
	assign expanded_stream4[119:118] = 2'b00;
	assign expanded_stream4[127:120] = 8'h04;
	
	assign expanded_stream5[7:0] = 8'h05;
	assign expanded_stream5[117:8] = sensor_stream5;
	assign expanded_stream5[119:118] = 2'b00;
	assign expanded_stream5[127:120] = 8'h05;
	
	assign expanded_stream6[7:0] = 8'h06;
	assign expanded_stream6[117:8] = sensor_stream6;
	assign expanded_stream6[119:118] = 2'b00;
	assign expanded_stream6[127:120] = 8'h06;
	
	assign expanded_stream7[7:0] = 8'h07;
	assign expanded_stream7[117:8] = sensor_stream7;
	assign expanded_stream7[119:118] = 2'b00;
	assign expanded_stream7[127:120] = 8'h07;
	
	//	FIFO	
	assign wr_en[0] = ~fifo_state_full[0] & sensor_stream_ready[0];
	assign rd_en[0] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b000);
	
	assign wr_en[1] = ~fifo_state_full[1] & sensor_stream_ready[1];
	assign rd_en[1] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b001);
	
	assign wr_en[2] = ~fifo_state_full[2] & sensor_stream_ready[2];
	assign rd_en[2] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b010);
	
	assign wr_en[3] = ~fifo_state_full[3] & sensor_stream_ready[3];
	assign rd_en[3] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b011);
	
	assign wr_en[4] = ~fifo_state_full[4] & sensor_stream_ready[4];
	assign rd_en[4] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b100);
	
	assign wr_en[5] = ~fifo_state_full[5] & sensor_stream_ready[5];
	assign rd_en[5] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b101);
	
	assign wr_en[6] = ~fifo_state_full[6] & sensor_stream_ready[6];
	assign rd_en[6] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b110);
	
	assign wr_en[7] = ~fifo_state_full[7] & sensor_stream_ready[7];
	assign rd_en[7] = (fbc_curr == Release_from_FIFO) & (m_datastream_select == 3'b111);
	
	assign wr_en[8] = (fbc_curr == Load_AT_FIFO);
	assign rd_en[8] = (fbc_curr == Release_from_FIFO) & want_at;
	
	FIFO_centre warehouse(
		.read_clock(clock),
		.write_clock(clock),
		.reset(reset),
		
		.DS0_in(expanded_stream0), .DS1_in(expanded_stream1), .DS2_in(expanded_stream2), .DS3_in(expanded_stream3), 
		.DS4_in(expanded_stream4), .DS5_in(expanded_stream5), .DS6_in(expanded_stream6), .DS7_in(expanded_stream7),
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
	wire all_at_data_sent, ds_data_exists;
	assign all_at_data_sent = fifo_state_empty[8];
	assign ds_data_exists = (fifo_state_empty[7:0] != 8'hFF) ? 1'b1 : 1'b0;
	
	wire [15:0] packet_counter, n_packet_counter;
	wire l_r_packet_counter, r_r_packet_counter, packet_counter_done;
	parameter packet_count_limit = 16'd14400;
	assign l_r_packet_counter = ~want_at & packet_sent & uart_packet_timer_done;
	assign r_r_packet_counter = ~(reset);
	adder_subtractor_16bit a_packet_counter(.a(packet_counter), .b(16'd1), .want_subtract(1'b0), .c_out(), .s(n_packet_counter) );
	register_16bit_enable_async r_packet_counter(.clk(clock), .resetn(r_r_packet_counter), .enable(l_r_packet_counter), .select(l_r_packet_counter), .d(n_packet_counter), .q(packet_counter) );
	assign packet_counter_done = (packet_counter == packet_count_limit) ? 1'b1 : 1'b0;
	assign ds_sending_flag = access_datastreams & command_from_app & ds_data_exists & ~packet_counter_done;
	
	//assign ds_sending_flag = access_datastreams & command_from_app & ds_data_exists;
	assign at_sending_flag = ~all_at_data_sent;
	
	mux_2_1bit m_sending_flag(.data0(ds_sending_flag), .data1(at_sending_flag), .sel(want_at), .result(sending_flag) );
	
	master_switch_ece496 control_valve(
		.clock(clock),
		.resetn(~reset),
		.sending_flag(sending_flag),
		.packet_sent(packet_sent),
		.ready_to_send((fbc_curr == Wait_for_Clearance)),
		.selected_streams(streams_selected),
		.empty_fifo_flags(fifo_state_empty[7:0]),
		.mux_select(m_datastream_select),
		.select_ready(select_ready)
	);

	mux_8_128bit m_datastream(
		.data0(datastream0), 
		.data1(datastream1), 
		.data2(datastream2), 
		.data3(datastream3), 
		.data4(datastream4), 
		.data5(datastream5), 
		.data6(datastream6), 
		.data7(datastream7),
		.sel(m_datastream_select), 
		.result(datastream) 
	);
	
	wire [7:0] datastream_byte_0, datastream_byte_1, datastream_byte_2, datastream_byte_3;
	wire [7:0] datastream_byte_4, datastream_byte_5, datastream_byte_6, datastream_byte_7;
	wire [7:0] datastream_byte_8, datastream_byte_9, datastream_byte_10, datastream_byte_11;
	wire [7:0] datastream_byte_12, datastream_byte_13, datastream_byte_14, datastream_byte_15;
	
	wire l_r_datastream, r_r_datastream;
	assign l_r_datastream = (fbc_curr == Load_Buffer);
	assign r_r_datastream = ~(reset | (fbc_curr == Wait_for_Clearance));
	
	register_8bit_enable_async r_datastream_byte_0(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[127:120]), .q(datastream_byte_0) 
	);
	register_8bit_enable_async r_datastream_byte_1(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[119:112]), .q(datastream_byte_1) 
	);
	register_8bit_enable_async r_datastream_byte_2(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[111:104]), .q(datastream_byte_2) 
	);
	register_8bit_enable_async r_datastream_byte_3(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[103:96]), .q(datastream_byte_3) 
	);
	register_8bit_enable_async r_datastream_byte_4(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[95:88]), .q(datastream_byte_4) 
	);
	register_8bit_enable_async r_datastream_byte_5(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[87:80]), .q(datastream_byte_5)
	);
	register_8bit_enable_async r_datastream_byte_6(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[79:72]), .q(datastream_byte_6) 
	);
	register_8bit_enable_async r_datastream_byte_7(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[71:64]), .q(datastream_byte_7) 
	);
	register_8bit_enable_async r_datastream_byte_8(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[63:56]), .q(datastream_byte_8) 
	);
	register_8bit_enable_async r_datastream_byte_9(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[55:48]), .q(datastream_byte_9) 
	);
	register_8bit_enable_async r_datastream_byte_10(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[47:40]), .q(datastream_byte_10) 
	);
	register_8bit_enable_async r_datastream_byte_11(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[39:32]), .q(datastream_byte_11) 
	);
	register_8bit_enable_async r_datastream_byte_12(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[31:24]), .q(datastream_byte_12) 
	);
	register_8bit_enable_async r_datastream_byte_13(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[23:16]), .q(datastream_byte_13)
	);
	register_8bit_enable_async r_datastream_byte_14(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream), 
		.d(datastream[15:8]), .q(datastream_byte_14) 
	);
	register_8bit_enable_async r_datastream_byte_15(
		.clk(clock), .resetn(r_r_datastream), .enable(l_r_datastream), .select(l_r_datastream),
		.d(datastream[7:0]), .q(datastream_byte_15) 
	);
	
	wire[3:0] n_byte_i, byte_i;
	wire l_r_byte_i, r_r_byte_i;
	
	assign l_r_byte_i = ~want_at & ~packet_sent & uart_byte_timer_done & (fbc_curr == Rest_Transmission);
	assign r_r_byte_i = ~(reset | (fbc_curr == Wait_for_Clearance));
	
	adder_subtractor_4bit a_byte_i(.a(byte_i), .b(4'd1), .want_subtract(1'b0), .c_out(), .s(n_byte_i) );
	register_4bit_enable_async r_byte_i(.clk(clock), .resetn(r_r_byte_i), .enable(l_r_byte_i), .select(l_r_byte_i), .d(n_byte_i), .q(byte_i) );
	
	assign packet_sent = (byte_i == 4'b1111) ? 1'b1 : 1'b0;
	
	mux_16_8bit m_bytestream(
		.data0(datastream_byte_0), .data1(datastream_byte_1), .data2(datastream_byte_2), .data3(datastream_byte_3),
		.data4(datastream_byte_4), .data5(datastream_byte_5), .data6(datastream_byte_6), .data7(datastream_byte_7),
		.data8(datastream_byte_8), .data9(datastream_byte_9), .data10(datastream_byte_10), .data11(datastream_byte_11),
		.data12(datastream_byte_12), .data13(datastream_byte_13), .data14(datastream_byte_14), .data15(datastream_byte_15),
		.sel(byte_i), 
		.result(bytestream)
	);
		
	mux_2_8bit m_uart_select(.data0(bytestream), .data1(at), .sel(want_at), .result(uart_input) );
	
	//	UART Byte Timer
	assign l_r_uart_byte_timer = (fbc_curr == Rest_Transmission);
	assign r_r_uart_byte_timer = ~(reset | (fbc_curr == Idle) | (fbc_curr == Release_from_FIFO) | (fbc_curr == Send_Byte) ) ;
	
	adder_subtractor_10bit a_uart_byte_timer(.a(uart_byte_timer), .b(10'd1), .want_subtract(1'b0), .c_out(), .s(n_uart_byte_timer) );
	register_10bit_enable_async r_uart_byte_timer(.clk(clock), .resetn(r_r_uart_byte_timer), .enable(l_r_uart_byte_timer), .select(l_r_uart_byte_timer), .d(n_uart_byte_timer), .q(uart_byte_timer) );
	
	assign uart_byte_timer_done = (uart_byte_timer == uart_byte_spacing_limit) ? 1'b1 : 1'b0;
	
	//	UART Packet Timer
	parameter uart_packet_spacing_limit = 16'd6000;
	assign l_r_uart_packet_timer = ~want_at & packet_sent & (fbc_curr == Rest_Transmission);
	assign r_r_uart_packet_timer = ~(reset | (fbc_curr == Idle) | (fbc_curr == Release_from_FIFO) ) ;
	
	adder_subtractor_16bit a_uart_packet_timer(.a(uart_packet_timer), .b(16'd1), .want_subtract(1'b0), .c_out(), .s(n_uart_packet_timer) );
	register_16bit_enable_async r_uart_packet_timer(.clk(clock), .resetn(r_r_uart_packet_timer), .enable(l_r_uart_packet_timer), .select(l_r_uart_packet_timer), .d(n_uart_packet_timer), .q(uart_packet_timer) );
	
	assign uart_packet_timer_done = (uart_packet_timer == uart_packet_spacing_limit) ? 1'b1 : 1'b0;
	
	//	UART
	wire start_tx;
	assign start_tx = (fbc_curr == Send_Byte);
	
	UART_tx tx(
		.clk(clock), 
		.resetn(~reset), 
		.start(start_tx), 
		.cycles_per_databit(uart_cpd), 
		.tx_line(fpga_txd), 
		.tx_data(uart_input), 
		.tx_done(tx_done)
	);
	
	/*
		Input from Bluetooth
	*/	
	wire [15:0] RFIFO_out;
	wire [7:0] RFIFO_wr_count;
	wire [6:0] RFIFO_rd_count;
	wire RFIFO_rd_en;
	
	wire at_command_sent;
	
	assign RFIFO_rd_en = (fbc_curr == Read_RFIFO);
	assign at_command_sent = want_at & all_data_sent & (fbc_curr == Rest_Transmission) ;
	
	receiver_centre Purolator(
		.commands(ep27wireOut[15:8]),
		.operands(ep27wireOut[7:0]),
	
		.clock(clock), 
		.reset(reset),
		.fpga_rxd(fpga_rxd),
		
		.want_at(want_at),
		.at_command_sent(at_command_sent),

		.uart_cpd(uart_cpd),
		.uart_byte_spacing(uart_byte_spacing_limit),
		
		.at_response_flag(have_at_response),
		.RFIFO_rd_en(RFIFO_rd_en),
		.RFIFO_out(RFIFO_out), 
		.RFIFO_wr_count(RFIFO_wr_count), 
		.RFIFO_rd_count(RFIFO_rd_count), 
		.RFIFO_full(), 
		.RFIFO_empty(),
		
		.stream_select(streams_selected),
		.ds_sending_flag(command_from_app)
	);
	
	/*
		FSM
	*/
	// Rest_Transmission Signals
	wire all_data_sent;
	mux_2_1bit m_all_data_sent(.data0(~ds_data_exists), .data1(all_at_data_sent), .sel(want_at), .result(all_data_sent) );
	
	always@(*)
	begin
		case(fbc_curr)
			Idle:
			begin
				if(want_at)
				begin
					if(user_data_on_line)
						fbc_next = Load_AT_FIFO;
					else
						fbc_next = Idle;
				end
				else
				begin
					if(ds_sending_flag)
						fbc_next = Wait_for_Clearance;
					else
						fbc_next = Idle;
				end
			end
			
			Load_AT_FIFO:
			begin
				fbc_next = Rest_AT_FIFO;
			end
			
			Rest_AT_FIFO:
			begin
				if(user_knows_stored)
				begin
					if(user_data_done)
						fbc_next = Wait_for_Clearance;
					else
						fbc_next = Idle;
				end
				else
					fbc_next = Rest_AT_FIFO;
			end
			
			Wait_for_Clearance:
			begin
				if(!sending_flag)
					fbc_next = Idle;
				else
				begin
					if(!want_at)
					begin
						if(select_ready)
							fbc_next = Release_from_FIFO;
						else
							fbc_next = Wait_for_Clearance;
					end
					else
						fbc_next = Release_from_FIFO;
				end
			end
			
			Release_from_FIFO:
			begin
				if(want_at)
					fbc_next = Send_Byte;
				else
					fbc_next = Load_Buffer;
			end
			
			Load_Buffer:
			begin
				fbc_next = Rest_byte_i;
			end
			
			Rest_byte_i:
			begin
				fbc_next = Send_Byte;
			end
			
			Send_Byte:
			begin
				if(tx_done)
					fbc_next = Rest_Transmission;
				else
					fbc_next = Send_Byte;
			end
			
			Rest_Transmission:
			begin
				if(!want_at)
				begin
					if(!packet_sent)
					begin
						if(uart_byte_timer_done)
							fbc_next = Rest_byte_i;
						else
							fbc_next = Rest_Transmission;
					end
					else
					begin
						if(all_data_sent)
							fbc_next = Idle;
						else
						begin
							if(uart_packet_timer_done)
								fbc_next = Wait_for_Clearance;
							else
								fbc_next = Rest_Transmission;
						end
					end
				end
				else
				begin
					if(all_data_sent)
						fbc_next = Receive_AT_Response; 
					else
					begin
						if(uart_byte_timer_done)
							fbc_next = Release_from_FIFO;
						else
							fbc_next = Rest_Transmission;
					end
				end
			end
			
			Receive_AT_Response:
			begin
				if(have_at_response)
					fbc_next = Wait_for_RFIFO_Request;
				else
					fbc_next = Receive_AT_Response;
			end
			
			Wait_for_RFIFO_Request:
			begin
				if(access_RFIFO)
					fbc_next = Read_RFIFO;
				else
					fbc_next = Wait_for_RFIFO_Request;
			end
			
			Read_RFIFO:
			begin
				fbc_next = Rest_RFIFO;
			end
			
			Rest_RFIFO:
			begin
				if(user_received_data)
				begin
					if(finished_with_RFIFO)
						fbc_next = Idle;
					else
						fbc_next = Wait_for_RFIFO_Request;
				end
				else
					fbc_next = Rest_RFIFO;
			end
			
			default:
			begin
				fbc_next = Idle;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			fbc_curr <= Idle;
		end
		else
		begin
			fbc_curr <= fbc_next;
		end
	end
	
	/*
		WireOut Assignments
	*/
	assign ep20wireOut = RFIFO_out;
	
	assign ep21wireOut[15:8] = 8'h00;
	assign ep21wireOut[7:0] = RFIFO_wr_count[7:0];
	
	assign ep22wireOut[15:7] = 9'h000;
	assign ep22wireOut[6:0] = RFIFO_rd_count[6:0];
	
	assign ep23wireOut = ep01wireIn;
	
	assign ep24wireOut = ep02wireIn;
	
	// User Signals
	wire data_stored_for_user, data_ready_for_user;
	assign data_stored_for_user = (fbc_curr == Rest_AT_FIFO);
	assign data_ready_for_user = (fbc_curr == Rest_RFIFO);
	
	assign ep25wireOut[0] = fbc_curr[0];
	assign ep25wireOut[1] = fbc_curr[1];
	assign ep25wireOut[2] = fbc_curr[2];
	assign ep25wireOut[3] = fbc_curr[3];
	assign ep25wireOut[4] = fbc_next[0];
	assign ep25wireOut[5] = fbc_next[1];
	assign ep25wireOut[6] = fbc_next[2];
	assign ep25wireOut[7] = fbc_next[3];
	assign ep25wireOut[8] = data_stored_for_user;
	assign ep25wireOut[9] = data_ready_for_user;
	assign ep25wireOut[15:10] = 6'd0;
	
	assign ep26wireOut[15] = 1'b0;
	assign ep26wireOut[14:12] = m_datastream_select;
	assign ep26wireOut[11:10] = rd_en[1:0];
	assign ep26wireOut[9:6] = 0;
	assign ep26wireOut[5] = uart_packet_timer_done;
	assign ep26wireOut[4] = packet_sent;
	assign ep26wireOut[3] = ds_data_exists;
	assign ep26wireOut[2] = command_from_app;
	assign ep26wireOut[1] = access_datastreams;
	assign ep26wireOut[0] = ds_sending_flag;

	assign ep28wireOut[7:0] = 8'd0;
	assign ep28wireOut[15:8] = uart_input;
	
	assign ep29wireOut[7:0] = sensor_stream_ready;
	assign ep29wireOut[15:8] = fifo_state_empty[7:0];
	
	assign ep30wireOut = packet_counter;

endmodule

