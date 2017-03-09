/*
	Anthony De Caria - February 9, 2017
	
	A test Data-stream 0
*/

module DS0(index, data);

	/*
		I/O
	*/
	input [5:0] index;
	output reg [109:0] data; 
	
	/*
		Data
	*/
	always @(*)
	begin
		case(index)
			6'b000000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd881;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd56110;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;		
			end
			6'b000001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd176;
				data[31:24] = 8'd100;
				data[47:32] = 16'd925;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd3791;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end 
			6'b000010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd962;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd63275;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end 
			6'b000011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1011;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd24574;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end 
			6'b000100:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd185;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1045;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd40019;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end 
			6'b000101:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd186;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1094;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd50527;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end 
			6'b000110:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1136;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd60177;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end 
			6'b000111:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1178;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd47222;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end 
			6'b001000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1220;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd42756;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b001001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1262;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd61961;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b001010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd183;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1304;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd7993;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b001011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1346;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd17675;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b001100:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1380;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd57473;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b001101:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1430;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd53224;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b001110:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1472;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd61195;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b001111:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd185;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1514;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd46996;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b010000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1556;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd145;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b010001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1598;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd21191;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b010010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1635;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd610;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b010011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1679;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd4089;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b010100:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1729;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd20685;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b0010101:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1766;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd10459;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b0010110:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1815;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd57766;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b010111:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1857;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd48236;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1903;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd36453;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd183;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1945;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd22977;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd1987;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd13045;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2033;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd40993;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011100:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2075;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd45310;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011101:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2108;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd62988;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011110:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd101;
				data[47:32] = 16'd2162;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd50032;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b011111:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2199;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd22312;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2248;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd48507;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd101;
				data[47:32] = 16'd2286;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd3615;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2335;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd31043;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2381;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd65151;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100100:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2423;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd45123;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100101:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2465;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd47297;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100110:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2498;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd1374;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b100111:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd180;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2548;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd8510;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2581;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd3766;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2631;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd15678;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2670;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd46144;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd176;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2712;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd43275;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101100:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd185;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2758;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd6402;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101101:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2800;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd28324;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101110:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2842;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd41123;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b101111:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2888;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd25754;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2926;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd43754;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd2973;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd37758;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3015;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd62364;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3057;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd48200;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110100:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3100;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd56276;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110101:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3146;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd59933;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110110:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd101;
				data[47:32] = 16'd3184;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd30250;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b110111:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3233;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd49966;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b111000:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3267;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd662;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b111001:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3308;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd47031;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b111010:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd1;
				data[15:8] = 8'd255;
				data[23:16] = 8'd178;
				data[31:24] = 8'd100;
				data[47:32] = 16'd3349;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd2734;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			6'b111011:
			begin
				data[6:0] = 7'd77;
				data[7] = 1'd0;
				data[15:8] = 8'd255;
				data[23:16] = 8'd177;
				data[31:24] = 8'd101;
				data[47:32] = 16'd3390;
				data[55:48] = 8'd239;
				data[63:56] = 8'd17;
				data[79:64] = 16'd36121;
				data[85:80] = 6'd1;
				data[109:86] = 24'd4272433;
			end
			//change all data below
			6'b111100:
			begin
                data[6:0] = 7'd77;
                data[7] = 1'd0;
                data[15:8] = 8'd255;
                data[23:16] = 8'd177;
                data[31:24] = 8'd101;
                data[47:32] = 16'd3431;
                data[55:48] = 8'd239;
                data[63:56] = 8'd17;
                data[79:64] = 16'd3721;
                data[85:80] = 6'd1;
                data[109:86] = 24'd4272433;
			end
			6'b111101:
			begin
				data[6:0] = 7'd77;
                data[7] = 1'd0;
                data[15:8] = 8'd255;
                data[23:16] = 8'd177;
                data[31:24] = 8'd101;
                data[47:32] = 16'd3472;
                data[55:48] = 8'd239;
                data[63:56] = 8'd17;
                data[79:64] = 16'd36121;
                data[85:80] = 6'd1;
                data[109:86] = 24'd4272433;
			end
			6'b111110:
			begin
				data[6:0] = 7'd77;
                data[7] = 1'd0;
                data[15:8] = 8'd255;
                data[23:16] = 8'd177;
                data[31:24] = 8'd101;
                data[47:32] = 16'd3513;
                data[55:48] = 8'd239;
                data[63:56] = 8'd17;
                data[79:64] = 16'd31121;
                data[85:80] = 6'd1;
                data[109:86] = 24'd4272433;
			end
			6'b111111:
			begin
				data[6:0] = 7'd77;
                data[7] = 1'd0;
                data[15:8] = 8'd255;
                data[23:16] = 8'd177;
                data[31:24] = 8'd101;
                data[47:32] = 16'd3554;
                data[55:48] = 8'd239;
                data[63:56] = 8'd17;
                data[79:64] = 16'd3611;
                data[85:80] = 6'd1;
                data[109:86] = 24'd4272433;
			end
			default:
				data = 110'd0;
		endcase
	end
endmodule
