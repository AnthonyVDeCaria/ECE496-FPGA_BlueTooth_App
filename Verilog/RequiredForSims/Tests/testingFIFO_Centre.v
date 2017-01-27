`timescale 1us / 1ps

module testingFIFO_Centre;

	// Inputs
	reg clock;
	reg reset;
	reg [8:0] wr_en, rd_en;

	// Outputs
	wire [15:0] datastream0, datastream1, datastream2, datastream3, datastream4, datastream5, datastream6, datastream7;
	wire [8:0] fifo_state_full, fifo_state_empty;
	wire [5:0] DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count;
	wire [3:0] DS0_wr_count, DS1_wr_count, DS2_wr_count, DS3_wr_count, DS4_wr_count, DS5_wr_count, DS6_wr_count, DS7_wr_count;
	
	parameter sensor0 = "Hello World! :-)", sensor1 = "DragonForce TFAF", sensor2 = "Bloody_Radio.exe", sensor3 = "Linkin=Park.xlsx";
	parameter sensor4 = "Fly on a Dog[tm]", sensor5 = "Foo^Fighting^ooF", sensor6 = "~~KAWAII~~~~~~~~", sensor7 = "*I LIKE PICKLES*";

	// Instantiate the Unit Under Test (UUT)
	FIFO_centre uut(
		.read_clock(clock),
		.write_clock(clock),
		.reset(reset),
		
		.DS0_in(sensor0), .DS1_in(sensor1), .DS2_in(sensor2), .DS3_in(sensor3), .DS4_in(sensor4), .DS5_in(sensor5), .DS6_in(sensor6), .DS7_in(sensor7),
		.DS0_out(datastream0), .DS1_out(datastream1), .DS2_out(datastream2), .DS3_out(datastream3), .DS4_out(datastream4), .DS5_out(datastream5), .DS6_out(datastream6), .DS7_out(datastream7),
		.DS0_rd_count(DS0_rd_count), .DS1_rd_count(DS1_rd_count), .DS2_rd_count(DS2_rd_count), .DS3_rd_count(DS3_rd_count), 
		.DS4_rd_count(DS4_rd_count), .DS5_rd_count(DS5_rd_count), .DS6_rd_count(DS6_rd_count), .DS7_rd_count(DS7_rd_count),
		.DS0_wr_count(DS0_wr_count), .DS1_wr_count(DS1_wr_count), .DS2_wr_count(DS2_wr_count), .DS3_wr_count(DS3_wr_count), 
		.DS4_wr_count(DS4_wr_count), .DS5_wr_count(DS5_wr_count), .DS6_wr_count(DS6_wr_count), .DS7_wr_count(DS7_wr_count),
		
		.AT_in(),
		.AT_out(),
		.AT_rd_count(),
		.AT_wr_count(),

		.write_enable(wr_en),
		.read_enable(rd_en),
		
		.full_flag(fifo_state_full), 
		.empty_flag(fifo_state_empty)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 1;
		wr_en = 9'h000;
		rd_en = 9'h000;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#0 reset = 1'b0;
		#0 wr_en = 9'h0FF;
		
		#1 wr_en = 9'h07F;
		
		#10 wr_en = 9'h033;
		
		#150 rd_en = 9'h0a0;
	end
	
endmodule

