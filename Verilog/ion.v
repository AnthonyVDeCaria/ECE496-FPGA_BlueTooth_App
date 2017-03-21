/*
	Ming Chen Hsu Jan 20th 
	Ion sensor simulator
	
	Edited - February 9th, Anthony De Caria
	Edited - March 18th, Anthony De Caria
*/

module ion(clock, reset, data_request, data_ack, data_valid, i);
	
	/*
		I/Os
	*/
	// General
	input clock, reset;
	
	// Flags
	input data_request, data_ack;
	output data_valid;
	
	// Other
	output [5:0] i;
	
	/*
		Wires
	*/
	// FSM
	parameter Waiting_for_Request = 1'b0, Waiting_for_ACK = 1'b1;
	reg ion_curr, ion_next;
	
	/*
		Assignments
	*/
	assign data_valid = (ion_curr == Waiting_for_ACK);
	
	/*
		i
	*/
	wire [5:0] n_i;
	wire l_r_i, r_r_i;
	
	assign l_r_i = (ion_curr == Waiting_for_ACK) & data_ack;
	assign r_r_i = ~(reset);

	adder_subtractor_6bit a_i(.a(i), .b(6'd1), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_6bit_enable_async r_i(.clk(clock), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		State Machine for sending and reading
	*/	
	always@(*)
	begin
		case(ion_curr)
			Waiting_for_Request:
			begin
				if(data_request)
					ion_next = Waiting_for_ACK;
				else
					ion_next = Waiting_for_Request;
			end
			Waiting_for_ACK:
			begin
				if(data_ack)
					ion_next = Waiting_for_Request;
				else
					ion_next = Waiting_for_ACK;
			end
		endcase
	end
	
	/*
		Reset or Update ion_curr
	*/
	always@(posedge clock or posedge reset)
	begin
		if(reset) 
			ion_curr <= Waiting_for_Request; 
		else
			ion_curr <= ion_next;
	end

endmodule
