/*
	Anthony De Caria - November 29, 2016

	This module handles the receiver logic for the ECE496-FPGA_Bluetooth_App.
	
	Algorithms:
		If we're #Collecting_Data
			And the UART_rx sends a done signal
				We set a timer - #Checking_if_Done
					If before the timer is done the UART_rx gets new data
						We go back to #Collecting_Data
					Else
						We're #Done
						Which after a clock cycle means we go back to #Collecting_Data
	
		If we're in DS Mode 
			And we're #Idle
				If new piece of data comes in
					Store it
					Since we got one, go to #Got_One
						And wait for the next piece of data
						When it comes in
							Store it
							Go back to #Idle
			And we're #Done
				Handle each case
					Start
						If the select is valid
							Set the select to whatever the user passed
							Set flag to 1
						Else
							Set everything to 0
					Cancel
						Set flag to 0
				Otherwise
					Don't set anything
					UNLESS we reset
						Then set everything to 0
			Otherwise
				Chill
				
		If we're in AT Mode
			And we get a new piece of data
				Add it to the RFIFO
			And we're #Done
				Set the at_response_flag
			Otherwise
				Chill
*/

module receiver_centre(
		clock, reset, want_at, fpga_rxd,
		uart_cpd, uart_timer_cap,
		at_response_flag,
		RFIFO_rd_en, RFIFO_out, RFIFO_wr_count, RFIFO_rd_count, RFIFO_full, RFIFO_empty,
		stream_select, ds_sending_flag,
		commands, operands
	);
	/*
		I/Os
	*/
	input clock, reset, want_at, fpga_rxd;

	input [9:0] uart_cpd;
	input [9:0] uart_timer_cap;
	
	output at_response_flag;
	
	input RFIFO_rd_en;
	output [15:0] RFIFO_out;
	output [12:0] RFIFO_wr_count;
	output [11:0] RFIFO_rd_count; 
	output RFIFO_full;
	output RFIFO_empty;
	
	output reg [7:0] stream_select;
	output reg ds_sending_flag;
	
	/*
		Wires
	*/
	wire [7:0] rx_data;
	wire is_uart_collecting_data, rx_done;
	wire at_mode, data_mode;
	
	parameter Start = 8'h00, Cancel = 8'h01;
	
	assign at_mode = want_at;
	assign data_mode = ~want_at;
	
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
		.cycles_per_databit(uart_cpd), 
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
	output [7:0] commands, operands;
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
	assign at_response_flag = (curr == Done) & at_mode;
	
	// Data
	wire begin_understanding_orders, operand_is_0;
	assign begin_understanding_orders = (curr == Done) & data_mode;
	assign operand_is_0 = (operands == 8'h00) ? 1'b1 : 1'b0;
	
	always@(*)
	begin
		if(reset)
		begin
			stream_select <= 8'h00;
			ds_sending_flag <= 1'b0;
		end
		else
		begin
			if(begin_understanding_orders)
			begin
				case(commands)
					Start:
					begin
						if(operand_is_0)
						begin
							stream_select <= 8'h00;
							ds_sending_flag <= 1'b0;
						end
						else
						begin
							stream_select <= operands;
							ds_sending_flag <= 1'b1;
						end
					end
					Cancel:
					begin
						ds_sending_flag <= 1'b0;
					end
				endcase
			end
			else
			begin
				stream_select <= stream_select;
				ds_sending_flag <= ds_sending_flag;
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
	
	assign timer_done = (timer == uart_timer_cap) ? 1'b1 : 1'b0;
	
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

