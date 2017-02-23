`timescale 1us / 1ps

module testingMS;

	// Inputs
	reg clock;
	reg resetn;
	reg [7:0] selected_streams;
	reg [8:0] rd_en;
	
	wire [5:0] DS0_rd_count;
	wire [127:0] sensor_stream0;
	wire [7:0] empty_fifo_flags, data_exists;
	wire sending_flag;
	assign sending_flag = (empty_fifo_flags != 8'hFF) ? 1'b1 : 1'b0;

	// Outputs
	wire [2:0] mux_select;
	wire select_ready;
	wire [127:0] datastream0;
	
	wire [2:0] curr, next;

	// Instantiate the Unit Under Test (UUT)
	master_switch_ece496 uut(
		.clock(clock), 
		.resetn(resetn),  
		.sending_flag(sending_flag), 
		.selected_streams(selected_streams),
		.empty_fifo_flags(empty_fifo_flags),
		.mux_select(mux_select),
		.select_ready(select_ready),
		
		.ms_curr(curr), .ms_next(next)
	);
	
	ion helper1(.clock(clock), .resetn(resetn), .ready(data_exists), .data_out());
	
	assign sensor_stream0[6:0] = 7'd77;
	assign sensor_stream0[7] = 1'd0;
	assign sensor_stream0[15:8] = 8'd255;
	assign sensor_stream0[23:16] = 8'd177;
	assign sensor_stream0[31:24] = 8'd100;
	assign sensor_stream0[47:32] = 16'd881;
	assign sensor_stream0[55:48] = 8'd239;
	assign sensor_stream0[63:56] = 8'd17;
	assign sensor_stream0[79:64] = 16'd56110;
	assign sensor_stream0[85:80] = 6'd1;
	assign sensor_stream0[109:86] = 24'd4272433;
	assign sensor_stream0[127:110] = 17'hFFFFF;
	
	FIFO_centre warehouse(
		.read_clock(clock),
		.write_clock(clock),
		.reset(~resetn),
		
		.DS0_in(sensor_stream0), 
		.DS0_out(datastream0), 
		.DS0_rd_count(), 
		.DS0_wr_count(), 
		
		.write_enable(data_exists),
		.read_enable(rd_en),
		
		.full_flag(), 
		.empty_flag(empty_fifo_flags)
	);
	
	always begin
		#1 clock = !clock;
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		resetn = 1'b0;
		selected_streams = 8'h00;
		rd_en = 8'h00;

		// Wait 100 us for global reset to finish
		#100;
        
		// Add stimulus here
		#100 resetn = 1'b1;
		#100 selected_streams = 8'hFF;
		
		#20000 rd_en[0] = 8'h01;
		#20001 rd_en[0] = 8'h00;
	end
	
endmodule

