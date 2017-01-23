/*
	Anthony De Caria - January 20, 2017
	
	This module instansiates a sensor analog for testing.
*/
module sensor_analog(
		clock, reset,
		sensor_stream0, sensor_stream1, sensor_stream2, sensor_stream3, 
		sensor_stream4, sensor_stream5, sensor_stream6, sensor_stream7,
		sensor_stream_ready
		
//		sensor_timer,
//		n_sensor_timer,
//		sensor_timer_done
	);
	/*
		I/O
	*/
	input clock, reset;
	
	output [31:0] sensor_stream0, sensor_stream1, sensor_stream2, sensor_stream3, sensor_stream4, sensor_stream5, sensor_stream6, sensor_stream7;
	output [7:0] sensor_stream_ready;
	
	assign sensor_stream0 = 32'h41624364, sensor_stream1 = 16'h5B5D, sensor_stream2 = 16'h6E49, sensor_stream3 = 16'h3B29; // AbCd, [], nI, ;)
	assign sensor_stream4 = 16'h2829, sensor_stream5 = 16'h3725, sensor_stream6 = 16'h780A, sensor_stream7 = 16'h7B6C; // (), 7%, x\n, {l
	
	reg [1:0] sa_curr, sa_next;
	
	parameter Reset = 2'b00, Waiting = 2'b01, Ding = 2'b10;
	
	/*
		Timer
	*/
	wire [15:0] sensor_timer, n_sensor_timer;
	wire l_r_sensor_timer, r_r_sensor_timer, sensor_timer_done;
	parameter sensor_timer_cap = 16'd25;
	assign l_r_sensor_timer = 1'b1;
	assign r_r_sensor_timer = ~(reset | (sa_curr == Reset)) ;
	
	adder_subtractor_16bit a_sensor_timer(.a(sensor_timer), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_sensor_timer) );
	register_16bit_enable_async r_sensor_timer(.clk(clock), .resetn(r_r_sensor_timer), .enable(l_r_sensor_timer), .select(l_r_sensor_timer), .d(n_sensor_timer), .q(sensor_timer) );
	
	assign sensor_timer_done = (sensor_timer == sensor_timer_cap) ? 1'b1 : 1'b0;
	
	assign sensor_stream_ready[0] = (sa_curr == Ding);
	assign sensor_stream_ready[7:1] = 7'h00;
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(sa_curr)
			Reset:
			begin
				sa_next = Waiting;
			end
			Waiting:
			begin
				if(sensor_timer_done)
					sa_next = Ding;
				else
					sa_next = Waiting;
			end
			Ding:
			begin
				sa_next = Reset;
			end
			default:
			begin
				sa_next = Reset;
			end
		endcase
	end
	always@(posedge clock or posedge reset)
	begin
		if(reset) 
			sa_curr <= Reset; 
		else 
			sa_curr <= sa_next;
	end
endmodule
