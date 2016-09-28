/*
Anthony De Caria - September 27, 2016

This is a module that handles the logic for a serial receiver
where the deserializer is 16 bits.
*/

module serial_receiver_16 (clock, resetn, start, done, data, more_data, line_in);
	input clock, resetn;
	input start;
	input line_in;
	input more_data;

	output [15:0] data;
	output done;
	
	parameter Idle = 3'b000, Load = 3'b001, Receive = 3'b010, Breather = 3'b011, Complete = 3'b100;
	reg [2:0] curr, next;

	wire s_r, f_r, reset;
	assign s_r = (curr == Receive);
	assign reset = ~(~resetn | (curr == Complete) | (curr == Idle));

	deserializer_16bit receiver(.clock(clock), .resetn(reset), .data_out(data), .start_receiving(s_r), .finish_receiving(f_r), .line_in(line_in) );
	
	assign done = (curr == Complete);

	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			Idle: if(start) next = Load; else next = Idle;
			Load: next = Receive;
			Receive: 
			begin
				if(!f_r) next = Receive;
				else next = Breather;
			end
			Breather:
			begin
				if(more_data) next = Load;
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

