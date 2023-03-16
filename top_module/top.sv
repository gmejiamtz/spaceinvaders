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

    logic [0:0] reset_i;

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
    sync_reset sync_reset_inst (
        .clk_i(clk_i)
        ,.reset_n_async_unsafe_i(reset_n_async_unsafe_i)
        ,.reset_o(reset_i)
    );

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
    logic [0:0] hsync, vsync, de;
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
    end
    
    /*----- Player -----*/
    // parameter: color_p = {4'hRed, 4'hGreen, 4'hBlue}
    logic [0:0] alive, shot_laser, resume;
    logic [9:0] pos_left, pos_right, gun_left, gun_right,
        bullet_left,bullet_right,bullet_top,bullet_bot;
    logic [3:0] player_red, player_green, player_blue;
    logic [4:0] player_next, player_pres;
    logic [1:0] bullet_pres_states,bullet_next_states;
    
    /*player #() player_inst 
        (.clk_i(clk_i) 			        //clock
	    ,.reset_i(reset_n_async_unsafe_i)	            //reset button
	    ,.move_left_i(btn_l) 	        //move left - left button
	    ,.shoot_i(shoot_btn) 		    //shoot and start and resume levels - center button
	    ,.frame_i(frame)
        ,.move_right_i(btn_r) 	        //move right -right button
	    ,.hit_i(1'b0) 			        //hit by enemy
	    ,.hit_enemy_i(1'b0)             //will be wired ground for now
        ,.add_life_i(1'b0)		        //add a life due to beating levels
	    ,.alive_o(alive)		            //player has more than 0 lives
	    ,.pos_left_o(pos_left)	        //left most position of player
	    ,.pos_right_o(pos_right)	    //right most position of player
	    ,.gun_left_o(gun_left)		    //location of gun, half of the ship size plus 1
	    ,.gun_right_o(gun_right)
        ,.player_red_o(player_red)	    //ammount of red the player is for display
	    ,.player_green_o(player_green)  //ammount of green the player is for display
	    ,.player_blue_o(player_blue)	//ammount of blue the player is for display
	    ,.next_states_o(player_next)	//outputs next states for debugging
	    ,.pres_states_o(player_pres)  //outputs present states for debugging
        ,.bullet_o(shot_laser)
        ,.bullet_left_o(bullet_left)
        ,.bullet_right_o(bullet_right)
        ,.bullet_top_o(bullet_top)
        ,.bullet_bot_o(bullet_bot)
        ,.bullet_pres_o(bullet_pres_states)
        ,.bullet_next_o(bullet_next_states)
        ,.bullet_not_border(led_o[1])
        );
    */
    /*----- Enemy -----*/
    // parameters:
    // - color_p = {4'hRed, 4'hGreen, 4'hBlue}
    // - top_start_p = 10'bRow
    // - left_start_p = 10'bColumn
    // - ship_id_p = 10'dShip ID
    logic [0:0] enemy_hit, enemy_landed, enemy_dead, start;
    logic [9:0] enemy_left, enemy_right, enemy_top, enemy_bot;
    logic [3:0] enemy_red, enemy_green, enemy_blue;
    logic [9:0] top_ship_pointer, bot_ship_pointer;
    /*enemy #() enemy_inst_1
        (.clk_i(clk_i)
        ,.reset_i(reset_n_async_unsafe_i)
        ,.hit_i(shot_laser)
        ,.frame_i(frame)
        ,.start_i(shoot_btn)
        ,.pixel_avail_i(10'd600)
        ,.top_ship_pointer_i(top_ship_pointer)
        ,.bot_ship_pointer_i(bot_ship_pointer)
        ,.left_pos_o(enemy_left)
        ,.right_pos_o(enemy_right)
        ,.top_pos_o(enemy_top)
        ,.bot_pos_o(enemy_bot)
        ,.landed_o(enemy_landed)
        ,.dead_o(enemy_dead)
        ,.enemy_red_o(enemy_red)
        ,.enemy_green_o(enemy_green)
        ,.enemy_blue_o(enemy_blue));
    
    /*----- Debug Player States -----*/
    //assign led_o[3:2] = bullet_next_states;
    //assign led_o[5:4] = bullet_pres_states;
    
    /*----- Draw Player -----*/
    logic [0:0] player_area_1, player_area_2, player_area;
    logic [0:0] player_x_1, player_x_2, player_y_1, player_y_2;

    /*---- Draw Bullet ----*/
    logic [0:0] bullet_x, bullet_y,bullet_area;


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

    /*----- Draw Enemies -----*/
    logic [0:0] enemy_area;
    always_comb begin
        enemy_area = (x > enemy_left && x < enemy_right && y > enemy_top && y < enemy_bot);
    end

    /*----- Color Pixels -----*/
    logic [3:0] paint_r, paint_g, paint_b;
    always_comb begin
        paint_r = {4{bullet_area}} & player_red | {4{player_area}} & player_red;
        paint_g = {4{bullet_area}} & player_green | {4{player_area}} & player_green;
        paint_b = {4{bullet_area}} & player_blue | {4{player_area}} & player_blue;
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
