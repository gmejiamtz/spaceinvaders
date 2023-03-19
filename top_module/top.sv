module top
    (input [0:0] clk_12mhz_i
    ,input [0:0] reset_n_async_unsafe_i
    ,input [3:1] button_async_unsafe_i
    ,output [5:1] led_o
    ,output logic [0:0] dvi_clk
    ,output logic [0:0] dvi_hsync
    ,output logic [0:0] dvi_vsync
    ,output logic [0:0] dvi_de
    ,output logic [3:0] dvi_r
    ,output logic [3:0] dvi_g
    ,output logic [3:0] dvi_b
    );

    /*----- Generate DVI Pixel Clock -----*/
    // clk_i: pixel clock
    // clk_i_locked: pixel clock locked
    logic [0:0] clk_i, clk_i_locked;
    clock_gen_25MHz pix_clock_inst (
        .clk_12m(clk_12mhz_i)
        ,.rst(reset_n_async_unsafe_i)
        ,.clk_pix(clk_i)
        ,.clk_pix_locked(clk_i_locked)
    );

    /*----- Syncronize Reset and Change N to P -----*/
    // :TODO : safe reset is non-functional with current clock PLL setup.:
    // sync_reset sync_reset_inst (
    //     .clk_i(clk_i)
    //     ,.reset_n_async_unsafe_i(reset_n_async_unsafe_i)
    //     ,.reset_o(reset_i)
    // );

    // wire [0:0] reset_n_sync_r;
    // wire [0:0] reset_sync_r;
    // wire [0:0] reset_r; // Use this as your reset_signal
    // dff #() sync_a
    //   (.clk_i(clk_12mhz_i)
    //   ,.reset_i(1'b0)
    //   ,.d_i(reset_n_async_unsafe_i)
    //   ,.q_o(reset_n_sync_r));

    // inv #() inv
    //   (.a_i(reset_n_sync_r)
    //   ,.b_o(reset_sync_r));

    // dff #() sync_b
    //   (.clk_i(clk_12mhz_i)
    //   ,.reset_i(1'b0)
    //   ,.d_i(reset_sync_r)
    //   ,.q_o(reset_r));

    /*----- Synchronize Shooting Button -----*/
    logic [0:0] shoot_btn, btn_l, btn_r;
    synchronizer shoot_button_inst 
        (.clk_i(clk_i)
        ,.btn_i(button_async_unsafe_i[2])
        ,.btn_o(shoot_btn));
    synchronizer right_button_inst 
        (.clk_i(clk_i)
        ,.btn_i(button_async_unsafe_i[1])
        ,.btn_o(btn_r));
    synchronizer left_button_inst 
        (.clk_i(clk_i)
        ,.btn_i(button_async_unsafe_i[3])
        ,.btn_o(btn_l));

    /*----- Instantiate DVI Sync Signals and Coordinates -----*/
    localparam CORDW = 10;
    logic [9:0] x, y;
    logic [0:0] hsync, vsync, de,new_line;
    dvi_controller controller_inst 
        (.clk_pix(clk_i)
        ,.rst_pix(!clk_i_locked)
        ,.sx(x)
        ,.sy(y)
        ,.hsync(hsync)
        ,.vsync(vsync)
        ,.de(de));
    
    /*----- Initialize a frame -----*/
    logic [0:0] frame;
    always_comb begin
        frame = (y == 481 && x == 2);
        new_line = x == 799;
    end
    
    /*---- Memories ----*/
    // ram_1r1w_sync #(.width_p(21),.depth_p(64),.filename_p("memory_enemy.hex"))
    //     enemy_memory_inst (.clk_i(clk_i),.reset_i(1'b0),
    //         .wr_valid_i(),.wr_data_i(),.wr_addr_i(),.rd_addr_i(),
    //         .rd_data_o());

    // ram_1r1w_sync #(.width_p(21),.depth_p(64),.filename_p("memory_enemy.hex"))
    //     enemy_memory_inst (.clk_i(clk_i),.reset_i(1'b0),
    //         .wr_valid_i(),.wr_data_i(),.wr_addr_i(),.rd_addr_i(),
    //         .rd_data_o());

    /*----- Player -----*/
    // parameter: color_p = {4'hRed, 4'hGreen, 4'hBlue}
    logic [0:0] alive, shot_laser, resume;
    logic [9:0] pos_left, pos_right, gun_left, gun_right,
                bullet_left, bullet_right, bullet_top, bullet_bot;
    logic [3:0] player_red, player_green, player_blue;
    logic [4:0] player_next, player_pres;
    logic [1:0] bullet_pres_states,bullet_next_states;

    player #() player_inst 
        (.clk_i(clk_i) 			        //clock
	    ,.reset_i(reset_n_async_unsafe_i)	            //reset button
	    ,.move_left_i(btn_l) 	        //move left - left button
	    ,.shoot_i(shoot_btn) 		    //shoot and start and resume levels - center button
	    ,.frame_i(frame)
        ,.move_right_i(btn_r) 	        //move right -right button
	    ,.hit_i(1'b0) 			        //hit by enemy
	    ,.hit_enemy_i(1'b0)             //will be wired ground for now
        ,.add_life_i(1'b0)		        //add a life due to beating levels
	    ,.alive_o(alive)		        //player has more than 0 lives
	    ,.pos_left_o(pos_left)	        //left most position of player
	    ,.pos_right_o(pos_right)	    //right most position of player
	    ,.gun_left_o(gun_left)		    //location of gun, half of the ship size plus 1
	    ,.gun_right_o(gun_right)
        ,.player_red_o(player_red)	    //ammount of red the player is for display
	    ,.player_green_o(player_green)  //ammount of green the player is for display
	    ,.player_blue_o(player_blue)	//ammount of blue the player is for display
	    ,.next_states_o(player_next)	//outputs next states for debugging
	    ,.pres_states_o(player_pres)    //outputs present states for debugging
        ,.bullet_o(shot_laser)
        ,.bullet_left_o(bullet_left)
        ,.bullet_right_o(bullet_right)
        ,.bullet_top_o(bullet_top)
        ,.bullet_bot_o(bullet_bot)
        ,.bullet_pres_o(bullet_pres_states)
        ,.bullet_next_o(bullet_next_states)
        ,.bullet_not_border(led_o[1]));

    /*----- Enemy -----*/
    // parameters:
    // - color_p = {4'hRed, 4'hGreen, 4'hBlue}
    // - top_start_p = 10'bRow
    // - left_start_p = 10'bColumn
    // - ship_id_p = 10'dShip ID
    logic [3:0] enemy_r, enemy_g, enemy_b;
    logic [0:0] landed, dead, draw_enemy;
    logic [0:0] bullet_area;
    enemy #() enemy_inst
        (.clk_i(clk_i)
        ,.reset_i(~reset_n_async_unsafe_i)
        ,.frame_i(frame)
        ,.sx_i(x)
        ,.sy_i(y)
        ,.de_i(de)
        ,.player_bullet_area_i(bullet_area)
        ,.player_bullet_flying_i(shot_laser)
        ,.draw_enemy(draw_enemy)
        ,.enemy_r_o(enemy_r)
        ,.enemy_g_o(enemy_g)
        ,.enemy_b_o(enemy_b)
        ,.landed_o(landed)
        ,.dead_o(dead));
    
    /*----- Debug Player States -----*/
    //assign led_o[3:2] = bullet_next_states;
    //assign led_o[5:4] = bullet_pres_states;
    
    /*----- Draw Player & Player Bullet -----*/
    logic [0:0] player_area_1, player_area_2, player_area;
    logic [0:0] player_x_1, player_x_2, player_y_1, player_y_2;
    logic [0:0] bullet_x, bullet_y;
    always_comb begin
        player_x_1 = (x >  pos_left && x < pos_right); //player
        player_x_2 = (x >  gun_left && x < gun_right); //player
        player_y_2 = (y >  429 && y <= 449);           //player
        player_y_1 = (y >= 449 && y < 469);            //player
        player_area_1 = player_x_1 && player_y_1;
        player_area_2 = player_x_2 && player_y_2;
        player_area = player_area_1 || player_area_2;

        //bullet
        bullet_x = (x > bullet_left && x < bullet_right);
        bullet_y = ((y >  bullet_top) && (y < bullet_bot));
        bullet_area = bullet_x && bullet_y;
    end

    /*----- Init Game Over Screen -----*/
    logic [0:19] bmap_lose [15];
    initial begin
        bmap_lose[0]  = 20'b0110_0000_0011_0001_0000;
        bmap_lose[1]  = 20'b0000_0100_0000_0000_0001;
        bmap_lose[2]  = 20'b0111_1001_0010_0010_1110;
        bmap_lose[3]  = 20'b0100_0010_1011_0110_1000;
        bmap_lose[4]  = 20'b0101_1010_1010_1010_1100;
        bmap_lose[5]  = 20'b0100_1011_1010_0010_1000;
        bmap_lose[6]  = 20'b0111_1010_1010_0010_1110;
        bmap_lose[7]  = 20'b0000_0000_0000_0000_0000;
        bmap_lose[8]  = 20'b0011_0100_1011_1011_1000;
        bmap_lose[9]  = 20'b0101_0100_1010_0010_1000;
        bmap_lose[10] = 20'b0101_0010_1011_0011_1000;
        bmap_lose[11] = 20'b0101_0010_1010_0010_1000;
        bmap_lose[12] = 20'b0110_0001_0011_1010_1100;
        bmap_lose[13] = 20'b0000_1100_0000_0000_0000;
        bmap_lose[14] = 20'b0100_0110_0010_0110_0010;
    end

    logic [0:19] bmap_win [15];
    initial begin
        bmap_win[0]  = 20'b0000_0000_0000_0000_0000;
        bmap_win[1]  = 20'b0000_0000_0000_0000_0000;
        bmap_win[2]  = 20'b0000_1010_0110_1001_0000;
        bmap_win[3]  = 20'b0000_1010_1010_1001_0000;
        bmap_win[4]  = 20'b0000_0110_1010_1001_0000;
        bmap_win[5]  = 20'b0000_0010_1010_1001_0000;
        bmap_win[6]  = 20'b0000_1110_1100_0110_0000;
        bmap_win[7]  = 20'b0000_0000_0000_0000_0000;
        bmap_win[8]  = 20'b0000_1000_1010_1001_0000;
        bmap_win[9]  = 20'b0000_1000_1010_1101_0000;
        bmap_win[10] = 20'b0000_1000_1010_1011_0000;
        bmap_win[11] = 20'b0000_1010_1010_1001_0000;
        bmap_win[12] = 20'b0000_0101_0010_1001_0000;
        bmap_win[13] = 20'b0000_0000_0000_0000_0000;
        bmap_win[14] = 20'b0000_0000_0000_0000_0000;
    end

    logic [0:0] gm_screen_flag, win_screen_flag;
    logic [4:0] screen_x;
    logic [3:0] screen_y;
    always_comb begin
        screen_x = x[9:5];
        screen_y = y[8:5];
        gm_screen_flag = de ? bmap_lose[screen_y][screen_x] : 1'b0;
        win_screen_flag = de ? bmap_win[screen_y][screen_x] : 1'b0;
    end

    /*----- Color Pixels -----*/
    logic [3:0] paint_r, paint_g, paint_b;
    always_comb begin
        if (landed & ~dead) begin
            paint_r = gm_screen_flag ? 4'hF : 4'h0;
            paint_g = gm_screen_flag ? 4'h0 : 4'h0;
            paint_b = gm_screen_flag ? 4'h0 : 4'h0;
        end else if (dead) begin
            paint_r = win_screen_flag ? 4'h5 : 4'h0;
            paint_g = win_screen_flag ? 4'hE : 4'h0;
            paint_b = win_screen_flag ? 4'h5 : 4'h0;
        end else begin
            paint_r = {4{draw_enemy}} & enemy_r | {4{bullet_area}} & player_red | {4{player_area}} & player_red;
            paint_g = {4{draw_enemy}} & enemy_g | {4{bullet_area}} & player_green | {4{player_area}} & player_green;
            paint_b = {4{draw_enemy}} & enemy_b | {4{bullet_area}} & player_blue | {4{player_area}} & player_blue;
        end
    end

    /*----- Display Pixels -----*/
    logic [3:0] display_r, display_g, display_b;
    always_comb begin
        display_r = (de) ? paint_r : 4'h0;
        display_g = (de) ? paint_g : 4'h0;
        display_b = (de) ? paint_b : 4'h0;
    end

    /*----- DVI Pmod Signals Outputs -----*/
    SB_IO #(.PIN_TYPE(6'b010100)) dvi_sig_io [14:0]
        (.PACKAGE_PIN({dvi_hsync, dvi_vsync, dvi_de, dvi_r, dvi_g, dvi_b})
        ,.OUTPUT_CLK(clk_i)
        ,.D_OUT_0({hsync, vsync, de, display_r, display_g, display_b})
        /* verilator lint_off PINCONNECTEMPTY */
        ,.D_OUT_1()
        /* verilator lint_on PINCONNECTEMPTY */
        );
    
    /*----- DVI Pmod Clock Output -----*/
    SB_IO #(.PIN_TYPE(6'b010000)) dvi_clk_io
        (.PACKAGE_PIN(dvi_clk)
        ,.OUTPUT_CLK(clk_i)
        ,.D_OUT_0(1'b0)
        ,.D_OUT_1(1'b1));
endmodule
