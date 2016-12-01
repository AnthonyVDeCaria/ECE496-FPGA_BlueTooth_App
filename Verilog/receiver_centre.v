/*
	Anthony De Caria - November 29, 2016

	This module handles the receiver logic for the ECE496-FPGA_Bluetooth_App
*/

module receiver_centre(clk, resetn, rx_data, at_complete);
	/*
		I/Os
	*/
	input clk, resetn;	
	input [7:0] rx_data;

	output rx_data_valid, at_complete;
	
	/*
		Wires
	*/
	
	/*
		FSM Wires
	*/
	reg [2:0] curr, next;
	parameter Idle = 3'b000, Collect_AT = 3'b001, Stop_Sending = 3'b010, Implement_Changes = 3'b011, Done = 3'b100;
	
	/*
		Receiver Hardware
	*/
	wire [7:0] orders_from_app;
	wire r_r_first, r_r_data, r_r_last;
	wire e_r_first, e_r_data, e_r_last;
	wire l_r_first, l_r_data, l_r_last;
	
	register_8bit_enable_async r_first(.clk(clock), .resetn(r_r_first), .enable(e_r_first), .select(l_r_first), .d(RFIFO_in), .q() );
	register_8bit_enable_async r_data(.clk(clock), .resetn(r_r_data), .enable(e_r_data), .select(l_r_data), .d(RFIFO_in), .q(orders_from_app) );
	register_8bit_enable_async r_last(.clk(clock), .resetn(r_r_last), .enable(e_r_last), .select(l_r_last), .d(RFIFO_in), .q() );
	
	
	/*
		FSM
	*/
	always@(*)
	begin
		
	end
	
	always@(posedge clk or negedge resetn)
	begin
		if(!resetn) 
			curr <= Idle; 
		else 
			curr <= next;
	end
	
endmodule

