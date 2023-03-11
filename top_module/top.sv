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
    
    /*----- Draw Player -----*/
    logic [0:0] player_area;
    logic [0:0] player_x, player_y;
    always_comb begin
        player_x = (x >  400 && x < 415);
        player_y = (y >  400 && y < 415);
        player_area = player_x && player_y;
    end

endmodule