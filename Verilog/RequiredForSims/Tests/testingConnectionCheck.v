`timescale 1us / 1ps

module testingConnectionCheck;

	// Inputs
	reg clock;
	reg reset;
	reg connection_switch;
	
	wire state_line, state_line_per;
	wire [31:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done, timer_reset;
	wire r_r_state_line_per, e_r_state_line_per;
	
	parameter timer_cap = 32'd500000, timer_reset_cap = 32'd500001;
	assign l_r_timer = 1'b1;
	assign r_r_timer = ~(reset | timer_reset);
	adder_subtractor_32bit a_timer(.a(timer), .b(32'd1), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_32bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;
	assign timer_reset = (timer == timer_reset_cap) ? 1'b1 : 1'b0;
	
	assign r_r_state_line_per = ~reset;
	assign e_r_state_line_per = timer_done;
	T_FF_Enable_Async r_state_line_per(.clk(clock), .resetn(r_r_state_line_per), .enable(e_r_state_line_per), .q(state_line_per));
	
	mux_2_1bit m_state_line(.data0(state_line_per), .data1(1'b1), .sel(connection_switch),. result(state_line));
	
	// Outputs
	wire connection_flag, connection_warning_flag;

	// Instantiate the Unit Under Test (UUT)
	HM_10_Connection_Check uut(
		.reset(reset),
		.clock(clock),
		.state_line(state_line), 
		.connection_flag(connection_flag),
		.connection_warning_flag(connection_warning_flag)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		connection_switch = 0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 reset = 1'b0;
		
		#5000000 connection_switch = 1'b1;
		
		#25000000 connection_switch = 1'b0;
	end
	
endmodule

