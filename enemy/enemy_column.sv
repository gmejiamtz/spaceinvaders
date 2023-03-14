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
    ,output [0:0] all_dead_o
    ,output [9:0] column_red_o
    ,output [9:0] column_green_o
    ,output [9:0] column_blue_o);

    for (genvar i = 0; i < 4; i++) begin
        enemy #(.top_start_p(9 + (i * 40)
               ,.left_start_p(left_start_p)
               ,.ship_id_p(i + 1))
               ) 
        enemy_inst (
    .clk_i(clk_i),
	.reset_i(),			
	.hit_i(),					
	.frame_i(),				
	.start_i(),		
	.pixel_avail_i(),			
	.pointed_to_i(),			
	.left_pos_o(),			
	.right_pos_o(),	
	.top_pos_o(),				
	.bot_pos_o(),				
	.landed_o(),			
	.dead_o(),
	.enemy_red_o(column_red_o),			
	.enemy_green_o(column_green_o),			
	.enemy_blue_o(column_blue_o));
    end
    
endmodule