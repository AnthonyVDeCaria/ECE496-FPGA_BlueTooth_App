/*
	Anthony De Caria - October 16, 2016

	This module creates a UART transmittor.
*/

module UART_tx(clk, resetn, start, cycles_per_databit, tx_line, tx_data, tx_done);
	/*
		I/Os
	*/
	input clk, resetn, start;	
	input [9:0] cycles_per_databit; //Allows for 1024 cycles between each databit
	input [7:0] tx_data;

	output tx_done;
	output tx_line;
	
	/*
		FSM
	*/
	reg [2:0] curr, next;
	parameter Idle = 3'b000, Prepare_Data = 3'b001, Send_Data = 3'b010, Add_i = 3'b011, Done = 3'b100;
	
	/*
		Timer 
	*/
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer;
	wire at_cpd;
	
	assign l_r_timer = ((curr == Send_Data) & (~at_cpd));
	assign r_r_timer = ~(~resetn | (curr == Idle) | (curr == Add_i) ) ;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clk), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign at_cpd = (timer == cycles_per_databit) ? 1'b1: 1'b0;	
	
	/*
		i
	*/
	wire [3:0] i, n_i;
	wire l_r_i, r_r_i;
	
	assign l_r_i = (curr == Add_i);
	assign r_r_i = ~(~resetn | (curr == Idle) );
	
	adder_subtractor_4bit a_i(.a(i), .b(4'b0001), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_4bit_enable_async r_i(.clk(clk), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		Sending Data
	*/
	wire [9:0] din, dout;
	wire l_r_safety;
	
	assign din[9] = 1'b1;
	assign din[8:1] = tx_data[7:0];
	assign din[0] = 1'b0;
	
	assign l_r_safety = (curr == Prepare_Data);
	
	register_10bit_enable_async r_safety(.clk(clk), .resetn(resetn), .enable(l_r_safety), .select(l_r_safety), .d(din), .q(dout) );
	
	reg current_dout;
	always@(*)
	begin
		if(curr == Send_Data)
			current_dout = dout[i];
	end
	
	wire dout_select;
	assign dout_select = (curr == Send_Data) | (curr == Add_i);
	mux_2_1bit m_dout(.data0(1'b1), .data1(current_dout), .sel(dout_select), .result(tx_line) );
	
	/*
		FSM
	*/
	
	always@(*)
	begin
		case(curr)
			Idle: 
			begin
				if(start)
					next = Prepare_Data;
				else
					next = Idle;
			end
			
			Prepare_Data:
			begin
				next = Send_Data;
			end
			
			Send_Data:
			begin
				if(!at_cpd)
					next = Send_Data;
				else
					next = Add_i;
			end
			
			Add_i:
			begin
				if(i[3] == 1'b1 && i[0] == 1'b1)
					next = Done;
				else
					next = Send_Data;
			end
			
			Done:
			begin
				if(start)
					next = Done;
				else
					next = Idle;
			end
		endcase
	end
	
	always@(posedge clk or negedge resetn)
	begin
		if(!resetn) 
			curr <= Idle; 
		else 
			curr <= next;
	end
	
	assign tx_done = (curr == Done);
	
endmodule

