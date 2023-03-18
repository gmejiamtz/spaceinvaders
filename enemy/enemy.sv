module enemy 
    #(parameter color_p   = {4'hF, 4'hF, 4'hF}
     ,parameter ship_id_p = 10'b00_0000_0001
     ,parameter qx        = 10'b00_0000_0000
     ,parameter qy        = 10'b00_0000_0000) 
    (input [0:0] clk_i
    ,input [0:0] reset_i
    ,input [0:0] frame_i
    ,input [9:0] sx_i
    ,input [9:0] sy_i
    ,input [0:0] de_i
    ,input [0:0] player_bullet_area_i
	,output [0:0] draw_enemy 
    ,output [3:0] enemy_r_o
    ,output [3:0] enemy_g_o
    ,output [3:0] enemy_b_o
    ,output logic [0:0] landed_o
    ,output reg [0:0] dead_o);
    
    localparam H_RES = 640;
    localparam V_RES = 480;

    localparam FRAME_NUM = 1; // how fast to move frames
    logic [$clog2(FRAME_NUM):0] cnt_frame;
    always_ff @(posedge clk_i) begin
        if (frame_i) begin
            cnt_frame <= (cnt_frame == FRAME_NUM-1) ? '0 : cnt_frame + 1;
        end
    end

    localparam Q_SIZE = 40; // enemy size in pixels
    // logic [9:0] qx, qy; // enemy position (origin at top left)
    // assign qx = top_x_p;
    // assign qy = top_y_p;

    logic [0:0] qdx; // State: QDX = 0, move right. QDX = 1, move left
    logic [9:0] qs = 10'd2; // enemy movement speed

    // update square position once per frame
    always_ff @(posedge clk_i) begin
        if (frame_i && cnt_frame == 0) begin
            // horizontal position
            if (qdx == 0 & ~landed_o) begin  // moving right
                if (qx + Q_SIZE + qs >= H_RES-1) begin  // hitting right of screen?
                    qx <= H_RES - Q_SIZE - 1;  // move right as far as we can
                    qdx <= 1;  // move left next frame
                    if (!(qy + qs + 80 >= 469)) begin
                       qy <= qy + qs + 40;
                    end else begin
                        landed_o = 1'b1;
                    end
                end else qx <= qx + qs;  // continue moving right
            end else if (~landed_o) begin  // moving left
                if (qx < qs) begin  // hitting left of screen?
                    qx <= 0;  // move left as far as we can
                    qdx <= 0;  // move right next frame
                    if (!(qy + qs + 80 >= 469)) begin
                       qy <= qy + qs + 40;
                    end else begin
                        landed_o = 1'b1;
                    end
                end else qx <= qx - qs;  // continue moving left
            end

            // vertical position
            // if (qdy == 0) begin  // moving down
            //     if (qy + Q_SIZE + qs >= V_RES-1) begin  // hitting bottom of screen?
            //         qy <= V_RES - Q_SIZE - 1;  // move down as far as we can
            //         // qdy <= 1;  // move up next frame
            //     end else qy <= qy + qs;  // continue moving down
            // end 
            // else begin  // moving up
            //     if (qy < qs) begin  // hitting top of screen?
            //         qy <= 0;  // move up as far as we can
            //         qdy <= 0;  // move down next frame
            //     end else qy <= qy - qs;  // continue moving up
            // end
        end
    end

    logic [0:0] enemy;
    always_comb begin
        enemy = (sx_i >= qx) && (sx_i < qx + Q_SIZE) && (sy_i >= qy) && (sy_i < qy + Q_SIZE);
        // dead_o = 1'b0;
        // if (enemy && player_top_bullet_pos_i) begin
        //     enemy = 1'b0;
        //     dead_o = 1'b0;
        // end
    end

	always_ff @(posedge clk_i) begin
		if (enemy && player_bullet_area_i) begin
			dead_o <= 1'b1;
		end else begin
			dead_o <= 1'b0;
		end
	end
    
	assign draw_enemy = enemy;
	assign enemy_r_o = color_p[11:8];
	assign enemy_g_o = color_p[7:4];
	assign enemy_b_o = color_p[3:0];

endmodule