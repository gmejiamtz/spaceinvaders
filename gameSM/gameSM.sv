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

    ,input [0:0] ready_i
    ,output [0:0] valid_o
    );

    typedef enum logic [4:0] {
        ERROR = 5'b00000,
        IDLE = 5'b00001,
        MOVING_LEFT = 5'b00010,
        MOVING_RIGHT = 5'b00100,
        SHOOTING = 5'b01000,
        GAMEOVER = 5'b10000 
    } player_states;

    typedef enum logic [1:0] {
        READY = 2'b00,
        MOVING = 2'b01
    } bullet_states;
endmodule

// each ship ID