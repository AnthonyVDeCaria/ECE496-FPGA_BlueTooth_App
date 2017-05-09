/*
	Anthony De Caria - April 13, 2017

	The module creates a 
	
	Algorithm:
		
*/

module UART_sender_for_testing(
		clock, reset,
		uart_cpd, uart_byte_spacing,
		user_data_on_line, user_data_done,
		tx_done,
		half_word,
		tx_line
	);
	/*
		I/Os
	*/
	input clock, reset;
	input [9:0] uart_cpd, uart_byte_spacing;
	input user_data_on_line, user_data_done;
	input [15:0] half_word;
	output tx_done;
	output tx_line;
	
	/*
		Wires 
	*/
	wire [7:0] uart_input;
	
	// Flags
	wire usft_timer_done, tx_done, all_data_sent;
	
	// FIFO
	wire wr_en, rd_en;
	
	// UART Timer Wires
	wire [9:0] uart_byte_timer, n_uart_byte_timer;
	wire l_r_uart_byte_timer;
	wire r_r_uart_byte_timer;
	
	/*
		FSM Parameters
	*/
	parameter Idle = 3'b000;
	parameter Load_FIFO = 3'b001, Rest_FIFO = 3'b010;
	parameter Release_from_FIFO = 3'b011;
	parameter Send_Byte = 3'b100, Rest_Transmission = 3'b101;
	parameter Done = 3'b110;
	
	reg [2:0] fbc_curr, fbc_next;
	
	//	FIFO
	assign wr_en = (fbc_curr == Load_FIFO);
	assign rd_en = (fbc_curr == Release_from_FIFO);
	
	FIFO_64_16in_8out FIFO(
		.rst(reset),
		.wr_clk(clock),
		.rd_clk(clock),
		.din(half_word),
		.wr_en(wr_en),
		.rd_en(rd_en),
		.dout(uart_input),
		.full(),
		.empty(fifo_empty),
		.rd_data_count(),
		.wr_data_count()
	);

	// Datastream Selector
	assign all_data_sent = fifo_empty;
	
	//	UART Byte Timer
	assign l_r_uart_byte_timer = (fbc_curr == Rest_Transmission);
	assign r_r_uart_byte_timer = ~(reset | (fbc_curr == Idle) | (fbc_curr == Release_from_FIFO) | (fbc_curr == Send_Byte) ) ;
	
	adder_subtractor_10bit a_uart_byte_timer(.a(uart_byte_timer), .b(10'd1), .want_subtract(1'b0), .c_out(), .s(n_uart_byte_timer) );
	register_10bit_enable_async r_uart_byte_timer(.clk(clock), .resetn(r_r_uart_byte_timer), .enable(l_r_uart_byte_timer), .select(l_r_uart_byte_timer), .d(n_uart_byte_timer), .q(uart_byte_timer) );
	
	assign usft_timer_done = (uart_byte_timer == uart_byte_spacing) ? 1'b1 : 1'b0;
	
	//	UART
	wire start_tx;
	assign start_tx = (fbc_curr == Send_Byte);
	
	UART_tx tx(
		.clk(clock), 
		.resetn(~reset), 
		.start(start_tx), 
		.cycles_per_databit(uart_cpd), 
		.tx_line(tx_line), 
		.tx_data(uart_input), 
		.tx_done(tx_done)
	);
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(fbc_curr)
			Idle:
			begin
				if(user_data_on_line)
					fbc_next = Load_FIFO;
				else
				begin
					if(user_data_done)
						fbc_next = Release_from_FIFO;
					else
						fbc_next = Idle;
				end
			end
			
			Load_FIFO:
			begin
				fbc_next = Rest_FIFO;
			end
			
			Rest_FIFO:
			begin
				if(user_data_on_line)
					fbc_next = Rest_FIFO;
				else
				begin
					if(user_data_done)
						fbc_next = Release_from_FIFO;
					else
						fbc_next = Idle;
				end
			end
			
			Release_from_FIFO:
			begin
				fbc_next = Send_Byte;
			end
			
			Send_Byte:
			begin
				if(tx_done)
					fbc_next = Rest_Transmission;
				else
					fbc_next = Send_Byte;
			end
			
			Rest_Transmission:
			begin
				if(all_data_sent)
					fbc_next = Done; 
				else
				begin
					if(usft_timer_done)
						fbc_next = Release_from_FIFO;
					else
						fbc_next = Rest_Transmission;
				end
			end
			
			Done:
			begin
				if(reset)
					fbc_next = Idle;
				else
					fbc_next = Done;
			end
			
			default:
			begin
				fbc_next = Idle;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			fbc_curr <= Idle;
		end
		else
		begin
			fbc_curr <= fbc_next;
		end
	end

endmodule

