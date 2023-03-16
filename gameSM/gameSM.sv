module gameSM #()
    (input  [0:0] clk_i
    ,input  [0:0] reset_i
    ,input  [0:0] frame_i
    ,input  [0:0] btn_left_i
    ,input  [0:0] btn_right_i
    ,input  [0:0] btn_shoot_i

    ,input  [0:0] player_was_hit_i
    ,input  [0:0] enemy_was_hit_i

    ,output [9:0] p_left_o
    ,output [9:0] p_right_o
    ,output [9:0] p_gun_left_o
    ,output [9:0] p_gun_right_o
    ,output [9:0] p_bullet_left_o
    ,output [9:0] p_bullet_right_o
    ,output [9:0] p_bullet_top_o
    ,output [9:0] p_bullet_bot_o

    ,output [0:0] p_fired_o
    ,output [0:0] bullet_not_border

    ,output [4:0] p_next_o
    ,output [4:0] p_pres_o

    ,output [1:0] p_bullet_next_o
    ,output [1:0] p_bullet_pres_o

    ,output [9:0] player_red_o
    ,output [9:0] player_green_o
    ,output [9:0] player_blue_o

    ,input [0:0] ready_i
    ,output [0:0] valid_o
    );

    logic [0:0] player_alive, p_bullet_flying;

    player #(.color_p()) player_inst
        (.clk_i(clk_i)
        ,.reset_i(reset_i)
        ,.frame_i(frame_i)
        ,.move_left_i(btn_left_i)
        ,.move_right_i(btn_right_i)
        ,.shoot_i(btn_shoot_i)
        ,.hit_i(player_was_hit_i)
        ,.hit_enemy_i(enemy_was_hit_i)
        ,.add_life_i(1'b0)
        ,.alive_o(player_alive)
        ,.pos_left_o(p_left_o)
        ,.pos_right_o(p_right_o)
        ,.gun_left_o(p_gun_left_o)
        ,.gun_right_o(p_gun_right_o)
        ,.bullet_left_o(p_bullet_left_o)
        ,.bullet_right_o(p_bullet_right_o)
        ,.bullet_top_o(p_bullet_top_o)
        ,.bullet_bot_o(p_bullet_bot_o)
        /* verilator lint_off PINCONNECTEMPTY */
        ,.next_states_o()
        ,.pres_states_o()
        ,.bullet_pres_o()
        ,.bullet_next_o()
        ,.bullet_not_border()
        /* verilator lint_on PINCONNECTEMPTY */
        ,.bullet_o(p_bullet_flying)
        ,.player_red_o(player_red_o)
        ,.player_green_o(player_green_o)
        ,.player_blue_o(player_blue_o)
        ,.);
endmodule

// each ship ID