/*
	Anthony De Caria - December 23, 2016

	This module acts as a holder for the FIFO's needed for the FBC.
*/

module FIFO_centre(
		input read_clock,
		input write_clock,
		input reset,
		
		output [7:0] DS0_out, DS1_out, DS2_out, DS3_out, DS4_out, DS5_out, DS6_out, DS7_out, AT_out,
		
		input [15:0] DS0_in, DS1_in, DS2_in, DS3_in, DS4_in, DS5_in, DS6_in, DS7_in,
		output [13:0] DS0_rd_count, DS1_rd_count, DS2_rd_count, DS3_rd_count, DS4_rd_count, DS5_rd_count, DS6_rd_count, DS7_rd_count,
		output [12:0] DS0_wr_count, DS1_wr_count, DS2_wr_count, DS3_wr_count, DS4_wr_count, DS5_wr_count, DS6_wr_count, DS7_wr_count,
		
		input [15:0] AT_in,
		output [13:0] AT_rd_count,
		output [12:0] AT_wr_count,

		input [8:0] write_enable,
		input [8:0] read_enable,
		
		output [8:0] full_flag, 
		output [8:0] empty_flag
	);
	/*
		Wires
	*/
	wire at_write_enable, at_read_enable, at_full, at_empty;
	
	assign at_write_enable = write_enable[8];
	assign at_read_enable = read_enable[8];
	assign full_flag[8] = at_full;
	assign empty_flag[8] = at_empty;
	
	/*
		DS0
	*/
	FIFO_8192_16in_8out f_DS0(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[0]),
		.rd_en(read_enable[0]),

		.din(DS0_in),
		.dout(DS0_out),

		.full(full_flag[0]),
		.empty(empty_flag[0]),

		.rd_data_count(DS0_rd_count),
		.wr_data_count(DS0_wr_count)
	);
	
	/*
		DS1
	*/
	FIFO_8192_16in_8out f_DS1(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[1]),
		.rd_en(read_enable[1]),

		.din(DS1_in),
		.dout(DS1_out),

		.full(full_flag[1]),
		.empty(empty_flag[1]),

		.rd_data_count(DS1_rd_count),
		.wr_data_count(DS1_wr_count)
	);
	
	/*
		DS2
	*/
	FIFO_8192_16in_8out f_DS2(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[2]),
		.rd_en(read_enable[2]),

		.din(DS2_in),
		.dout(DS2_out),

		.full(full_flag[2]),
		.empty(empty_flag[2]),

		.rd_data_count(DS2_rd_count),
		.wr_data_count(DS2_wr_count)
	);
	
	/*
		DS3
	*/
	FIFO_8192_16in_8out f_DS3(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[3]),
		.rd_en(read_enable[3]),

		.din(DS3_in),
		.dout(DS3_out),

		.full(full_flag[3]),
		.empty(empty_flag[3]),

		.rd_data_count(DS3_rd_count),
		.wr_data_count(DS3_wr_count)
	);
	
	/*
		DS4
	*/
	FIFO_8192_16in_8out f_DS4(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[4]),
		.rd_en(read_enable[4]),

		.din(DS4_in),
		.dout(DS4_out),

		.full(full_flag[4]),
		.empty(empty_flag[4]),

		.rd_data_count(DS4_rd_count),
		.wr_data_count(DS4_wr_count)
	);
	
	/*
		DS5
	*/
	FIFO_8192_16in_8out f_DS5(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[5]),
		.rd_en(read_enable[5]),

		.din(DS5_in),
		.dout(DS5_out),

		.full(full_flag[5]),
		.empty(empty_flag[5]),

		.rd_data_count(DS5_rd_count),
		.wr_data_count(DS5_wr_count)
	);
	
	/*
		DS6
	*/
	FIFO_8192_16in_8out f_DS6(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[6]),
		.rd_en(read_enable[6]),

		.din(DS6_in),
		.dout(DS6_out),

		.full(full_flag[6]),
		.empty(empty_flag[6]),

		.rd_data_count(DS6_rd_count),
		.wr_data_count(DS6_wr_count)
	);
	
	/*
		DS7
	*/
	FIFO_8192_16in_8out f_DS7(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(write_enable[7]),
		.rd_en(read_enable[7]),

		.din(DS7_in),
		.dout(DS7_out),

		.full(full_flag[7]),
		.empty(empty_flag[7]),

		.rd_data_count(DS7_rd_count),
		.wr_data_count(DS7_wr_count)
	);
	
	/*
		AT
	*/
	FIFO_8192_16in_8out f_AT(
		.rst(reset),

		.wr_clk(write_clock),
		.rd_clk(read_clock),

		.wr_en(at_write_enable),
		.rd_en(at_read_enable),

		.din(AT_in),
		.dout(AT_out),

		.full(at_full),
		.empty(at_empty),

		.rd_data_count(AT_rd_count),
		.wr_data_count(AT_wr_count)
	);
	
endmodule

