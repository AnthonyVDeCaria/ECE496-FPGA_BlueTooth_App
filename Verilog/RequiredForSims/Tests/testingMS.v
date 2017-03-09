`timescale 1us / 1ps

module testingMS;

	// Inputs
	reg clock;
	reg resetn;
	reg [7:0] selected_streams;
	reg [8:0] rd_en;
	
	wire [7:0] empty_fifo_flags, data_exists;
	wire sending_flag, packet_sent;
	assign sending_flag = (empty_fifo_flags != 8'hFF) ? 1'b1 : 1'b0;

	// Outputs
	wire [2:0] mux_select;
	wire select_ready;

	// Instantiate the Unit Under Test (UUT)
	master_switch_ece496 uut(
		.clock(clock), 
		.resetn(resetn),  
		.sending_flag(sending_flag),
		.packet_sent(packet_sent),
		.selected_streams(selected_streams),
		.empty_fifo_flags(empty_fifo_flags),
		.mux_select(mux_select),
		.select_ready(select_ready)
	);
	
	
	/*
		Helpers
	*/
	wire [127:0] sensor_stream0, sensor_stream1, sensor_stream2, sensor_stream3;
	wire [127:0] sensor_stream4, sensor_stream5, sensor_stream6, sensor_stream7;
	wire [109:0] data_out0, data_out1, data_out2, data_out3;
	wire [109:0] data_out4, data_out5, data_out6, data_out7;
    wire [109:0] extracted_data0, extracted_data1, extracted_data2, extracted_data3; 
    wire [109:0] extracted_data4, extracted_data5, extracted_data6, extracted_data7;
    wire [5:0] i0, i1, i2, i3, i4, i5, i6, i7;
	
	DS0 stream0(.index(i0), .data(extracted_data0));
    DS1 stream1(.index(i1), .data(extracted_data1));
    DS2 stream2(.index(i2), .data(extracted_data2));
    DS3 stream3(.index(i3), .data(extracted_data3));
    DS4 stream4(.index(i4), .data(extracted_data4));
    DS5 stream5(.index(i5), .data(extracted_data5));
    DS6 stream6(.index(i6), .data(extracted_data6));
    DS7 stream7(.index(i7), .data(extracted_data7));
	
	ion sensor0(
		.clock(clock),
		.resetn(resetn),
		.ready(data_exists[0]),
		.data_in(extracted_data0),
		.timer_cap0(20'd1000),
		.i0(i0),
		.data_out(data_out0)
	);
	
	ion sensor1(
	   .clock(clock),
       .resetn(resetn),
       .ready(data_exists[1]),
       .data_in(extracted_data1),
       .timer_cap0(20'd10000),
       .i0(i1),
       .data_out(data_out1)
	);
	
	ion sensor2(
        .clock(clock),
        .resetn(resetn),
        .ready(data_exists[2]),
        .data_in(extracted_data2),
        .timer_cap0(20'd1000),
        .i0(i2),
        .data_out(data_out2)
    );
    
    ion sensor3(
        .clock(clock),
        .resetn(resetn),
        .ready(data_exists[3]),
        .data_in(extracted_data3),
        .timer_cap0(20'd1000),
        .i0(i3),
        .data_out(data_out3)
    );
    
    ion sensor4(
        .clock(clock),
        .resetn(resetn),
        .ready(data_exists[4]),
        .data_in(extracted_data4),
        .timer_cap0(20'd1000),
        .i0(i4),
        .data_out(data_out4)
    );
    
    ion sensor5(
        .clock(clock),
        .resetn(resetn),
        .ready(data_exists[5]),
        .data_in(extracted_data5),
        .timer_cap0(20'd1000),
        .i0(i5),
        .data_out(data_out5)
    );
    
    ion sensor6(
        .clock(clock),
        .resetn(resetn),
        .ready(data_exists[6]),
        .data_in(extracted_data6),
        .timer_cap0(20'd1000),
        .i0(i6),
        .data_out(data_out6)
    );
    
    ion sensor7(
        .clock(clock),
        .resetn(resetn),
        .ready(data_exists[7]),
        .data_in(extracted_data7),
        .timer_cap0(20'd1000),
        .i0(i7),
        .data_out(data_out7)
    );
	
	assign sensor_stream0[7:0] = 8'h00;
	assign sensor_stream0[117:8] = data_out0;
	assign sensor_stream0[119:118] = 2'b00;
	assign sensor_stream0[127:120] = 8'h00;
	
	assign sensor_stream1[7:0] = 8'h01;
	assign sensor_stream1[117:8] = data_out1;
	assign sensor_stream1[119:118] = 2'b00;
	assign sensor_stream1[127:120] = 8'h01;
	
	assign sensor_stream2[7:0] = 8'h02;
	assign sensor_stream2[117:8] = data_out2;
	assign sensor_stream2[119:118] = 2'b00;
	assign sensor_stream2[127:120] = 8'h02;
	
	assign sensor_stream3[7:0] = 8'h03;
	assign sensor_stream3[117:8] = data_out3;
	assign sensor_stream3[119:118] = 2'b00;
	assign sensor_stream3[127:120] = 8'h03;
	
	assign sensor_stream4[7:0] = 8'h04;
	assign sensor_stream4[117:8] = data_out4;
	assign sensor_stream4[119:118] = 2'b00;
	assign sensor_stream4[127:120] = 8'h04;
	
	assign sensor_stream5[7:0] = 8'h05;
	assign sensor_stream5[117:8] = data_out5;
	assign sensor_stream5[119:118] = 2'b00;
	assign sensor_stream5[127:120] = 8'h05;
	
	assign sensor_stream6[7:0] = 8'h06;
	assign sensor_stream6[117:8] = data_out6;
	assign sensor_stream6[119:118] = 2'b00;
	assign sensor_stream6[127:120] = 8'h06;
	
	assign sensor_stream7[7:0] = 8'h07;
	assign sensor_stream7[117:8] = data_out7;
	assign sensor_stream7[119:118] = 2'b00;
	assign sensor_stream7[127:120] = 8'h07;
	
	FIFO_centre warehouse(
		.read_clock(clock),
		.write_clock(clock),
		.reset(~resetn),
		
		.DS0_in(sensor_stream0), .DS1_in(sensor_stream1), .DS2_in(sensor_stream2), .DS3_in(sensor_stream3), 
		.DS4_in(sensor_stream4), .DS5_in(sensor_stream5), .DS6_in(sensor_stream6), .DS7_in(sensor_stream7),
		.DS0_out(), .DS1_out(), .DS2_out(), .DS3_out(), 
		.DS4_out(), .DS5_out(), .DS6_out(), .DS7_out(), 
		
		.write_enable(data_exists),
		.read_enable(rd_en),
		
		.full_flag(), 
		.empty_flag(empty_fifo_flags)
	);
	wire [15:0] n_uart_packet_timer, uart_packet_timer;
	wire reset_timer;
	parameter uart_packet_spacing_limit = 16'd20000;
	parameter timer_reset = 16'd20005;
	assign l_r_uart_packet_timer = 1'b1;
	assign r_r_uart_packet_timer = ~(~resetn | (reset_timer)) ;
	
	adder_subtractor_16bit a_uart_packet_timer(.a(uart_packet_timer), .b(16'd1), .want_subtract(1'b0), .c_out(), .s(n_uart_packet_timer) );
	register_16bit_enable_async r_uart_packet_timer(.clk(clock), .resetn(r_r_uart_packet_timer), .enable(l_r_uart_packet_timer), .select(l_r_uart_packet_timer), .d(n_uart_packet_timer), .q(uart_packet_timer) );
	
	assign packet_sent = (uart_packet_timer == uart_packet_spacing_limit) ? 1'b1 : 1'b0;
	assign reset_timer = (uart_packet_timer == timer_reset) ? 1'b1 : 1'b0;
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 1'b0;
		selected_streams = 8'h00;
		rd_en = 8'h00;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 resetn = 1'b1;
		#100 selected_streams = 8'hFF;
		
		#20000 rd_en[0] = 8'h01;
		#20001 rd_en[0] = 8'h00;
	end
	
endmodule

