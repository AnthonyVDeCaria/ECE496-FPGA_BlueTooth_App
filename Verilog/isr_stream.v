/*
	Anthony De Caria - March 26, 2017
	
	This module is one ISR stream, used to make a request to a stream "n"
	This should be set in ion_sensor_requester.v
	
	Algorithm:
		Add a period and offset to create a timer value - #Idle
		If this stream is active
			Start subtracting 1 from this timer - #Wait
			If it hits 0
				Send a i_s_request - #Done
				Go back to #Idle
			Else
				#Wait
		Else
			#Idle
		
*/
module isr_stream(clock, resetn, period, offset, stream_active, i_s_request);
	/*
		I/Os
	*/
	input clock, resetn;
	input [15:0] period, offset;
	input stream_active;
	
	output i_s_request;
	
	/*
		Wires
	*/
	// Timers
	wire [15:0] a, b, timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	// FSM
	parameter Idle = 2'b00, Wait = 2'b01, Done = 2'b10;
	reg [1:0] isrs_curr, isrs_next;

	/*
		Timers
	*/	
	assign l_r_timer = (isrs_curr == Wait) | (isrs_curr == Idle);
	assign r_r_timer = ~( ~resetn );
	
	mux_2_16bit m_timer_b(.data0(offset), .data1(timer), .sel(stream_active), .result(b));
	mux_2_16bit m_timer_a(.data0(period), .data1(16'd1), .sel(stream_active), .result(a));
	adder_subtractor_16bit a_timer(.a(a), .b(b), .want_subtract(stream_active), .c_out(), .s(n_timer) );
	register_16bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == 16'd0) ? 1'b1 : 1'b0;
	
	/*
		Request
	*/
	assign i_s_request = (isrs_curr == Done);

	/*
		FSM
	*/
	always@(*)
	begin
		case(isrs_curr)
			Idle:
			begin
				if(stream_active)
					isrs_next = Wait;
				else
					isrs_next = Idle;
			end
			Wait:
			begin
				if(timer_done)
					isrs_next = Done;
				else
					isrs_next = Wait;
			end
			Done:
			begin
				isrs_next = Idle;
			end
			default:
			begin
				isrs_next = Idle;
			end
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn)
		begin
			isrs_curr <= Idle;
		end
		else
		begin
			isrs_curr <= isrs_next;
		end
	end
endmodule
