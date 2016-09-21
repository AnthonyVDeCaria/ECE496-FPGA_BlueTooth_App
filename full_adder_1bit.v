/*
Anthony De Caria - January 18, 2016

This module is a full adder for a single bit.
*/

module full_adder_1bit(a, b, c_in, c_out, s);
  
  /*
   * I/Os
   */
  input a, b, c_in;
  output s, c_out;
  
  /*		
	 a  b  c_in | c_out  s
	 0  0   0   |   0    0
	 0  0   1   |   0    1
	 0  1   0   |   0    1
	 0  1   1   |   1    0
	 1  0   0   |   0    1
	 1  0   1   |   1    0
	 1  1   0   |   1    0
	 1  1   1   |   1    1
	
	*/
  
  assign s = (a ^ b) ^ c_in;
  assign c_out = a&b | b&c_in | a&c_in;
  
endmodule
