/*
Anthony De Caria - September 26, 2016

This is a 16-bit serializer to send data.
*/

module serializer_16bit (clock, resetn, data, start_transmission, finish_transmission, tx);
	input clock, resetn, start_transmission;
	input [15:0] data;

	output finish_transmission, tx;
	
	parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, SD = 2'b11;
	reg [1:0] curr, next;
	
	wire [15:0] q_out;
	
	wire i_load, i_enable, i_reset;
	wire [4:0] i_out, a_out;
	assign i_load = (curr == S2);
	assign i_enable = (curr == S2);
	assign i_reset = ~(~resetn | (curr == S0) | (curr == SD));
	
	wire s_load, s_enable, s_reset;
	assign s_load = (curr == S1);
	assign s_enable = (curr == S1) | (curr == S2);
	assign s_reset = ~(~resetn | (curr == S0) | (curr == SD));

	register_4bit_enable_async i(.clk(clock), .resetn(i_reset), .enable(i_enable), .select(i_load), .d(a_out), .q(i_out) );
	adder_subtractor_4bit a_i(.a(i_out), .b(5'b00001), .want_subtract(1'b0), .c_out(), .s(a_out) );
	
	Shift_Register_8_Enable_Async_OneLoad test_reg(.clk(clock), .resetn(s_reset), .enable(s_enable), .select(s_load), .d(data), .q(q_out) );
	
	assign finish_transmission = (curr == SD);
	assign tx = q_out[15];
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			S0: if(start_transmission) next = S1; else next = S0;
			S1: next = S2;
			S2: if(!a_out[4]) next = S2; else next = SD;
			SD: if(start_transmission) next = SD; else next = S0;
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= S0; else curr <= next;
	end
	
endmodule
