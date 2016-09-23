/*
Anthony De Caria - September 21, 2016

This is a module to send a larger chunk of data out serially for ECE496.
This module selects a byte of data to send from a 32 byte chain and sends it to serializer_8bit to send.
Why 32 bytes? Cause hopefully that's all we'll need. 
*/

module ece496_fpga_transmission (clock, resetn, start, done, data, data_size, line_out);
	input clock, resetn;
	input start;
	input [255:0] data;
	input [5:0] data_size;

	output line_out;
	
	output done;
	
	parameter Idle = 3'b000, Initialize = 3'b001, Load_Byte = 3'b010, Byte_Transmission = 3'b011, Restart_BT = 3'b100, Complete = 3'b101;
	reg [2:0] curr, next;

	wire [7:0] data_byte;

	wire s_t_b, f_t_b;
	assign s_t_b = (curr == Byte_Transmission);

	integer i, n; 
	always @(*)
	begin
		if ((curr == Idle) | (curr == Complete))
		begin
			i = 0;
			n = 0;
		end
		if (curr == Initialize)
		begin
    		n = data_size;
		end
		if (curr == Restart_BT)
		begin
			i = i + 1;
		end
	end

	wire b_reset, b_enable, b_load;
	assign b_reset = ~((curr == Idle) | (curr == Complete) | (curr == Restart_BT));
	assign b_enable = (curr == Load_Byte);
	assign b_load = (curr == Load_Byte);
	register_8bit_enable_async r_byte(.clk(clock), .resetn(b_reset), .enable(b_enable), .select(b_load), .d(data[8*i +: 8]), .q(data_byte) );

	serializer_8bit byte_sender(.clock(clock), .resetn(resetn), .data(data_byte), .start_transmission(s_t_b), .finish_transmission(f_t_b), .tx(line_out) );
	
	assign done = (curr == Complete);

	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			Idle: if(start) next = Initialize; else next = Idle;
			Initialize: next = Load_Byte;
			Load_Byte: next = Byte_Transmission;
			Byte_Transmission: 
			begin
				if(!f_t_b) next = Load_Byte;
				else next = Restart_BT;
			end
			Restart_BT:
			begin
				if(i < n) next = Load_Byte;
				else next = Complete;
			end
			Complete: if(start) next = Complete; else next = Idle;
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= Idle; else curr <= next;
	end
	
endmodule

