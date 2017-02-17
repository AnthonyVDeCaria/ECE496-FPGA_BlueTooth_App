/*
	Ming Chen Hsu Jan 20th 
	Ion sensor simulator
	
	Edited - February 9th, Anthony De Caria
*/

module ion(clock, resetn, ready, data_out0, data_out1, data_out2, data_out3, data_out4, data_out5, data_out6, data_out7,
i0, i1, i2, i3, i4, i5, i6, i7, ion_curr, ion_next, timer_done, timer0, timer1, timer2, timer3, timer4, timer5, timer6, timer7);

	/*
		I/Os
	*/
	input clock, resetn;
	output [7:0] ready;
	
	output [109:0] data_out0, data_out1, data_out2, data_out3, data_out4, data_out5, data_out6, data_out7; 
	
	/*
		Interior Wires
	*/
	wire [109:0] extracted_data0, extracted_data1, extracted_data2, extracted_data3; 
	wire [109:0] extracted_data4, extracted_data5, extracted_data6, extracted_data7;
	output reg [5:0] i0, i1, i2, i3, i4, i5, i6, i7;
	wire any_timer_done;
	
	// FSM
	parameter Start = 2'b00, Idle = 2'b01, Read_Packet = 2'b10, Send_Packet = 2'b11;
	output reg [1:0] ion_curr, ion_next;
	
	/*
		Timers
	*/
	parameter timer_cap0 = 16'd30000, timer_cap1 = 16'd35000, timer_cap2 = 16'd40000, timer_cap3 = 16'd45000;
	parameter timer_cap4 = 16'd50000, timer_cap5 = 16'd55000, timer_cap6 = 16'd60000, timer_cap7 = 16'd65000;

	output [15:0] timer0, timer1, timer2, timer3, timer4, timer5, timer6, timer7;
	wire [15:0] n_timer0, n_timer1, n_timer2, n_timer3, n_timer4, n_timer5, n_timer6, n_timer7;
	wire [7:0] l_r_timer, r_r_timer;
	output [7:0] timer_done;
	
	assign l_r_timer[0] = ~timer_done[0];
	assign l_r_timer[1] = ~timer_done[1];
	assign l_r_timer[2] = ~timer_done[2];
	assign l_r_timer[3] = ~timer_done[3];
	assign l_r_timer[4] = ~timer_done[4];
	assign l_r_timer[5] = ~timer_done[5];
	assign l_r_timer[6] = ~timer_done[6];
	assign l_r_timer[7] = ~timer_done[7];
	
	assign r_r_timer[0] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[0] | (ion_curr == Start) );
	assign r_r_timer[1] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[1] | (ion_curr == Start) );
	assign r_r_timer[2] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[2] | (ion_curr == Start) );
	assign r_r_timer[3] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[3] | (ion_curr == Start) );
	assign r_r_timer[4] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[4] | (ion_curr == Start) );
	assign r_r_timer[5] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[5] | (ion_curr == Start) );
	assign r_r_timer[6] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[6] | (ion_curr == Start) );
	assign r_r_timer[7] = ~( ~resetn | (ion_curr == Send_Packet) & timer_done[7] | (ion_curr == Start) );
	
	adder_subtractor_16bit a_timer0(.a(timer0), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer0) );
	register_16bit_enable_async r_timer0(.clk(clock), .resetn(r_r_timer[0]), .enable(l_r_timer[0]), .select(l_r_timer[0]), .d(n_timer0), .q(timer0) );
	
	adder_subtractor_16bit a_timer1(.a(timer1), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer1) );
	register_16bit_enable_async r_timer1(.clk(clock), .resetn(r_r_timer[1]), .enable(l_r_timer[1]), .select(l_r_timer[1]), .d(n_timer1), .q(timer1) );
	
	adder_subtractor_16bit a_timer2(.a(timer2), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer2) );
	register_16bit_enable_async r_timer2(.clk(clock), .resetn(r_r_timer[2]), .enable(l_r_timer[2]), .select(l_r_timer[2]), .d(n_timer2), .q(timer2) );
	
	adder_subtractor_16bit a_timer3(.a(timer3), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer3) );
	register_16bit_enable_async r_timer3(.clk(clock), .resetn(r_r_timer[3]), .enable(l_r_timer[3]), .select(l_r_timer[3]), .d(n_timer3), .q(timer3) );
	
	adder_subtractor_16bit a_timer4(.a(timer4), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer4) );
	register_16bit_enable_async r_timer4(.clk(clock), .resetn(r_r_timer[4]), .enable(l_r_timer[4]), .select(l_r_timer[4]), .d(n_timer4), .q(timer4) );
	
	adder_subtractor_16bit a_timer5(.a(timer5), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer5) );
	register_16bit_enable_async r_timer5(.clk(clock), .resetn(r_r_timer[5]), .enable(l_r_timer[5]), .select(l_r_timer[5]), .d(n_timer5), .q(timer5) );
	
	adder_subtractor_16bit a_timer6(.a(timer6), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer6) );
	register_16bit_enable_async r_timer6(.clk(clock), .resetn(r_r_timer[6]), .enable(l_r_timer[6]), .select(l_r_timer[6]), .d(n_timer6), .q(timer6) );
	
	adder_subtractor_16bit a_timer7(.a(timer7), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer7) );
	register_16bit_enable_async r_timer7(.clk(clock), .resetn(r_r_timer[7]), .enable(l_r_timer[7]), .select(l_r_timer[7]), .d(n_timer7), .q(timer7) );
	
	assign timer_done[0] = (timer0 == timer_cap0) ? 1'b1 : 1'b0;
	assign timer_done[1] = (timer1 == timer_cap1) ? 1'b1 : 1'b0;	
	assign timer_done[2] = (timer2 == timer_cap2) ? 1'b1 : 1'b0;
	assign timer_done[3] = (timer3 == timer_cap3) ? 1'b1 : 1'b0;	
	assign timer_done[4] = (timer4 == timer_cap4) ? 1'b1 : 1'b0;
	assign timer_done[5] = (timer5 == timer_cap5) ? 1'b1 : 1'b0;
	assign timer_done[6] = (timer6 == timer_cap6) ? 1'b1 : 1'b0;
	assign timer_done[7] = (timer7 == timer_cap7) ? 1'b1 : 1'b0;
	
	assign any_timer_done = (timer_done != 8'h00) ? 1'b1 : 1'b0;
	
	/*
		State Machine for sending and reading
	*/	
	always@(*)
	begin
		case(ion_curr)
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
				
				ion_next = Idle;
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
					ion_next = Idle;
				end
				else 
				begin
					ion_next = Read_Packet;
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
				
				ion_next = Send_Packet;
			end
			Send_Packet:
			begin
				if(timer_done[0])
					i0 = i0 + 6'd1;
				else if(timer_done[1])
					i1 = i1 + 6'd1;
				else if(timer_done[2])
					i2 = i2 + 6'd1;
				else if(timer_done[3])
					i3 = i3 + 6'd1;
				else if(timer_done[4])
					i4 = i4 + 6'd1;
				else if(timer_done[5])
					i5 = i5 + 6'd1;
				else if(timer_done[6])
					i6 = i6 + 6'd1;
				else if(timer_done[7])
					i7 = i7 + 6'd1;
				
				ion_next = Idle;
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
				
				ion_next = Start;
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
	
	mux_2_110bit m_ed0(.data0(110'd0), .data1(extracted_data0), .sel((ion_curr == Read_Packet)), .result(data_out0) );
	mux_2_110bit m_ed1(.data0(110'd0), .data1(extracted_data1), .sel((ion_curr == Read_Packet)), .result(data_out1) );
	mux_2_110bit m_ed2(.data0(110'd0), .data1(extracted_data2), .sel((ion_curr == Read_Packet)), .result(data_out2) );
	mux_2_110bit m_ed3(.data0(110'd0), .data1(extracted_data3), .sel((ion_curr == Read_Packet)), .result(data_out3) );
	mux_2_110bit m_ed4(.data0(110'd0), .data1(extracted_data4), .sel((ion_curr == Read_Packet)), .result(data_out4) );
	mux_2_110bit m_ed5(.data0(110'd0), .data1(extracted_data5), .sel((ion_curr == Read_Packet)), .result(data_out5) );
	mux_2_110bit m_ed6(.data0(110'd0), .data1(extracted_data6), .sel((ion_curr == Read_Packet)), .result(data_out6) );
	mux_2_110bit m_ed7(.data0(110'd0), .data1(extracted_data7), .sel((ion_curr == Read_Packet)), .result(data_out7) );
	
	
	wire r_r_ready, l_r_ready;
	assign r_r_ready = ~(~resetn |(ion_curr == Send_Packet));
	assign l_r_ready = (ion_curr == Idle);
	register_8bit_enable_async r_ready(.clk(clock), .resetn(r_r_ready), .enable(l_r_ready), .select(l_r_ready), .d(timer_done), .q(ready) );
	
	/*
		Reset or Update ion_curr
	*/
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) ion_curr <= Start; else ion_curr <= ion_next;
	end

endmodule
