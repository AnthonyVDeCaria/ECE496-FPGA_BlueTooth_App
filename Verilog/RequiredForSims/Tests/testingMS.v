`timescale 1us / 1ps

module testingMS;

	// Inputs
	reg clock;
	reg resetn;
	reg sending_flag;
	reg want_at;
	reg [7:0] selected_streams;
	reg [7:0] empty_fifo_flags;
	reg [5:0] DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count;

	// Outputs
	wire [3:0] mux_select;
	wire select_ready;
	wire [7:0] rd_count_equals_trig, ds_rd_count_not_0;
	wire [5:0] trig_DS0;
	
	wire [2:0] curr, next;

	// Instantiate the Unit Under Test (UUT)
	master_switch_ece496 uut(
		.clock(clock), 
		.resetn(resetn), 
		.want_at(want_at), 
		.sending_flag(sending_flag), 
		.selected_streams(selected_streams),
		.empty_fifo_flags(empty_fifo_flags),
		.mux_select(mux_select),
		.select_ready(select_ready),
		.DS0_rd_count(DS0_rd_count), .DS1_rd_count(DS1_rd_count), .DS2_rd_count(DS2_rd_count), .DS3_rd_count(DS3_rd_count), 
		.DS4_rd_count(DS4_rd_count), .DS5_rd_count(DS5_rd_count), .DS6_rd_count(DS6_rd_count), .DS7_rd_count(DS7_rd_count),
		
		.ms_curr(curr), .ms_next(next), .rd_count_equals_trig(rd_count_equals_trig), .trig_DS0(trig_DS0), .ds_rd_count_not_0(ds_rd_count_not_0)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 1'b0;
		selected_streams = 8'h00;
		sending_flag = 1'b0;
		want_at = 1'b0;
		DS0_rd_count = 6'h00;
		DS1_rd_count = 6'h00;
		DS2_rd_count = 6'h00; 
		DS3_rd_count = 6'h00;
		DS4_rd_count = 6'h00;
		DS5_rd_count = 6'h00;
		DS6_rd_count = 6'h00;
		DS7_rd_count = 6'h00;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 resetn = 1'b1;
		
		#100 selected_streams = 8'haa;
		#100 empty_fifo_flags = 8'hFE;
		#100 sending_flag = 1'b1;
		
		#200 sending_flag = 1'b0;
		#200 selected_streams = 8'h01;
		#200 empty_fifo_flags = 8'hFE;
		#201 sending_flag = 1'b1;
		
		#300 sending_flag = 1'b0;
		#300 selected_streams = 8'h11;
		#300 empty_fifo_flags = 8'hFE;
		#301 sending_flag = 1'b1;
		
		#400 sending_flag = 1'b0;
		#400 selected_streams = 8'hC3;
		#400 empty_fifo_flags = 8'h3C;
		#401 sending_flag = 1'b1;
		#450 empty_fifo_flags = 8'h03;
		
		#500 sending_flag = 1'b0;
		#500 selected_streams = 8'h03;
		#500 empty_fifo_flags = 8'hFE;
		#501 sending_flag = 1'b1;
		
		#600 sending_flag = 1'b0;
		#600 selected_streams = 8'h06;
		#600 empty_fifo_flags = 8'hF9;
		#601 sending_flag = 1'b1;
		
		#700 sending_flag = 1'b0;
		#700 selected_streams = 8'h05;
		#700 selected_streams = 8'hFA;
		#701 sending_flag = 1'b1;
	end
	
endmodule

