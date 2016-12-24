`timescale 1us / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:30:42 09/28/2016
// Design Name:   FPGA_Bluetooth_connection
// Module Name:   C:/Users/Anthony/Desktop/ECE496/t1_sim/t1.v
// Project Name:  t1_sim
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FPGA_Bluetooth_connection
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testingFIFO_Centre;

	// Inputs
	reg clock;
	reg reset;
	reg [8:0] wr_en, rd_en;

	// Outputs
	wire [7:0] datastream0, datastream1, datastream2, datastream3, datastream4, datastream5, datastream6, datastream7;
	wire [8:0] fifo_state_full, fifo_state_empty;
	wire [13:0] DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count;
	wire [12:0] DS0_wr_count, DS1_wr_count, DS2_wr_count, DS3_wr_count, DS4_wr_count, DS5_wr_count, DS6_wr_count, DS7_wr_count;
	
	parameter sensor0 = 16'h4869, sensor1 = 16'h5B5D, sensor2 = 16'h6E49, sensor3 = 16'h3B29;
	parameter sensor4 = 16'h2829, sensor5 = 16'h3725, sensor6 = 16'h780A, sensor7 = 16'h7B2C;

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
		
		#150 rd_en = 9'h020;
	end
	
endmodule

