/*
	Ming Chen Hsu Jan 20th 
	Ion sensor simulator
*/

module ion(clock, resetn, ready, data_out);

	input clock, resetn;
	output [7:0] ready;
	output [109:0] data_out;

	integer data_file; // file handler
	integer scan_file; // file handler

	reg [109:0] extracted_data; 
	parameter timer_cap = 16'hFFFF; //16'd500000;

	`define NULL 0  
	/*
		Reading from file
	*/
	initial 
	begin
  		data_file = $fopen("ch1.dat", "r");
  		if (data_file == `NULL) 
		begin
    			$display("data_file handle was NULL");
    			$finish;
  		end
	end

	/*
		Timer (timer_cap 500,000)
	*/
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (curr == Idle);
	assign r_r_timer = ~( ~resetn | (curr == Read_Packet) );
	
	adder_subtractor_16bit a_timer(.a(timer), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_16bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;

	/*
		FSM Wires
	*/
	parameter Idle = 3'b000, Read_Packet = 3'b001, Send_Packet = 3'b010;
	reg [2:0] curr, next;
	
	/*
		State Machine for sending and reading
	*/	
	always@(*)
	begin
		case(curr)
			Idle: 
			begin
				if (timer_done)
				begin
					next = Read_Packet;
				end
				else 
					next = Idle;
			end 
			Read_Packet:
			begin
				next = Send_Packet;
			end
			Send_Packet:
			begin
				next = Idle;
			end
			default: 
				next = Idle;
		endcase
	end
	
	//reading data

	always @(*) 
	begin
		if (curr == Read_Packet)
		begin
  			scan_file = $fscanf(data_file, "%d\n", extracted_data); 
  			if ($feof(data_file)) 
			begin
    				extracted_data = 110'd0;
			end
  		end
	end

	//data_read begin sent out
	assign data_out = (curr == Send_Packet) ? extracted_data : 110'd0;
	assign ready = (curr == Send_Packet) ? 8'b00000001 : 8'b00000000;
	/*
		Reset or Update Curr
	*/
	always@(posedge clock or negedge resetn)
	begin
		if(!resetn) curr <= Idle; else curr <= next;
	end

endmodule
