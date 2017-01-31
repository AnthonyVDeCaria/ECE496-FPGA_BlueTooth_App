`timescale 1us / 1ps

module testingRC;

	// Inputs
	reg clock;
	reg reset;
	reg [7:0] tx_data;
	reg start;
	reg want_at;
	reg RFIFO_rd_en;
	
	parameter cpd = 10'd50;
	parameter timer_cap = 10'd12;
	wire data_line;

	// Outputs
	wire tx_done;
	wire at_response_flag;
	wire [15:0] RFIFO_out;
	wire [12:0] RFIFO_wr_count; 
	wire [11:0] RFIFO_rd_count; 
	wire ds_sending_flag;
	wire [7:0] stream_select;
	wire [7:0] commands, operands;
	wire l_r_ds_sending_flag, r_r_ds_sending_flag, ds_sending_flag_value, c, n;
	wire [1:0] rc_curr, rc_next;
	wire [9:0] timer, n_timer;

	// Instantiate the Unit Under Test (UUT)
	receiver_centre uut(
		.clock(clock), 
		.reset(reset),
		
		.uart_cpd(cpd), 
		.uart_timer_cap(timer_cap),
		 
		.fpga_rxd(data_line),
		
		.want_at(want_at),
		.at_response_flag(at_response_flag),
		.RFIFO_rd_en(RFIFO_rd_en), 
		.RFIFO_out(RFIFO_out), 
		.RFIFO_wr_count(RFIFO_wr_count), 
		.RFIFO_rd_count(RFIFO_rd_count),
		
		.stream_select(stream_select), 
		.ds_sending_flag(ds_sending_flag),
		
		.commands(commands), .operands(operands), .l_r_ds_sending_flag(l_r_ds_sending_flag), .r_r_ds_sending_flag(r_r_ds_sending_flag), .ds_sending_flag_value(ds_sending_flag_value),
		.rc_curr(rc_curr), .rc_next(rc_next), .c(c), .n(n),
		.timer(timer), .n_timer(n_timer)
	);
	
	UART_tx santas_little_helper(
			.clk(clock), 
			.resetn(~reset), 
			.start(start), 
			.cycles_per_databit(cpd), 
			.tx_line(data_line),
			.tx_data(tx_data),
			.tx_done(tx_done)
		);
	
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		want_at = 1'b0;
		RFIFO_rd_en = 1'b0;
		tx_data = 8'h00;
		start = 1'b0;
		
		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 reset = 1'b0;
		#100 want_at = 1'b1;
		
		#220 tx_data = "O";
		#250 start = 1'b1;
		#275 start = 1'b0;
		
		#620 tx_data = "K";
		#650 start = 1'b1;
		#675 start = 1'b0;
		
		#800 RFIFO_rd_en = 1'b1;
		#801 RFIFO_rd_en = 1'b0;
		
		#1000 want_at = 1'b0;
		#1020 tx_data = 8'h00;
		#1050 start = 1'b1;
		#1075 start = 1'b0;
		
		#1220 tx_data = 8'h78;
		#1250 start = 1'b1;
		#1275 start = 1'b0;
		
		#1420 tx_data = 8'h01;
		#1450 start = 1'b1;
		#1475 start = 1'b0;
	end
	
endmodule
