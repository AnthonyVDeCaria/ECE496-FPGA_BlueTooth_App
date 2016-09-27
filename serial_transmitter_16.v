/*
Anthony De Caria - September 26, 2016

This is a module that handles the logic for a serial transmitter
where the serializer is 16 bits.
*/

module serial_transmitter_16 (clock, resetn, start, done, data, more_data, line_out);
	input clock, resetn;
	input start;
	input [15:0] data;
	input more_data;

	output line_out;
	
	output done;
	
	parameter Idle = 3'b000, Load = 3'b001, Transmission = 3'b010, Breather = 3'b011, Complete = 3'b100;
	reg [2:0] curr, next;

	wire s_t_b, f_t_b, reset;
	assign s_t_b = (curr == Transmission);
	assign reset = ~(~resetn | (curr == Complete) | (curr == Idle));

	serializer_16bit byte_sender(.clock(clock), .resetn(reset), .data(data), .start_transmission(s_t_b), .finish_transmission(f_t_b), .tx(line_out) );
	
	assign done = (curr == Complete);

	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			Idle: if(start) next = Load; else next = Idle;
			Load: next = Transmission;
			Transmission: 
			begin
				if(!f_t_b) next = Transmission;
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

