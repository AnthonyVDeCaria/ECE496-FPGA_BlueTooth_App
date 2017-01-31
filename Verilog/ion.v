/*
	Ming Chen Hsu Jan 20th 
	Ion sensor simulator
*/

module ion(clock, resetn, ready, data_out, extracted_data, index);

	input clock, resetn;
	output [7:0] ready;
	output [109:0] data_out;

	//integer data_file; // file handler
	//integer scan_file; // file handler

	output reg [109:0] extracted_data; 
	parameter timer_cap = 16'hFFFF; //16'd500000;

	wire [15:0] timer, n_timer;
	wire l_r_timer, r_r_timer, timer_done;
	
	assign l_r_timer = (curr == Idle);
	assign r_r_timer = ~( ~resetn | (curr == Read_Packet) );
	
	adder_subtractor_16bit a_timer(.a(timer), .b(16'h0001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_16bit_enable_async r_timer(.clk(clock), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	assign timer_done = (timer == timer_cap) ? 1'b1 : 1'b0;

	/*
		FSM Wires
	*/
	parameter Idle = 2'b00, Read_Packet = 2'b01, Send_Packet = 2'b10;
	reg [1:0] curr, next;
	output reg [5:0] index = 6'd0;
	
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
					next <= Read_Packet;
					index <= index + 6'b0;
				end
				else 
				begin
					next <= Idle;
					index <= index + 6'b0;
				end
			end 
			Read_Packet:
			begin
				next <= Send_Packet;
				index <= index + 6'b1;
			end
			Send_Packet:
			begin
				next <= Idle;
				index <= index + 6'b0;
			end
			default: 
			begin
				next <= Idle;
				index <= 6'b0;
			end
		endcase
	end
	
	//reading data

	always @(*)
	begin
		case(index)
			6'b000000:
			begin
				extracted_data = 110'b1;
				//extracted_data[6:0] = 7'd77;
				//extracted_data[7] = 1'd0;
				//extracted_data[15:8] = 8'd255;
				//extracted_data[23:16] = 8'd177;
				//extracted_data[31:24] = 8'd100;
				//extracted_data[47:32] = 16'd881;
				//extracted_data[55:48] = 8'd239;
				//extracted_data[63:56] = 8'd17;
				//extracted_data[79:64] = 16'd56110;
				//extracted_data[85:80] = 6'd1;
				//extracted_data[109:86] = 24'd4272433;		
			end
			6'b000001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd176;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd925;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd3791;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end 
			6'b000010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd962;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd63275;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end 
			6'b000011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1011;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd24574;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end 
			6'b000100:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd185;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1045;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd40019;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end 
			6'b000101:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd186;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1094;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd50527;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end 
			6'b000110:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1136;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd60177;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end 
			6'b000111:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1178;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd47222;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end 
			6'b001000:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1220;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd42756;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b001001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1262;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd61961;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b001010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd183;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1304;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd7993;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b001011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1346;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd17675;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b001100:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1380;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd57473;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b001101:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1430;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd53224;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b001110:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1472;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd61195;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b001111:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd185;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1514;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd46996;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b010000:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1556;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd145;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b010001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1598;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd21191;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b010010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1635;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd610;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b010011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1679;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd4089;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b010100:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1729;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd20685;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b0010101:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1766;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd10459;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b0010110:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1815;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd57766;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b010111:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1857;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd48236;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011000:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1903;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd36453;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd183;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1945;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd22977;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd1987;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd13045;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2033;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd40993;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011100:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2075;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd45310;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011101:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2108;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd62988;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011110:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd101;
				extracted_data[47:32] = 16'd2162;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd50032;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b011111:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2199;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd22312;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100000:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2248;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd48507;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd101;
				extracted_data[47:32] = 16'd2286;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd3615;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2335;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd31043;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2381;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd65151;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100100:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2423;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd45123;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100101:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2465;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd47297;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100110:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2498;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd1374;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b100111:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd180;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2548;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd8510;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101000:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2581;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd3766;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2631;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd15678;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2670;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd46144;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd176;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2712;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd43275;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101100:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd185;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2758;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd6402;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101101:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2800;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd28324;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101110:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2842;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd41123;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b101111:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2888;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd25754;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110000:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2926;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd43754;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd2973;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd37758;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3015;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd62364;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3057;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd48200;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110100:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3100;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd56276;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110101:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3146;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd59933;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110110:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd101;
				extracted_data[47:32] = 16'd3184;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd30250;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b110111:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3233;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd49966;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b111000:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3267;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd662;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b111001:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3308;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd47031;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b111010:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd1;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd178;
				extracted_data[31:24] = 8'd100;
				extracted_data[47:32] = 16'd3349;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd2734;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
			end
			6'b111011:
			begin
				extracted_data[6:0] = 7'd77;
				extracted_data[7] = 1'd0;
				extracted_data[15:8] = 8'd255;
				extracted_data[23:16] = 8'd177;
				extracted_data[31:24] = 8'd101;
				extracted_data[47:32] = 16'd3390;
				extracted_data[55:48] = 8'd239;
				extracted_data[63:56] = 8'd17;
				extracted_data[79:64] = 16'd36121;
				extracted_data[85:80] = 6'd1;
				extracted_data[109:86] = 24'd4272433;
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
	//mux_2_110bit m_data_out(.data0(110'd0), .data1(extracted_data), .sel((curr == Send_Packet)), .result(data_out));
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
