/*
	Ming Chen Hsu Jan 20th 
	Ion sensor simulator
*/

module ion(clock, resetn, ready, data_out);

	input clock, resetn;
	output [7:0] ready;
	output [109:0] data_out;

	//integer data_file; // file handler
	//integer scan_file; // file handler

	reg [109:0] extracted_data; 
	parameter timer_cap = 16'hFFFF; //16'd500000;

	/*
	`define NULL 0  
	
		Reading from file
	
	initial 
	begin
  		//data_file = $fopen("ch1.dat", "r");
		data_file = $readmemb("ch1.dat", "r");
  		if (data_file == `NULL) 
		begin
    			$display("data_file handle was NULL");
    			$finish;
  		end
	end
	*/
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
	
	reg [5:0] index;

	always @(*) 
	begin
		if (curr == Read_Packet)
		begin
			index = index + 6'b0000001;
  		end
	end

	

	always @(*)
	begin
		case(index)
			6'b000000:
			begin
				extracted_data = 110'd770255177100881239175611014272433;
			end
			6'b000001:
			begin
				extracted_data = 110'd77125517610092523917379114272433;
			end 
			6'b000010:
			begin
				extracted_data = 110'd770255177100962239176327514272433;
			end 
			6'b000011:
			begin
				extracted_data = 110'd7712551771001011239172457414272433;
			end 
			6'b000100:
			begin
				extracted_data = 110'd7712551851001045239174001914272433;
			end 
			6'b000101:
			begin
				extracted_data = 110'd7712551861001094239175052714272433;
			end 
			6'b000110:
			begin
				extracted_data = 110'd7702551771001136239176017714272433;
			end 
			6'b000111:
			begin
				extracted_data = 110'd7702551781001178239174722214272433;
			end 
			6'b001000:
			begin
				extracted_data = 110'd7702551771001220239174275614272433;
			end
			6'b001001:
			begin
				extracted_data = 110'd7702551771001262239176196114272433;
			end
			6'b001010:
			begin
				extracted_data = 110'd77025518310013042391799314272433;
			end
			6'b001011:
			begin
				extracted_data = 110'd7702551781001346239171767514272433;
			end
			6'b001100:
			begin
				extracted_data = 110'd7702551781001380239175747314272433;
			end
			6'b001101:
			begin
				extracted_data = 110'd7702551771001430239175322414272433;
			end
			6'b001110:
			begin
				extracted_data = 110'd7702551781001472239176119514272433;
			end
			6'b001111:
			begin
				extracted_data = 110'd7712551851001514239174699614272433;
			end
			6'b010000:
			begin
				extracted_data = 110'd77125517710015562391714514272433;
			end
			6'b010001:
			begin
				extracted_data = 110'd7712551781001598239172119114272433;
			end
			6'b010010:
			begin
				extracted_data = 110'd77025517710016352391761014272433;
			end
			6'b010011:
			begin
				extracted_data = 110'd771255177100167923917408914272433;
			end
			6'b010100:
			begin
				extracted_data = 110'd7702551781001729239172068514272433;
			end
			6'b0010101:
			begin
				extracted_data = 110'd7712551771001766239171045914272433;
			end
			6'b0010110:
			begin
				extracted_data = 110'd7712551781001815239175776614272433;
			end
			6'b010111:
			begin
				extracted_data = 110'd7702551771001857239174823614272433;
			end
			6'b011000:
			begin
				extracted_data = 110'd7712551771001903239173645314272433;
			end
			6'b011001:
			begin
				extracted_data = 110'd7702551831001945239172297714272433;
			end
			6'b011010:
			begin
				extracted_data = 110'd7702551771001987239171304514272433;
			end
			6'b011011:
			begin
				extracted_data = 110'd7702551771002033239174099314272433;
			end
			6'b011100:
			begin
				extracted_data = 110'd7712551771002075239174531014272433;
			end
			6'b011101:
			begin
				extracted_data = 110'd7712551771002108239176298814272433;
			end
			6'b011110:
			begin
				extracted_data = 110'd7712551771012162239175003214272433;
			end
			6'b011111:
			begin
				extracted_data = 110'd7712551781002199239172231214272433;
			end
			6'b100000:
			begin
				extracted_data = 110'd7702551771002248239174850714272433;
			end
			6'b100001:
			begin
				extracted_data = 110'd770255178101228623917361514272433;
			end
			6'b100010:
			begin
				extracted_data = 110'd7712551771002335239173104314272433;
			end
			6'b100011:
			begin
				extracted_data = 110'd7702551771002381239176515114272433;
			end
			6'b100100:
			begin
				extracted_data = 110'd7702551771002423239174512314272433;
			end
			6'b100101:
			begin
				extracted_data = 110'd7702551771002465239174729714272433;
			end
			6'b100110:
			begin
				extracted_data = 110'd770255177100249823917137414272433;
			end
			6'b100111:
			begin
				extracted_data = 110'd770255180100254823917851014272433;
			end
			6'b101000:
			begin
				extracted_data = 110'd771255178100258123917376614272433;
			end
			6'b101001:
			begin
				extracted_data = 110'd7702551781002631239171567814272433;
			end
			6'b101010:
			begin
				extracted_data = 110'd7702551781002670239174614414272433;
			end
			6'b101011:
			begin
				extracted_data = 110'd7712551761002712239174327514272433;
			end
			6'b101100:
			begin
				extracted_data = 110'd771255185100275823917640214272433;
			end
			6'b101101:
			begin
				extracted_data = 110'd7702551781002800239172832414272433;
			end
			6'b101110:
			begin
				extracted_data = 110'd7702551771002842239174112314272433;
			end
			6'b101111:
			begin
				extracted_data = 110'd7702551781002888239172575414272433;
			end
			6'b110000:
			begin
				extracted_data = 110'd7712551771002926239174375414272433;
			end
			6'b110001:
			begin
				extracted_data = 110'd7702551771002973239173775814272433;
			end
			6'b110010:
			begin
				extracted_data = 110'd7702551771003015239176236414272433;
			end
			6'b110011:
			begin
				extracted_data = 110'd7712551771003057239174820014272433;
			end
			6'b110100:
			begin
				extracted_data = 110'd7712551781003100239175627614272433;
			end
			6'b110101:
			begin
				extracted_data = 110'd7702551781003146239175993314272433;
			end
			6'b110110:
			begin
				extracted_data = 110'd7702551771013184239173025014272433;
			end
			6'b110111:
			begin
				extracted_data = 110'd7712551781003233239174996614272433;
			end
			6'b111000:
			begin
				extracted_data = 110'd77125517710032672391766214272433;
			end
			6'b111001:
			begin
				extracted_data = 110'd7712551781003308239174703114272433;
			end
			6'b111010:
			begin
				extracted_data = 110'd771255178100334923917273414272433;
			end
			6'b111011:
			begin
				extracted_data = 110'd7702551771013390239173612114272433;
			end
			6'b111100:
			begin
				extracted_data = 110'd0;
			end
			6'b111101:
			begin
				extracted_data = 110'd0;
			end
			6'b111110:
			begin
				extracted_data = 110'd0;
			end
			6'b111111:
			begin
				extracted_data = 110'd0;
			end
			default:
				extracted_data = 110'd0;
    
		endcase
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
