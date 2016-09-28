/*
Anthony De Caria - September 27, 2016

This is a 16-bit deserializer to send line_in.
*/

module deserializer_16bit (clock, resetn, line_in, start_receiving, finish_receiving, data_out);
	input clock, resetn, start_receiving;
	input line_in;

	output finish_receiving;
	output [15:0] data_out;
	
	parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, SD = 2'b11;
	reg [1:0] curr, next;
	
	wire i_load, i_enable, i_reset;
	wire [4:0] i_out, a_out;
	assign i_load = (curr == S2);
	assign i_enable = (curr == S2);
	assign i_reset = ~(~resetn | (curr == S0) | (curr == SD));
	
	wire r_enable, r_reset;
	assign r_enable = (curr == S1) | (curr == S2);
	assign r_reset = ~(~resetn | (curr == S0));

	register_5bit_enable_async i(.clk(clock), .resetn(i_reset), .enable(i_enable), .select(i_load), .d(a_out), .q(i_out) );
	adder_subtractor_5bit a_i(.a(i_out), .b(5'b00001), .want_subtract(1'b0), .c_out(), .s(a_out) );
	
	Shift_Register_16_Enable_Async_OneLoad data_out_reg(.clk(clock), .resetn(r_reset), .enable(r_enable), .select(1'b0), .d(line_in), .q(data_out) );
	
	assign finish_receiving = (curr == SD);
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			S0: if(start_receiving) next = S1; else next = S0;
			S1: next = S2;
			S2: if(!a_out[4]) next = S2; else next = SD;
			SD: if(start_receiving) next = SD; else next = S0;
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= S0; else curr <= next;
	end
	
endmodule
