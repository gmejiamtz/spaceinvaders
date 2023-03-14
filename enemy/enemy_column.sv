module enemy_column 
    #(parameter column_id = 10'd10
      parameter left_start_p = 10'd9) 
    (input [0:0] clk_i
    ,input [0:0] reset_i
    ,input [0:0] hit_i
    ,input [0:0] pointed_to_i
    ,input [0:0] frame_i
    ,output [9:0] left_pos_o
    ,output [9:0] right_pos_o
    ,output [0:0] all_dead_o);

    for (genvar i = 0; i < 4; i++) begin
        enemy #(.top_start_p(9 + (i * 40)
               ,.left_start_p(left_start_p)
               ,.ship_id_p(i + 1))
               ) 
        enemy_inst 
        (.clk_i(clk_i)
        ,.reset_i(reset_i)
        ,.hit_i(hit_i)
        ,.frame_i(frame_i)
        ,.

        );
    end
    
endmodule