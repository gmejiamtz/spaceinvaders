// This module implements a 2-input OR gate
module or2
  (input [0:0] a_i
  ,input [0:0] b_i
  ,output [0:0] c_o);

   assign c_o = a_i | b_i;

endmodule
	   
