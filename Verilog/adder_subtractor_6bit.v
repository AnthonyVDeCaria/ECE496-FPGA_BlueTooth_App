/*
	Anthony De Caria - January 26, 2017

	This module is a 6 bit adder/subtractor.

	It will output B - A if desired.
*/

module adder_subtractor_6bit(a, b, want_subtract, c_out, s);
  
	/*
		I/Os
	*/
	input [5:0] a, b;
	input want_subtract; // If want_subtract == 1, we subtract. Otherwise we add.
	output [5:0] s;
	output c_out;

	wire [4:0]c;
	wire [5:0]a_adder;

	mux_2_1bit m_0( .data0(a[0]), .data1(~a[0]), .sel(want_subtract), .result(a_adder[0]) );
	mux_2_1bit m_1( .data0(a[1]), .data1(~a[1]), .sel(want_subtract), .result(a_adder[1]) );
	mux_2_1bit m_2( .data0(a[2]), .data1(~a[2]), .sel(want_subtract), .result(a_adder[2]) );
	mux_2_1bit m_3( .data0(a[3]), .data1(~a[3]), .sel(want_subtract), .result(a_adder[3]) );
	mux_2_1bit m_4( .data0(a[4]), .data1(~a[4]), .sel(want_subtract), .result(a_adder[4]) );
	mux_2_1bit m_5( .data0(a[5]), .data1(~a[5]), .sel(want_subtract), .result(a_adder[5]) );

	full_adder_1bit a_0( .a(a_adder[0]), .b(b[0]), .c_in(want_subtract), .c_out(c[0]), .s(s[0]) );
	
	full_adder_1bit a_1( .a(a_adder[1]), .b(b[1]), .c_in(c[0]), .c_out(c[1]), .s(s[1]) );
	full_adder_1bit a_2( .a(a_adder[2]), .b(b[2]), .c_in(c[1]), .c_out(c[2]), .s(s[2]) );
	full_adder_1bit a_3( .a(a_adder[3]), .b(b[3]), .c_in(c[2]), .c_out(c[3]), .s(s[3]) );
	full_adder_1bit a_4( .a(a_adder[4]), .b(b[4]), .c_in(c[3]), .c_out(c[4]), .s(s[4]) );
	
	full_adder_1bit a_5( .a(a_adder[5]), .b(b[5]), .c_in(c[4]), .c_out(c_out), .s(s[5]) );
  
endmodule