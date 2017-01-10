`timescale 1us / 1ps

module testingRC;

	// Inputs
	reg clock;
	reg reset;
	reg want_at;
	reg [9:0] cpd;
	reg [9:0] timer_cap;
	reg fpga_rxd;
	reg RFIFO_rd_en;

	// wires
	wire at_response_flag;
	wire [15:0] RFIFO_out;
	wire [12:0] RFIFO_wr_count; 
	wire [11:0] RFIFO_rd_count; 
	wire ds_sending_flag;
	wire [7:0] stream_select;
	wire are_we_sending;
	wire [7:0] commands, operands;

	// Instantiate the Unit Under Test (UUT)
	receiver_centre uut(
		.clock(clock), 
		.reset(reset),
		.want_at(want_at), 
		.fpga_rxd(fpga_rxd),
		.uart_cpd(cpd), 
		.uart_timer_cap(timer_cap),
		.at_response_flag(at_response_flag),
		.RFIFO_rd_en(RFIFO_rd_en), 
		.RFIFO_out(RFIFO_out), 
		.RFIFO_wr_count(RFIFO_wr_count), 
		.RFIFO_rd_count(RFIFO_rd_count), 
		.stream_select(stream_select), 
		.ds_sending_flag(ds_sending_flag),
		.commands(commands), .operands(operands)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		cpd = 10'd11;
		timer_cap = 10'd385;
		want_at = 1'b0;
		fpga_rxd = 1'b1;
		RFIFO_rd_en = 1'b0;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 reset = 1'b0;
		#100 want_at = 1'b1;
		#200 fpga_rxd = 1'b0;
		#201 fpga_rxd = 1'b1;
		#221 fpga_rxd = 1'b0;
		#227 fpga_rxd = 1'b1;
		#800 RFIFO_rd_en = 1'b1;
		#801 RFIFO_rd_en = 1'b0;
	end
	
endmodule

