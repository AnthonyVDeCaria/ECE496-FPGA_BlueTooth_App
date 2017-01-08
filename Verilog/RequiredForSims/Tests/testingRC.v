`timescale 1us / 1ps

module testingRC;

	// Inputs
	reg clock;
	reg reset;
	reg bt_state;
	reg [7:0] ep01wireIn;
	reg [9:0] cpd;
	reg [9:0] timer_cap;
	reg fpga_rxd;
	reg RFIFO_rd_en;

	// wires
	wire at_complete;
	wire [15:0] RFIFO_out;
	wire [12:0] RFIFO_wr_count; 
	wire [11:0] RFIFO_rd_count; 
	wire RFIFO_full;
	wire RFIFO_empty;
	wire [7:0] stream_select;
	wire are_we_sending;

	// Instantiate the Unit Under Test (UUT)
	receiver_centre uut(
		.clock(clock), 
		.reset(reset),
		
		.bt_state(bt_state),
		.fpga_rxd(fpga_rxd),

		.cpd(cpd),
		.timer_cap(timer_cap),
		
		.at_complete(at_complete),
		
		.RFIFO_rd_en(RFIFO_rd_en),
		.RFIFO_out(RFIFO_out), 
		.RFIFO_wr_count(RFIFO_wr_count), 
		.RFIFO_rd_count(RFIFO_rd_count), 
		.RFIFO_full(RFIFO_full), 
		.RFIFO_empty(RFIFO_empty),
		
		.stream_select(stream_select),
		.are_we_sending(are_we_sending)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		ep01wireIn = 8'h00;
		cpd = 10'd11;
		timer_cap = 10'd385;
		bt_state = 1'b0;
		fpga_rxd = 1'b1;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 reset = 1'b0;
		#200 fpga_rxd = 1'b0;
		#250 bt_state = 1'b1;
		#300 fpga_rxd = 1'b1;
	end
	
endmodule

