module syncronizer #()
    (input [0:0] clk_i
    ,input [0:0] btn_i
    ,output [0:0] btn_o);
    wire [0:0] btn_sync;
    dff #() sync_btn_dff_1 
        (.clk_i(clk_i)
        ,.reset_i(1'b0)
        ,.d_i(btn_i)
        ,.q_o(btn_sync));
    dff #() sync_btn_dff_2 
        (.clk_i(clk_i)
        ,.reset_i(1'b0)
        ,.d_i(btn_sync)
        ,.q_o(btn_o));
endmodule