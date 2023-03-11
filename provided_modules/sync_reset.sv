module sync_reset
    (input [0:0] clk_i
    ,input [0:0] reset_n_async_unsafe_i
    ,output logic [0:0] reset_o);
    wire reset_n_sync_r;
    wire reset_sync_r;
    wire reset_r;
    dff #() sync_reset_a
      (.clk_i(clk_i)
      ,.reset_i(1'b0)
      ,.d_i(reset_n_async_unsafe_i)
      ,.q_o(reset_n_sync_r));
  
    inv #() inv
      (.a_i(reset_n_sync_r)
      ,.b_o(reset_sync_r));
  
    dff #() sync_reset_b
      (.clk_i(clk_i)
      ,.reset_i(1'b0)
      ,.d_i(reset_sync_r)
      ,.q_o(reset_o));
endmodule