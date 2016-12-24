/*
	Anthony De Caria - November 29, 2016

	This module handles the receiver logic for the ECE496-FPGA_Bluetooth_App
*/

module receiver_centre(
		input clock, 
		input reset,
		
		input bt_state,
		input fpga_rxd,

		input [9:0] cpd,
		input [9:0] timer_cap,
		
		output at_complete,
		
		input RFIFO_rd_en,
		output [15:0] RFIFO_out, 
		output [12:0] RFIFO_wr_count, 
		output [11:0] RFIFO_rd_count, 
		output RFIFO_full, 
		output RFIFO_empty,
		
		output reg [7:0] stream_select,
		output reg sending_flag
	);
	/*
		Wires
	*/
	wire [7:0] rx_data;
	wire is_uart_collecting_data, rx_done;
	wire at_mode, data_mode;
	
	parameter Start = 8'h00, Cancel = 8'h01;
	
	assign at_mode = ~bt_state;
	assign data_mode = bt_state;
	
	/*
		FSM Wires
	*/
	parameter Collecting_Data = 2'b00, Checking_if_Done = 2'b01, Done = 2'b10;
	reg [1:0] curr, next;
	
	parameter Idle = 1'b0, Got_One = 1'b1; 
	reg c, n;
	
	/*
		Receiver Hardware
	*/
	//	UART
	UART_rx rx(
		.clk(clock), 
		.resetn(~reset), 
		.cycles_per_databit(cpd), 
		.rx_line(fpga_rxd), 
		.rx_data(rx_data), 
		.collecting_data(is_uart_collecting_data),
		.rx_data_valid(rx_done)
	);
	
	//	FIFO
	wire RFIFO_wr_en;
	assign RFIFO_wr_en = rx_done & at_mode;
	
	FIFO_8192_8in_16out RFIFO(
		.rst(reset),
		
		.wr_clk(clock),
		.rd_clk(clock),
		
		.wr_en(RFIFO_wr_en),
		.rd_en(RFIFO_rd_en),
		
		.din(rx_data),
		.dout(RFIFO_out),
		
		.full(RFIFO_full),
		.empty(RFIFO_empty),
		
		.rd_data_count(RFIFO_rd_count),
		.wr_data_count(RFIFO_wr_count)
	);
	
	//	User Commands
	wire [7:0] commands, operands;
	wire r_r_commands, l_r_commands;
	wire r_r_operands, l_r_operands;
	
	assign r_r_commands = ~reset;
	assign r_r_operands = ~reset;
	
	assign l_r_commands = rx_done & data_mode & (c == Idle);
	assign l_r_operands = rx_done & data_mode & (c == Got_One);
	
	register_8bit_enable_async r_commands(.clk(clock), .resetn(r_r_commands), .enable(l_r_commands), .select(l_r_commands), .d(rx_data), .q(commands) );
	register_8bit_enable_async r_operands(.clk(clock), .resetn(r_r_operands), .enable(l_r_operands), .select(l_r_operands), .d(rx_data), .q(operands) );
	
	/*
		Interpreter Hardware
	*/
	// AT
	assign at_complete = (curr == Done) & at_mode;
	
	// Data
	wire begin_understanding_orders;
	assign begin_understanding_orders = (curr == Done) & data_mode;
	
	always@(*)
	begin
		if(reset)
		begin
			stream_select <= 8'h00;
			sending_flag <= 1'b0;
		end
		else
		begin
			if(begin_understanding_orders)
			begin
				case(commands)
					Start:
					begin
						stream_select <= operands;
						sending_flag <= 1'b1;
					end
					Cancel:
					begin
						sending_flag <= 1'b0;
					end
				endcase
			end
			else
			begin
				stream_select <= stream_select;
				sending_flag <= sending_flag;
			end
		end
	end
	
	/*
		Timer
	*/
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (curr == Checking_if_Done);
	assign r_r_timer = ~(reset | (curr == Collecting_Data) ) ;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;
	
	/*
		FSMs
	*/
	// Receiving
	always@(*)
	begin
		case(curr)
			Collecting_Data:
			begin
				if(rx_done)
					next = Checking_if_Done;
				else
					next = Collecting_Data;
			end
			Checking_if_Done:
			begin
				if(is_uart_collecting_data)
					next = Collecting_Data;
				else
				begin
					if(timer_done)
						next = Done;
					else
						next = Checking_if_Done;
				end
			end
			Done:
			begin
				next = Collecting_Data;
			end
		endcase
	end
	
	// Storing User Data
	always@(*)
	begin
		case(c)
			Idle:
			begin
				if(rx_done & data_mode)
					n = Got_One;
				else
					n = Idle;
			end
			Got_One:
			begin
				if(rx_done & data_mode)
					n = Idle;
				else
					n = Got_One;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin 
			curr <= Collecting_Data;
			c <= Idle;
		end
		else
		begin
			curr <= next;
			c <= n;
		end
	end
	
endmodule

