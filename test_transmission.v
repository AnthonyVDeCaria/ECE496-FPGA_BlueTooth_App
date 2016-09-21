/*
Anthony De Caria - September 20, 2016

This is a test module for transmitting a byte serially.
*/

module test_transmission (clock, resetn, start_transmission, finish_transmission, tx);
	input clock, resetn, start_transmission;
	output finish_transmission, tx;
	
	wire [7:0] q_out;
	wire s_load, s_enable, s_reset;
	wire i_load, i_enable, i_reset;
	wire [3:0] i_out, a_out;
	
	parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, SD = 2'b11;
	reg [1:0] curr, next;
	
	assign i_load = (curr == S2);
	assign i_enable = (curr == S2);
	assign i_reset = ~(~resetn | (curr == S0) | (curr == SD));
	
	assign s_load = (curr == S1);
	assign s_enable = (curr == S1) | (curr == S2);
	assign s_reset = ~(~resetn | (curr == S0) | (curr == SD));

	register_4bit_enable_async i(.clk(clock), .resetn(i_reset), .enable(i_enable), .select(i_load), .d(a_out), .q(i_out) );
	adder_subtractor_4bit a_i(.a(i_out), .b(4'b0001), .want_subtract(1'b0), .c_out(), .s(a_out) );
	
	Shift_Register_8_Enable_Async_OneLoad test_reg(.clk(clock), .resetn(s_reset), .enable(s_enable), .select(s_load), .d(8'h8F), .q(q_out) );
	
	assign tx = q_out[7];
	assign finish_transmission = (curr == SD);
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(curr)
			S0: if(start_transmission) next = S1; else next = S0;
			S1: next = S2;
			S2: if(!a_out[3]) next = S2; else next = SD;
			SD: if(start_transmission) next = SD; else next = S0;
		endcase
	end
	
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= S0; else curr <= next;
	end
	
endmodule
