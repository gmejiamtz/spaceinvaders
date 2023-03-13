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
    logic [9:0] pos_left, pos_right, gun_pos;
    logic [3:0] player_red, player_green, player_blue;
    logic [4:0] next_states, pres_states;
    player #() player_inst 
        (.clk_i(clk_i) 			        //clock
	    ,.reset_i(reset_i)	            //reset button
	    ,.move_left_i(btn_l) 	        //move left - left button
	    ,.shoot_i(shoot_btn) 		    //shoot and start and resume levels - center button
	    ,.move_right_i(btn_r) 	        //move right -right button
	    ,.hit_i(1'b0) 			        //hit by enemy
	    ,.add_life_i(1'b0)		        //add a life due to beating levels
	    ,.alive_o(alive)		            //player has more than 0 lives
	    ,.shot_laser_o(shot_laser)	        //spawn bullet
	    ,.resume_o(resume)		        //resuming a game
	    ,.pos_left_o(pos_left)	        //left most position of player
	    ,.pos_right_o(pos_right)	    //right most position of player
	    ,.gun_pos_o(gun_pos)		    //location of gun, half of the ship size plus 1
	    ,.player_red_o(player_red)	    //ammount of red the player is for display
	    ,.player_green_o(player_green)  //ammount of green the player is for display
	    ,.player_blue_o(player_blue)	//ammount of blue the player is for display
	    ,.next_states_o(next_states)	//outputs next states for debugging
	    ,.pres_states_o(pres_states));  //outputs present states for debugging

    /*----- Draw Player -----*/
    logic [0:0] player_area;
    logic [0:0] player_x, player_y;
    always_comb begin
        player_x = (x >  pos_left && x < pos_right);
        player_y = (y >  399 && y < 414);
        player_area = player_x && player_y;
    end

    /*----- Color Pixels -----*/
    logic [3:0] paint_r, paint_g, paint_b;
    always_comb begin
        paint_r = (player_area) ? 4'h5 : 4'h0;
        paint_g = (player_area) ? 4'hE : 4'h0;
        paint_b = (player_area) ? 4'h5 : 4'h0;
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