/*
	Anthony De Caria - April 1, 2017
	
	This module handles the AT Response from the BLE module.

	Algorithm:
	If we get a start - #Idle
			Wait for data to come in - #Collecting_Data
			If the UART_rx sends a uart_done signal
				Add the byte to the RFIFO - #Checking_if_Packet_Received
				Set a Byte Timer
				If before the Byte Timer is done the UART_rx gets new data
					We go back to #Collecting_Data
				Else
					We have the full packet - #Packet_Received
					Set the at_response_flag
					Go back to #Idle
		Else
			#Idle
*/
module handle_at_response(
		clock, reset,
		start, uart_done, uart_collecting_data,
		RFIFO_in, RFIFO_out, RFIFO_rd_en, RFIFO_rd_count, RFIFO_wr_count, RFIFO_full, RFIFO_empty,
		uart_byte_spacing, uart_cpd,
		at_response_flag
	);
	/*
		I/Os
	*/
	//General
	input clock, reset;
	
	// Input Flags
	input start, uart_done, uart_collecting_data;
	
	// FIFO
	input [7:0] RFIFO_in;
	output [15:0] RFIFO_out;
	input RFIFO_rd_en;
	output [6:0] RFIFO_rd_count;
	output [7:0] RFIFO_wr_count; 
	output RFIFO_full;
	output RFIFO_empty;
	
	// Timer
	input [9:0] uart_byte_spacing, uart_cpd;
	
	// Output Flags
	output at_response_flag;
	
	/*
		Wires
	*/	
	// RFIFO
	wire RFIFO_wr_en;
	
	// Timer
	wire [9:0] atr_timer_limit;
 	wire l_atr_timer, rn_atr_timer, atr_timer_done;
	
	// FSM
	parameter Idle = 2'b00, Collecting_Data = 2'b01, Checking_if_Packet_Received = 2'b10, Packet_Received = 2'b11;
	reg [1:0] at_curr, at_next;
	
	/*
		Assignments
		
		The timer is set to be 2 CPD periods and a Byte Period
		Why two CPDs? This is to maximize the time between the rx_done signal "which happens at the beginning of the CPD"
		and the rx_collecting_data "which happens at the end of the CPD".
	*/
	assign RFIFO_wr_en = uart_done;
	
	assign atr_timer_limit = uart_cpd + uart_byte_spacing + uart_cpd;
	assign l_atr_timer = (at_curr == Checking_if_Packet_Received);
	assign rn_atr_timer = ~(reset | (at_curr == Collecting_Data) ) ;
	
	assign at_response_flag = (at_curr == Packet_Received);
	
	/*
		Modules
	*/
	// FIFO	
	FIFO_256_8in_16out RFIFO(
		.rst(reset),
		
		.wr_clk(clock),
		.rd_clk(clock),
		
		.wr_en(RFIFO_wr_en),
		.rd_en(RFIFO_rd_en),
		
		.din(RFIFO_in),
		.dout(RFIFO_out),
		
		.full(RFIFO_full),
		.empty(RFIFO_empty),
		
		.rd_data_count(RFIFO_rd_count),
		.wr_data_count(RFIFO_wr_count)
	);
	
	// Timer
	timer_10bit atr_timer(
		.clock(clock), 
		.resetn_timer(rn_atr_timer), 
		.timer_active(l_atr_timer), 
		.timer_final_value(atr_timer_limit), 
		.timer_done(atr_timer_done)
	);
	
	/*
		FSMs
	*/
	always@(*)
	begin
		case(at_curr)
			Idle:
			begin
				if(start)
					at_next = Collecting_Data;
				else
					at_next = Idle;
			end
			Collecting_Data:
			begin
				if(uart_done)
					at_next = Checking_if_Packet_Received;
				else
					at_next = Collecting_Data;
			end
			Checking_if_Packet_Received:
			begin
				if(uart_collecting_data)
					at_next = Collecting_Data;
				else
				begin
					if(atr_timer_done)
						at_next = Packet_Received;
					else
						at_next = Checking_if_Packet_Received;
				end
			end
			Packet_Received:
			begin
				at_next = Collecting_Data;
			end
			
			default:
			begin
				at_next = Idle;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
			at_curr <= Idle;
		else
			at_curr <= at_next;
	end
endmodule
