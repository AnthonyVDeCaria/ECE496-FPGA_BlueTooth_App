/*
	Ming Chen Hsu Jan 20th 
	Ion sensor simulator
	
	Edited - February 9th, Anthony De Caria
*/

module ion(clock, resetn, ready, data_out, 
i0, i1, i2, i3, i4, i5, i6, i7);

	/*
		I/Os
	*/
	input clock, resetn;
	output [7:0] ready;
	output [109:0] data_out;
	
	/*
		Interior Wires
	*/
	wire [109:0] extracted_data0, extracted_data1, extracted_data2, extracted_data3; 
	wire [109:0] extracted_data4, extracted_data5, extracted_data6, extracted_data7;
	wire [109:0] extracted_data;
	output reg [5:0] i0, i1, i2, i3, i4, i5, i6, i7;
	wire any_timer_done;
	
	/*
		Timers
	*/
	parameter timer_cap0 = 16'd45000, timer_cap1 = 16'd50000, timer_cap2 = 16'd55000, timer_cap3 = 16'd60000;
	parameter timer_cap4 = 16'd65000, timer_cap5 = 16'd70000, timer_cap6 = 16'd75000, timer_cap7 = 16'd80000;

	wire [15:0] timer0, timer1, timer2, timer3, timer4, timer5, timer6, timer7;
	wire [15:0] n_timer0, n_timer1, n_timer2, n_timer3, n_timer4, n_timer5, n_timer6, n_timer7;
	wire [7:0] l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer[0] = (curr == Idle);
	assign l_r_timer[1] = (curr == Idle);
	assign l_r_timer[2] = (curr == Idle);
	assign l_r_timer[3] = (curr == Idle);
	assign l_r_timer[4] = (curr == Idle);
	assign l_r_timer[5] = (curr == Idle);
	assign l_r_timer[6] = (curr == Idle);
	assign l_r_timer[7] = (curr == Idle);
	
	assign r_r_timer[0] = ~( ~resetn | (curr == Read_Packet) );
	assign r_r_timer[1] = ~( ~resetn | (curr == Read_Packet) );
	assign r_r_timer[2] = ~( ~resetn | (curr == Read_Packet) );
	assign r_r_timer[3] = ~( ~resetn | (curr == Read_Packet) );
	assign r_r_timer[4] = ~( ~resetn | (curr == Read_Packet) );
	assign r_r_timer[5] = ~( ~resetn | (curr == Read_Packet) );
	assign r_r_timer[6] = ~( ~resetn | (curr == Read_Packet) );
	assign r_r_timer[7] = ~( ~resetn | (curr == Read_Packet) );
	
	adder_subtractor_16bit a_timer0(.a(timer0), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer0) );
	register_16bit_enable_async r_timer0(.clk(clock), .resetn(r_r_timer0), .enable(l_r_timer0), .select(l_r_timer0), .d(n_timer0), .q(timer0) );
	
	adder_subtractor_16bit a_timer1(.a(timer1), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer1) );
	register_16bit_enable_async r_timer1(.clk(clock), .resetn(r_r_timer1), .enable(l_r_timer1), .select(l_r_timer1), .d(n_timer1), .q(timer1) );
	
	adder_subtractor_16bit a_timer2(.a(timer2), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer2) );
	register_16bit_enable_async r_timer2(.clk(clock), .resetn(r_r_timer2), .enable(l_r_timer2), .select(l_r_timer2), .d(n_timer2), .q(timer2) );
	
	adder_subtractor_16bit a_timer3(.a(timer3), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer3) );
	register_16bit_enable_async r_timer3(.clk(clock), .resetn(r_r_timer3), .enable(l_r_timer3), .select(l_r_timer3), .d(n_timer3), .q(timer3) );
	
	adder_subtractor_16bit a_timer4(.a(timer4), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer4) );
	register_16bit_enable_async r_timer4(.clk(clock), .resetn(r_r_timer4), .enable(l_r_timer4), .select(l_r_timer4), .d(n_timer4), .q(timer4) );
	
	adder_subtractor_16bit a_timer5(.a(timer5), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer5) );
	register_16bit_enable_async r_timer5(.clk(clock), .resetn(r_r_timer5), .enable(l_r_timer5), .select(l_r_timer5), .d(n_timer5), .q(timer5) );
	
	adder_subtractor_16bit a_timer6(.a(timer6), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer6) );
	register_16bit_enable_async r_timer6(.clk(clock), .resetn(r_r_timer6), .enable(l_r_timer6), .select(l_r_timer6), .d(n_timer6), .q(timer6) );
	
	adder_subtractor_16bit a_timer7(.a(timer7), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer7) );
	register_16bit_enable_async r_timer7(.clk(clock), .resetn(r_r_timer7), .enable(l_r_timer7), .select(l_r_timer7), .d(n_timer7), .q(timer7) );
	
	assign timer_done[0] = (timer0 == timer_cap0) ? 1'b1 : 1'b0;
	assign timer_done[1] = (timer1 == timer_cap1) ? 1'b1 : 1'b0;	
	assign timer_done[2] = (timer2 == timer_cap2) ? 1'b1 : 1'b0;
	assign timer_done[3] = (timer3 == timer_cap3) ? 1'b1 : 1'b0;	
	assign timer_done[4] = (timer4 == timer_cap4) ? 1'b1 : 1'b0;
	assign timer_done[5] = (timer5 == timer_cap5) ? 1'b1 : 1'b0;
	assign timer_done[6] = (timer6 == timer_cap6) ? 1'b1 : 1'b0;
	assign timer_done[7] = (timer7 == timer_cap7) ? 1'b1 : 1'b0;
	
	assign any_timer_done = (timer_done == 8'h00) ? 1'b1 : 1'b0;

	/*
		FSM Wires
	*/
	parameter Start = 2'b00, Idle = 2'b01, Read_Packet = 2'b10, Send_Packet = 2'b11;
	reg [1:0] curr, next;
	
	/*
		State Machine for sending and reading
	*/	
	always@(*)
	begin
		case(curr)
			Start:
			begin
				i0 = 6'd0;
				i1 = 6'd0;
				i2 = 6'd0;
				i3 = 6'd0;
				i4 = 6'd0;
				i5 = 6'd0;
				i6 = 6'd0;
				i7 = 6'd0;
				
				next = Idle;
			end
			Idle: 
			begin
				i0 = i0 + 6'd0;
				i1 = i1 + 6'd0;
				i2 = i2 + 6'd0;
				i3 = i3 + 6'd0;
				i4 = i4 + 6'd0;
				i5 = i5 + 6'd0;
				i6 = i6 + 6'd0;
				i7 = i7 + 6'd0;
				
				if (!any_timer_done)
				begin
					next = Idle;	
				end
				else 
				begin
					next = Read_Packet;
				end
			end 
			Read_Packet:
			begin
				i0 = i0 + 6'd0;
				i1 = i1 + 6'd0;
				i2 = i2 + 6'd0;
				i3 = i3 + 6'd0;
				i4 = i4 + 6'd0;
				i5 = i5 + 6'd0;
				i6 = i6 + 6'd0;
				i7 = i7 + 6'd0;
				
				next = Send_Packet;
			end
			Send_Packet:
			begin
				if(!timer_done[0])
					i0 = i0 + 6'd1;
				else if(!timer_done[1])
					i1 = i1 + 6'd1;
				else if(!timer_done[2])
					i2 = i2 + 6'd1;
				else if(!timer_done[3])
					i3 = i3 + 6'd1;
				else if(!timer_done[4])
					i4 = i4 + 6'd1;
				else if(!timer_done[5])
					i5 = i5 + 6'd1;
				else if(!timer_done[6])
					i6 = i6 + 6'd1;
				else if(!timer_done[7])
					i7 = i7 + 6'd1;
				
				next = Idle;
			end
			default: 
			begin
				i0 = 6'd0;
				i1 = 6'd0;
				i2 = 6'd0;
				i3 = 6'd0;
				i4 = 6'd0;
				i5 = 6'd0;
				i6 = 6'd0;
				i7 = 6'd0;
				
				next = Start;
			end
		endcase
	end
	
	DS0 stream0(.index(i0), .data(extracted_data0));
	DS1 stream1(.index(i1), .data(extracted_data1));
	DS2 stream2(.index(i2), .data(extracted_data2));
	DS3 stream3(.index(i3), .data(extracted_data3));
	DS4 stream4(.index(i4), .data(extracted_data4));
	DS5 stream5(.index(i5), .data(extracted_data5));
	DS6 stream6(.index(i6), .data(extracted_data6));
	DS7 stream7(.index(i7), .data(extracted_data7));
	
	mux_8_110bit m_extracted_data(
		.data0(extracted_data0), 
		.data1(extracted_data1), 
		.data2(extracted_data2), 
		.data3(extracted_data3), 
		.data4(extracted_data4), 
		.data5(extracted_data5), 
		.data6(extracted_data6), 
		.data7(extracted_data7), 
		.sel(3'b001), 
		.result(extracted_data)
	);
	
	mux_2_110bit m_data_out(
		.data0(110'd0), 
		.data1(extracted_data), 
		.sel((curr == Read_Packet)), 
		.result(data_out)
	);
	
	//data_read begin sent out
	assign ready = (curr == Read_Packet) ? 8'b00000001 : 8'b00000000;
	/*
		Reset or Update Curr
	*/
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= Start; else curr <= next;
	end

endmodule
