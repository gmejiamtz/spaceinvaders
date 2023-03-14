module enemy 
	#(parameter [11:0] color_p = {4'hF,4'hF,4'hF},
	 parameter [9:0] top_start_p = 10'b00_0000_1001,
	 parameter [9:0] left_start_p =10'b00_0000_1001,
	 parameter [9:0] ship_id_p = 10'd1) //ship id pointer
	(
	input [0:0] clk_i,
	input [0:0] reset_i,				//when all ships dead and 5 seconds have passed
	input [0:0] hit_i,					//hit by the player
	input [0:0] frame_i,				//a frame has been processed for timing
	input [0:0] start_i,				//btnC input responding to turn on enemies
	input [9:0]	pixel_avail_i,			//ammount of pixels available for movement
	input [9:0]	top_ship_pointer_i,		//pointer to the ship above
	input [9:0] bot_ship_pointer_i,		//pointer to the ship below
	output [9:0] left_pos_o,			//ship left position
	output [9:0] right_pos_o,			//ship right position
	output [9:0] top_pos_o,				//ship top position
	output [9:0] bot_pos_o,				//ship bot position
	output [0:0] landed_o,				//ship has landed thus game over
	output [0:0] dead_o,				//ship is dead
	output [3:0] enemy_red_o,				//enemy red color 
	output [3:0] enemy_green_o,			//enemy green color
	output [3:0] enemy_blue_o				//enemy blue color
	);

	/****************************************************************************
	 *Implements a single enemey space ship 
	 *States are as follow:
	 *Idle Ship: not displayed and dead 
	 *Right: moves the ship to the right until border is hit every second
	 *Left: moves the ship to the left until border is hit every second
	 *Dead: signals that the ship is dead and also not displayed no respawn
	 ***************************************************************************/
	

	// logic [3:0] next_l, pres_l;
	// logic [0:0] moving_right, moving_left, one_sec, bounce, dead_l;
	// logic [9:0] left_p, right_p, top_p, bot_p,
	// 			step_o_cnt, move_reset_o, move_count,
	// 			next_left, next_right;

	enum logic [3:0] {
		ERROR 		 = 4'b0000,
		IDLE  		 = 4'b0001,
		MOVING_RIGHT = 4'b0010,
		MOVING_LEFT  = 4'b0100,
		DEAD		 = 4'b1000
	} states;

	logic [3:0] present_l, next_l;

	logic [0:0] dead, landed, moving_right, moving_left, bounce;

	logic [9:0] left_l, right_l, top_l, bot_l;

	always_ff @(posedge clk_i) begin
		if(reset_i | new_game) begin
			present_l <= IDLE;
		end else begin
			present_l <= next_l;
		end
	end
	
	logic [0:0] right_boundry_hit, left_boundary_hit, boundary_hit;
	assign right_boundry_hit = (right_l == 10'd629);
	assign left_boundary_hit = (left_l == 10'd0);
	assign boundary_hit = (right_boundry_hit | left_boundary_hit);

	//counter for vertical movements
	counter #(.width_p(10),.reset_val_p(top_start_p),.step_p(10'd10))
		vertical_move_counter_inst 
		(.clk_i(clk_i)
		,.reset_i(reset_i)
		,.up_i(frame_i & boundry_hit & ~landed_o)
		,.down_i('0)
		,.load_i('0)
		,.loaded_val_i('0)
		,.counter_o(top_p)
		,.step_o()
		,.reset_val_o());

	//counter for horizontal movements
	counter #(.width_p(10), .reset_val_p(10'd99), .step_p(10'd10))
		horizontal_move_counter_inst 
		(.clk_i(clk_i)
		,.reset_i(reset_i)
		,.up_i(frame_i & (moving_left | moving_right) & ~boundary_hit)
		,.down_i('0)
		,.load_i(right_boundary_hit)
		,.loaded_val_i('0)
		,.counter_o(move_count)
		,.step_o()
		,.reset_val_o());

	//registers for left pole
	always_ff @(posedge clk_i) begin
		if(reset_i) begin
			left_l <= left_start_p;
		end else begin 
			left_l <= next_left;
		end
	end

	always_comb begin
		bounce = 1'b0;
		moving_right = 1'b0;
		moving_left = 1'b0;
		next_left = left_l;
		next_right = next_left + 10'd40;
		dead_l = 1'b0;
		case (pres_l)
			IDLE: begin
				if (start_i) begin
					next_l = MOVING_RIGHT;
				end else begin
					next_l = IDLE;
				end
			end
			
			MOVING_RIGHT: begin
				moving_right = 1'b1;
				next_left = left_l + move_count;
				if(((move_count + 1'b1) == pixel_avail_i) & ~hit_i ) begin
					bounce = 1'b1;
					next_l = MOVING_LEFT;
				end else if (((move_count + 1'b1) != pixel_avail_i) & ~hit_i & left_boundary_hit) begin
					bounce = 1'b0;
					next_l = MOVING_RIGHT;
				end else begin
					bounce = 1'b0;
					dead_l = 1'b1;
					next_l = DEAD;
				end
			end
		
			MOVING_LEFT: begin
				moving_left = 1'b1;
				next_left = left_l - move_count;
				if(((move_count+ 1'b1) == pixel_avail_i)&~hit_i ) begin
					bounce = 1'b0;
					next_l = MOVING_RIGHT;
				end else if (((move_count + 1'b1) != pixel_avail_i) & ~hit_i & right_boundry_hit) begin
					bounce = 1'b0;
					next_l = MOVING_LEFT;
				end else begin
					bounce = 1'b0;
					dead_l = 1'b1;
					next_l = DEAD;
				end
			end

			DEAD: begin
				dead_l = 1'b1;
				if (start_i) begin
					dead_l = 1'b0;
					next_l = MOVING_RIGHT;
				end else begin
					next_l = dead;
				end
			end
			default:
				next_l = IDLE;
		endcase
	end

	assign enemy_red_o = color_p[11:8];
	assign enemy_green_o = color_p[7:4];
	assign enemy_blue_o = color_p[3:0];

	assign left_pos_o = left_l;
	assign right_pos_o = right_p;
	assign top_pos_o = top_p;
	assign bot_pos_o = top_p - 10'd10;

endmodule
