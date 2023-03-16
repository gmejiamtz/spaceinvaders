module render_enemy
    (input [0:0] clk_i
    ,input [0:0] reset_i
    ,input [0:0] frame_i
    ,input [9:0] sx_i
    ,input [9:0] sy_i
    ,input [9:0] sprx_i
    ,input [9:0] spry_i
    ,output [0:0] drawing_o
    ,output [0:0] pix_o);

    // sprite bitmap
    localparam SPR_WIDTH  = 40;
    localparam SPR_HEIGHT = 40;
    logic [0:SPR_WIDTH-1] bmap [SPR_HEIGHT];
    initial begin  // MSB first, so we can write initial block left to right
        bmap[0] = '0;
        bmap[1] = '0;
        bmap[2] = '0;
        bmap[3] = '0;
        bmap[4] = '0;
        bmap[5] = '0;
        bmap[6] = '0;
        bmap[7] = '0;
        bmap[8] = '0;
        bmap[9] = '0;

        bmap[10]  = 40'h00_3FFF_FC00;
        bmap[11]  = 40'h00_3FFF_FC00;
        bmap[12]  = 40'h00_3FFF_FC00;
        bmap[13]  = 40'h00_3FFF_FC00;
        bmap[14]  = 40'h00_3FFF_FC00;
        bmap[15]  = 40'h00_3FFF_FC00;
        bmap[16]  = 40'h00_3FFF_FC00;
        bmap[17]  = 40'h00_3FFF_FC00;
        bmap[18]  = 40'h00_3FFF_FC00;
        bmap[19]  = 40'h00_3FFF_FC00;
        bmap[20]  = 40'h00_3FFF_FC00;
        bmap[21]  = 40'h00_3FFF_FC00;
        bmap[22]  = 40'h00_3FFF_FC00;
        bmap[23]  = 40'h00_3FFF_FC00;
        bmap[24]  = 40'h00_3FFF_FC00;
        bmap[25]  = 40'h00_3FFF_FC00;
        bmap[26]  = 40'h00_3FFF_FC00;
        bmap[27]  = 40'h00_3FFF_FC00;
        bmap[28]  = 40'h00_3FFF_FC00;
        bmap[29]  = 40'h00_3FFF_FC00;

        bmap[30]  = '0;
        bmap[31]  = '0;
        bmap[32]  = '0;
        bmap[33]  = '0;
        bmap[34]  = '0;
        bmap[35]  = '0;
        bmap[36]  = '0;
        bmap[37]  = '0;
        bmap[38]  = '0;
        bmap[39]  = '0;
    end

    // coordinates within sprite bitmap
    logic [$clog2(SPR_WIDTH)-1:0]  bmap_x;
    logic [$clog2(SPR_HEIGHT)-1:0] bmap_y;

    // for registering sprite position
    logic signed [9:0] sprx_r, spry_r;

    // status flags: used to change state
    logic [0:0] spr_active;  // sprite active on this line
    logic [0:0] spr_begin;   // begin sprite drawing
    logic [0:0] spr_end;     // end of sprite on this line
    logic [0:0] line_end;    // end of screen line, corrected for sx offset
    always_comb begin
        spr_active = (sy - spry_r >= 0) && (sy - spry_r < SPR_HEIGHT);
        spr_begin  = (sx >= sprx_r - 2);
        spr_end    = (bmap_x == SPR_WIDTH-1);
        line_end   = (sx == 638); // H_RES - OFFSET
    end

    // sprite state machine
    enum {
        IDLE,      // awaiting line signal
        REG_POS,   // register sprite position
        ACTIVE,    // check if sprite is active on this line
        WAIT_POS,  // wait for horizontal sprite position
        SPR_LINE,  // iterate over sprite pixels
        WAIT_DATA  // account for data latency
    } state;

    always_ff @(posedge clk) begin
        if (line) begin  // prepare for new line
            state <= REG_POS;
            pix <= 0;
            drawing <= 0;
        end else begin
            case (state)
                REG_POS: begin
                    state <= ACTIVE;
                    sprx_r <= sprx;
                    spry_r <= spry;
                end
                ACTIVE: state <= spr_active ? WAIT_POS : IDLE;
                WAIT_POS: begin
                    if (spr_begin) begin
                        state <= SPR_LINE;
                        bmap_x <= sx - sprx_r + 2;  // account for start offset
                        bmap_y <= sy - spry_r;
                    end
                end
                SPR_LINE: begin
                    if (spr_end || line_end) state <= WAIT_DATA;
                    bmap_x <= bmap_x + 1;
                    pix <= bmap[bmap_y][bmap_x];
                    drawing <= 1;
                end
                WAIT_DATA: begin
                    state <= IDLE;  // 1 cycle between address set and data receipt
                    pix <= 0;  // default colour
                    drawing <= 0;
                end
                default: state <= IDLE;
            endcase
        end

        if (rst) begin
            state <= IDLE;
            bmap_x <= 0;
            bmap_y <= 0;
            pix <= 0;
            drawing <= 0;
        end
    end
endmodule