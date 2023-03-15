module enemy_column 
    #(parameter column_id = 10'd10
      parameter left_start_p = 10'd9
      parameter column_bullet_delay_p = 10'd1) 
    (input  [0:0] clk_i
    ,input  [0:0] reset_i
    // ,input  [0:0] hit_i
    ,input  [0:0] pointed_by_left_i
    ,input  [0:0] pointed_by_right_i
    ,input  [0:0] frame_i
    ,input  [9:0] pixel_avail_i
    ,input  [9:0] bullet_left_i
    ,input  [9:0] bullet_right_i
    ,output [0:0] landed_o
    ,output [0:0] dead_o
    ,output [0:0] all_dead_o
    ,output [9:0] left_pos_o
    ,output [9:0] right_pos_o
    ,output [9:0] column_red_o
    ,output [9:0] column_green_o
    ,output [9:0] column_blue_o);

    logic [4:0] column_status; // 0 = alive, 1 = dead
    assign all_dead_o = &column_status;

    // logic [9:0] ship_pointer;
    // counter #(.width_p(10), .reset_val_p(10'd5), .step_p(10'd1))
    //     ship_pointer_counter_inst
    //     (.clk_i(clk_i)
    //     ,.reset_i(reset_i)
    //     ,.up_i('0)
    //     ,.down_i()
    //     ,.load_i()
    //     ,.load_val_i(10'd5)
    //     ,.counter_o(ship_pointer)
    //     ,.step_o()
    //     ,.reset_val_o());

    int ship_pointer = 5;
    always_comb begin
        if ((column_status[ship_pointer - 1]) && (column_status[ship_pointer - 2])) begin
            ship_pointer--;
        end else if (column_status[ship_pointer]) begin
            
        end
    end

    for (genvar i = 0; i < 5; i++) begin
        enemy #(.top_start_p(9 + (i * 40))
               ,.left_start_p(left_start_p)
               ,.ship_id_p(i + 1)
               ,.bullet_delay_p(column_bullet_delay_p))
        enemy_inst 
            (.clk_i(clk_i)
	        ,.reset_i(reset_i)
	        ,.hit_i(hit_i)
	        ,.frame_i(frame_i)
	        ,.all_dead_i(all_dead_o)
	        ,.pixel_avail_i(pixel_avail_i)
	        ,.pointed_to_i(pointed_to_i)
	        ,.left_pos_o(left_pos_o)
	        ,.right_pos_o(right_pos_o)
	        ,.top_pos_o(top_pos_o)
	        ,.bot_pos_o(bot_pos_o)
	        ,.landed_o(landed_o)
	        ,.dead_o(column_status[i])
	        ,.enemy_red_o(column_red_o)
	        ,.enemy_green_o(column_green_o)
	        ,.enemy_blue_o(column_blue_o));
    end
    
    logic [0:0] is_edge = 1'b0;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            column_pres <= HAVE_FIVE;
        end else begin
            column_pres <= column_next
        end
    end

    always_comb begin
        if (column_id)
    end


endmodule