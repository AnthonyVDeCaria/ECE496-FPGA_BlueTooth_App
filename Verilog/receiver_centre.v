/*
	Anthony De Caria - November 29, 2016

	This module handles the receiver logic for the ECE496-FPGA_Bluetooth_App
*/

module receiver_centre(
		input clock, 
		input reset,

		input [9:0] cpd,
		input fpga_rxd,
		
		output at_complete,
		
		input RFIFO_rd_en,
		output [15:0] RFIFO_out, 
		output [12:0] RFIFO_wr_count, 
		output [11:0] RFIFO_rd_count, 
		output RFIFO_full, 
		output RFIFO_empty,
		
		output reg [2:0] stream_select,
		output set_sending,
		
		input bt_state
	);
	/*
		Wires
	*/
	wire [7:0] rx_data;
	wire rx_done;
	
	parameter Select_Datastream =  3'b110;
	
	/*
		FSM Wires
	*/
	reg [1:0] curr, next;
	parameter Idle = 2'b00, Collect_AT = 2'b01, Get_Command_from_App = 2'b10, Implement_Changes = 2'b11;
	
	reg [1:0] c, n;
	parameter ITB = 2'b00, Found_11 = 2'b01, Got_Message = 2'b10;
	
	/*
		Assignments
	*/
	assign set_sending = ~( (curr == Get_Command_from_App) & (curr == Implement_Changes) ) ;
	
	/*
		Receiver Hardware
	*/
	//	UART
	wire is_uart_collecting_data;
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
	assign RFIFO_wr_en = rx_done & (curr == Collect_AT);
	
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
	wire [7:0] orders_from_app;
	wire r_r_data, e_r_data, l_r_data;
	
	assign r_r_data = ~reset;
	assign e_r_data = rx_done & (curr == Get_Command_from_App) & (c == Found_11);
	assign l_r_data = rx_done & (curr == Get_Command_from_App) & (c == Found_11);
	
	register_8bit_enable_async r_data(.clk(clock), .resetn(r_r_data), .enable(e_r_data), .select(l_r_data), .d(rx_data), .q(orders_from_app) );
	
	/*
		Interpreter Hardware
	*/
	always@(*)
	begin
		if(reset)
		begin
			stream_select <= 3'b000;
		end
		else
		begin
			if(curr == Implement_Changes)
			begin
				case(orders_from_app[6:4])
					Select_Datastream:
					begin
						stream_select <= orders_from_app[2:0];
					end
				endcase
			end
			else
			begin
				stream_select <= stream_select;
			end
		end
	end
	
	/*
		FSMs
	*/
	//	General
	wire found_00;
	assign found_00 = (rx_data == 8'h00) ? 1'b1 : 1'b0;
	
	wire at_over;
	assign at_over = 1'b1;
	
	always@(*)
	begin
		case(curr)
			Idle:
			begin
				if(is_uart_collecting_data)
				begin
					if(bt_state)
						next = Get_Command_from_App;
					else
						next = Collect_AT;
				end
				else
				begin
					next = Idle;
				end
			end
			Collect_AT:
			begin
				if(at_over)
					next = Idle;
				else
					next = Collect_AT;
			end
			Get_Command_from_App:
			begin
				if(found_00)
					next = Implement_Changes;
				else
					next = Get_Command_from_App;
			end
			Implement_Changes:
			begin
				next = Idle;
			end
		endcase
	end
	
	assign at_complete = (curr == Collect_AT) & (at_over);
	
	//	Parsing User Input
	wire is_line_11, f_11_trigger;
	assign is_line_11 = (rx_data == 8'h11) ? 1'b1 : 1'b0;
	assign f_11_trigger = is_line_11 & (curr == Get_Command_from_App);
	
	always@(*)
	begin
		case(c)
			ITB:
			begin
				if(f_11_trigger)
					n = Found_11;
				else
					n = ITB;
			end
			Found_11:
			begin
				if(rx_done)
					n = Got_Message;
				else
					n = Found_11;
			end
			Got_Message:
			begin
				if(found_00)
					n = ITB;
				else
					n = Got_Message;
			end
		endcase
	end
	
	//	Clock
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			curr <= Idle; 
			c <= ITB;
		end
		else
		begin
			curr <= next;
			c <= n;
		end
	end
	
endmodule

