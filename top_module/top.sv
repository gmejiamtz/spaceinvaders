module top
    (input [0:0] clk_12mhz_i
    ,input [0:0] reset_n_async_unsafe_i
    ,input [3:1] button_async_unsafe_i
    ,output logic [0:0] dvi_clk_o
    ,output logic [0:0] dvi_hsync_o
    ,output logic [0:0] dvi_vsync_o
    ,output logic [7:1] dvi_de_o
    ,output logic [7:1] dvi_r_o
    ,output logic [7:1] dvi_g_o
    ,output logic [7:1] dvi_b_o
    );

    logic [0:0] reset_i;

    /*----- Generate DVI Pixel Clock -----*/
    // clk_i: pixel clock
    // clk_i_locked: pixel clock locked
    logic [0:0] clk_i, clk_i_locked;
    clock_gen_25Mhz pix_clock_inst (
        .clk_i(clk_12mhz_i)
        ,.reset_i(reset_i)
        ,.clk_o(clk_i)
        ,.clk_locked_o(clk_i_locked)
    );

    /*----- Syncronize Reset and Change N to P -----*/
    sync_reset sync_reset_inst (
        .clk_i(clk_i)
        ,.reset_n_async_unsafe_i(reset_n_async_unsafe_i)
        ,.reset_o(reset_i)
    );

    /*----- Synchronize Shooting Button -----*/
    logic [0:0] shoot_btn;
    sync_button sync_button_inst 
        (.clk_i(clk_i)
        ,.reset_i(1'b0)
        ,.button_async_unsafe_i(button_async_unsafe_i[2])
        ,.button_o(shoot_btn));

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
        frame = (y == 480 && x == 0);
    end

    /*----- Draw Player -----*/
    logic [0:0] player_area;
    logic [0:0] player_x, player_y;
    always_comb begin
        player_x = (x >  400 && x < 415);
        player_y = (y >  400 && y < 415);
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
    SB_IO #(.PIN_TYPE(6'b010100)) dvi_sig_io
        (.PACKAGE_PIN({dvi_hsync_o, dvi_vsync_o, dvi_de_o, dvi_r_o, dvi_g_o, dvi_b_o})
        ,.OUTPUT_CLK(clk_i)
        ,.D_OUT_0({hsync, vsync, de, display_r, display_g, display_b})
        /* verilator lint_off PINCONNECTEMPTY */
        ,.D_OUT_1()
        /* verilator lint_on PINCONNECTEMPTY */
        );
    
    /*----- DVI Pmod Clock Output -----*/
    SB_IO #(.PIN_TYPE(6'b0100000)) dvi_clk_io
        (.PACKAGE_PIN(dvi_clk_o)
        ,.OUTPUT_CLK(clk_i)
        ,.D_OUT_0(1'b0)
        ,.D_OUT_1(1'b1));
endmodule