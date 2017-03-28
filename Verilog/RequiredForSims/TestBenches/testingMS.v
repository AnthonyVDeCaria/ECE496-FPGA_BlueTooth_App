`timescale 1us / 1ps

module testingMS;

	// Inputs
	reg clock;
	reg resetn;
	reg packet_sent, ready_to_send;
	reg [7:0] selected_streams;
	reg access_datastreams, command_from_app;
	
	wire [8:0] wr_en, rd_en, empty_fifo_flags, fifo_state_full;
	assign wr_en[8] = 1'b0;
	assign rd_en[8] = 1'b0;
	wire [7:0] access_sensor_stream, sensor_stream_ready, ds_empty_flags;
	wire sending_flag;
	assign ds_empty_flags[7:0] = empty_fifo_flags[7:0];
	assign sending_flag = (ds_empty_flags != 8'hFF) ? 1'b1 : 1'b0;

	// Outputs
	wire [2:0] mux_select;
	wire select_ready;

	// Instantiate the Unit Under Test (UUT)
	master_switch_ece496 uut(
		.clock(clock), 
		.resetn(resetn),  
		.sending_flag(sending_flag),
		.packet_sent(packet_sent),
		.ready_to_send(ready_to_send),
		.selected_streams(selected_streams),
		.empty_fifo_flags(ds_empty_flags),
		.mux_select(mux_select),
		.select_ready(select_ready)
	);
	
	/*
		Helpers
	*/
	wire [109:0] sensor_stream0, sensor_stream1, sensor_stream2, sensor_stream3, sensor_stream4, sensor_stream5, sensor_stream6, sensor_stream7;
	wire [127:0] expanded_stream0, expanded_stream1, expanded_stream2, expanded_stream3, expanded_stream4, expanded_stream5, expanded_stream6, expanded_stream7;
    wire [5:0] i0, i1, i2, i3, i4, i5, i6, i7;
	ion sensor0(
        .clock(clock),
        .reset(~resetn),
		.data_request(access_sensor_stream[0]),
		.data_valid(sensor_stream_ready[0]),
        .i(i0)
	);
	ion sensor1(
        .clock(clock),
        .reset(~resetn),
		.data_request(access_sensor_stream[1]),
		.data_valid(sensor_stream_ready[1]),
        .i(i1)
	);
	ion sensor2(
        .clock(clock),
        .reset(~resetn),
		.data_request(access_sensor_stream[2]),
		.data_valid(sensor_stream_ready[2]),
        .i(i2)
    );
    ion sensor3(
        .clock(clock),
        .reset(~resetn),
		.data_request(access_sensor_stream[3]),
		.data_valid(sensor_stream_ready[3]),
        .i(i3)
    );
    ion sensor4(
        .clock(clock),
        .reset(~resetn),
		.data_request(access_sensor_stream[4]),
		.data_valid(sensor_stream_ready[4]),
        .i(i4)
    );
    ion sensor5(
        .clock(clock),
        .reset(~resetn),
		.data_request(access_sensor_stream[5]),
		.data_valid(sensor_stream_ready[5]),
        .i(i5)
    );
    ion sensor6(
        .clock(clock),
        .reset(~resetn),
		.data_request(access_sensor_stream[6]),
		.data_valid(sensor_stream_ready[6]),
        .i(i6)
    );
    ion sensor7(
        .clock(clock),
        .reset(~resetn),
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
	wire [7:0] start_isr;
	assign start_isr[0] = selected_streams[0] & access_datastreams & command_from_app;
	assign start_isr[1] = selected_streams[1] & access_datastreams & command_from_app;
	assign start_isr[2] = selected_streams[2] & access_datastreams & command_from_app;
	assign start_isr[3] = selected_streams[3] & access_datastreams & command_from_app;
	assign start_isr[4] = selected_streams[4] & access_datastreams & command_from_app;
	assign start_isr[5] = selected_streams[5] & access_datastreams & command_from_app;
	assign start_isr[6] = selected_streams[6] & access_datastreams & command_from_app;
	assign start_isr[7] = selected_streams[7] & access_datastreams & command_from_app;
	ion_sensor_requester gofer(.clock(clock), .resetn(resetn), .stream_active(start_isr), .i_s_request(access_sensor_stream));
	
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
	
	assign wr_en[0] = ~fifo_state_full[0] & sensor_stream_ready[0];
	assign rd_en[0] = mux_select == 3'b000;
	
	assign wr_en[1] = ~fifo_state_full[1] & sensor_stream_ready[1];
	assign rd_en[1] = mux_select == 3'b001;
	
	assign wr_en[2] = ~fifo_state_full[2] & sensor_stream_ready[2];
	assign rd_en[2] = mux_select == 3'b010;
	
	assign wr_en[3] = ~fifo_state_full[3] & sensor_stream_ready[3];
	assign rd_en[3] = mux_select == 3'b011;
	
	assign wr_en[4] = ~fifo_state_full[4] & sensor_stream_ready[4];
	assign rd_en[4] = mux_select == 3'b100;
	
	assign wr_en[5] = ~fifo_state_full[5] & sensor_stream_ready[5];
	assign rd_en[5] = mux_select == 3'b101;
	
	assign wr_en[6] = ~fifo_state_full[6] & sensor_stream_ready[6];
	assign rd_en[6] = mux_select == 3'b110;
	
	assign wr_en[7] = ~fifo_state_full[7] & sensor_stream_ready[7];
	assign rd_en[7] = mux_select == 3'b111;
	
	FIFO_centre warehouse(
		.read_clock(clock),
		.write_clock(clock),
		.reset(~resetn),
		
		.DS0_in(expanded_stream0), .DS1_in(expanded_stream1), .DS2_in(expanded_stream2), .DS3_in(expanded_stream3), 
		.DS4_in(expanded_stream4), .DS5_in(expanded_stream5), .DS6_in(expanded_stream6), .DS7_in(expanded_stream7),
		.DS0_out(), .DS1_out(), .DS2_out(), .DS3_out(), 
		.DS4_out(), .DS5_out(), .DS6_out(), .DS7_out(), 
		
		.write_enable(wr_en),
		.read_enable(rd_en),
		
		.full_flag(fifo_state_full), 
		.empty_flag(empty_fifo_flags)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 1'b0;
		selected_streams = 8'h00;
		access_datastreams = 0;
		command_from_app = 0;
		packet_sent = 0;
		ready_to_send = 0;
		
		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 resetn = 1'b1;
		#100 selected_streams = 8'hFF;
		#100 access_datastreams = 1'b1;
		#200 command_from_app = 1'b1;
		#225 ready_to_send = 1'b1;
		
		#3000 packet_sent = 1'b1;
		#1000 ready_to_send = 1'b0;
		
		#6000 packet_sent = 1'b0;
		#6005 ready_to_send = 1'b1;
		
		#9000 packet_sent = 1'b1;
		#8000 ready_to_send = 1'b0;
		
		#12000 packet_sent = 1'b0;
		#12005 ready_to_send = 1'b1;
		
		#15000 packet_sent = 1'b1;
		#14000 ready_to_send = 1'b0;
	end
endmodule

