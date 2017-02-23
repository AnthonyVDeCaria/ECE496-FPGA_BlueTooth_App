/*
Feb 23, 2017 Ming

This module is a 32 bit adder/subtractor.

It will output B - A if desired.
*/

module adder_subtractor_32bit(a, b, want_subtract, c_out, s);

  /*
   * I/Os
   */
  input [31:0] a, b;
  input want_subtract;		// If want_subtract == 1, we subtract. Otherwise we add.
  output [31:0] s;
  output c_out;

  wire [30:0]c;
  wire [31:0]a_adder;

  mux_2_1bit m_0( .data0(a[0]), .data1(~a[0]), .sel(want_subtract), .result(a_adder[0]) );
  mux_2_1bit m_1( .data0(a[1]), .data1(~a[1]), .sel(want_subtract), .result(a_adder[1]) );
  mux_2_1bit m_2( .data0(a[2]), .data1(~a[2]), .sel(want_subtract), .result(a_adder[2]) );
  mux_2_1bit m_3( .data0(a[3]), .data1(~a[3]), .sel(want_subtract), .result(a_adder[3]) );
  mux_2_1bit m_4( .data0(a[4]), .data1(~a[4]), .sel(want_subtract), .result(a_adder[4]) );
  mux_2_1bit m_5( .data0(a[5]), .data1(~a[5]), .sel(want_subtract), .result(a_adder[5]) );
  mux_2_1bit m_6( .data0(a[6]), .data1(~a[6]), .sel(want_subtract), .result(a_adder[6]) );
  mux_2_1bit m_7( .data0(a[7]), .data1(~a[7]), .sel(want_subtract), .result(a_adder[7]) );
  mux_2_1bit m_8( .data0(a[8]), .data1(~a[8]), .sel(want_subtract), .result(a_adder[8]) );
  mux_2_1bit m_9( .data0(a[9]), .data1(~a[9]), .sel(want_subtract), .result(a_adder[9]) );

  mux_2_1bit m_10( .data0(a[10]), .data1(~a[10]), .sel(want_subtract), .result(a_adder[10]) );
  mux_2_1bit m_11( .data0(a[11]), .data1(~a[11]), .sel(want_subtract), .result(a_adder[11]) );
  mux_2_1bit m_12( .data0(a[12]), .data1(~a[12]), .sel(want_subtract), .result(a_adder[12]) );
  mux_2_1bit m_13( .data0(a[13]), .data1(~a[13]), .sel(want_subtract), .result(a_adder[13]) );
  mux_2_1bit m_14( .data0(a[14]), .data1(~a[14]), .sel(want_subtract), .result(a_adder[14]) );
  mux_2_1bit m_15( .data0(a[15]), .data1(~a[15]), .sel(want_subtract), .result(a_adder[15]) );

  mux_2_1bit m_16( .data0(a[16]), .data1(~a[16]), .sel(want_subtract), .result(a_adder[16]) );
  mux_2_1bit m_17( .data0(a[17]), .data1(~a[17]), .sel(want_subtract), .result(a_adder[17]) );
  mux_2_1bit m_18( .data0(a[18]), .data1(~a[18]), .sel(want_subtract), .result(a_adder[18]) );
  mux_2_1bit m_19( .data0(a[19]), .data1(~a[19]), .sel(want_subtract), .result(a_adder[19]) );
  mux_2_1bit m_20( .data0(a[20]), .data1(~a[20]), .sel(want_subtract), .result(a_adder[20]) );
  mux_2_1bit m_21( .data0(a[21]), .data1(~a[21]), .sel(want_subtract), .result(a_adder[21]) );
  mux_2_1bit m_22( .data0(a[22]), .data1(~a[22]), .sel(want_subtract), .result(a_adder[22]) );
  mux_2_1bit m_23( .data0(a[23]), .data1(~a[23]), .sel(want_subtract), .result(a_adder[23]) );
  mux_2_1bit m_24( .data0(a[24]), .data1(~a[24]), .sel(want_subtract), .result(a_adder[24]) );
  mux_2_1bit m_25( .data0(a[25]), .data1(~a[25]), .sel(want_subtract), .result(a_adder[25]) );

  mux_2_1bit m_26( .data0(a[26]), .data1(~a[26]), .sel(want_subtract), .result(a_adder[26]) );
  mux_2_1bit m_27( .data0(a[27]), .data1(~a[27]), .sel(want_subtract), .result(a_adder[27]) );
  mux_2_1bit m_28( .data0(a[28]), .data1(~a[28]), .sel(want_subtract), .result(a_adder[28]) );
  mux_2_1bit m_29( .data0(a[29]), .data1(~a[29]), .sel(want_subtract), .result(a_adder[29]) );
  mux_2_1bit m_30( .data0(a[30]), .data1(~a[30]), .sel(want_subtract), .result(a_adder[30]) );
  mux_2_1bit m_31( .data0(a[31]), .data1(~a[31]), .sel(want_subtract), .result(a_adder[31]) );

  full_adder_1bit a_0( .a(a_adder[0]), .b(b[0]), .c_in(want_subtract), .c_out(c[0]), .s(s[0]) );

  full_adder_1bit a_1( .a(a_adder[1]), .b(b[1]), .c_in(c[0]), .c_out(c[1]), .s(s[1]) );
  full_adder_1bit a_2( .a(a_adder[2]), .b(b[2]), .c_in(c[1]), .c_out(c[2]), .s(s[2]) );
  full_adder_1bit a_3( .a(a_adder[3]), .b(b[3]), .c_in(c[2]), .c_out(c[3]), .s(s[3]) );
  full_adder_1bit a_4( .a(a_adder[4]), .b(b[4]), .c_in(c[3]), .c_out(c[4]), .s(s[4]) );
  full_adder_1bit a_5( .a(a_adder[5]), .b(b[5]), .c_in(c[4]), .c_out(c[5]), .s(s[5]) );
  full_adder_1bit a_6( .a(a_adder[6]), .b(b[6]), .c_in(c[5]), .c_out(c[6]), .s(s[6]) );
  full_adder_1bit a_7( .a(a_adder[7]), .b(b[7]), .c_in(c[6]), .c_out(c[7]), .s(s[7]) );
  full_adder_1bit a_8( .a(a_adder[8]), .b(b[8]), .c_in(c[7]), .c_out(c[8]), .s(s[8]) );
  full_adder_1bit a_9( .a(a_adder[9]), .b(b[9]), .c_in(c[8]), .c_out(c[9]), .s(s[9]) );

  full_adder_1bit a_10( .a(a_adder[10]), .b(b[10]), .c_in(c[9]), .c_out(c[10]), .s(s[10]) );

  full_adder_1bit a_11( .a(a_adder[11]), .b(b[11]), .c_in(c[10]), .c_out(c[11]), .s(s[11]) );
  full_adder_1bit a_12( .a(a_adder[12]), .b(b[12]), .c_in(c[11]), .c_out(c[12]), .s(s[12]) );
  full_adder_1bit a_13( .a(a_adder[13]), .b(b[13]), .c_in(c[12]), .c_out(c[13]), .s(s[13]) );
  full_adder_1bit a_14( .a(a_adder[14]), .b(b[14]), .c_in(c[13]), .c_out(c[14]), .s(s[14]) );
  full_adder_1bit a_15( .a(a_adder[15]), .b(b[15]), .c_in(c[14]), .c_out(c[15]), .s(s[15]) );

  full_adder_1bit a_16( .a(a_adder[16]), .b(b[16]), .c_in(c[15]), .c_out(c[16]), .s(s[16]) );

  full_adder_1bit a_17( .a(a_adder[17]), .b(b[17]), .c_in(c[16]), .c_out(c[17]), .s(s[17]) );
  full_adder_1bit a_18( .a(a_adder[18]), .b(b[18]), .c_in(c[17]), .c_out(c[18]), .s(s[18]) );
  full_adder_1bit a_19( .a(a_adder[19]), .b(b[19]), .c_in(c[18]), .c_out(c[19]), .s(s[19]) );
  full_adder_1bit a_20( .a(a_adder[20]), .b(b[20]), .c_in(c[19]), .c_out(c[20]), .s(s[20]) );
  full_adder_1bit a_21( .a(a_adder[21]), .b(b[21]), .c_in(c[20]), .c_out(c[21]), .s(s[21]) );
  full_adder_1bit a_22( .a(a_adder[22]), .b(b[22]), .c_in(c[21]), .c_out(c[22]), .s(s[22]) );
  full_adder_1bit a_23( .a(a_adder[23]), .b(b[23]), .c_in(c[22]), .c_out(c[23]), .s(s[23]) );
  full_adder_1bit a_24( .a(a_adder[24]), .b(b[24]), .c_in(c[23]), .c_out(c[24]), .s(s[24]) );
  full_adder_1bit a_25( .a(a_adder[25]), .b(b[25]), .c_in(c[24]), .c_out(c[25]), .s(s[25]) );

  full_adder_1bit a_26( .a(a_adder[26]), .b(b[26]), .c_in(c[25]), .c_out(c[26]), .s(s[26]) );

  full_adder_1bit a_27( .a(a_adder[27]), .b(b[27]), .c_in(c[26]), .c_out(c[27]), .s(s[27]) );
  full_adder_1bit a_28( .a(a_adder[28]), .b(b[28]), .c_in(c[27]), .c_out(c[28]), .s(s[28]) );
  full_adder_1bit a_29( .a(a_adder[29]), .b(b[29]), .c_in(c[28]), .c_out(c[29]), .s(s[29]) );
  full_adder_1bit a_30( .a(a_adder[30]), .b(b[30]), .c_in(c[29]), .c_out(c[30]), .s(s[30]) );
  full_adder_1bit a_31( .a(a_adder[31]), .b(b[31]), .c_in(c[30]), .c_out(c_out), .s(s[31]) );

endmodule
