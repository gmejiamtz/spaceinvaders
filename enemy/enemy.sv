module enemy 
	#(parameter [11:0] color_p = {4'hF,4'hF,4'hF},
	  parameter [9:0] top_start_p = 10'b00_0000_1001,
	  parameter [9:0] left_start_p =10'b00_0000_1001,
	  parameter [9:0] ship_id_p = 10'd1,
	  parameter [15:0] bullet_delay_p = 16'd5) //ship id pointer
	(
	input  [0:0] clk_i,
	input  [0:0] reset_i,				//when all ships dead and 5 seconds have passed
	input  [0:0] hit_i,					//hit by the player
	input  [0:0] frame_i,				//a frame has been processed for timing
	input  [0:0] all_dead_i,			//ensures that all are dead
	input  [9:0] pixel_avail_i,		    //ammount of pixels available for movement
	input  [0:0] pointed_to_i,			//this is the last one in the column
	input  [0:0] is_front_o, 			//is the front of the column
	input  [0:0] hit_player_i,			//hit the player
	input  [9:0] player_bullet_pos_top_i,	//player bullet top position
	input  [9:0] player_bullet_pos_bot_i,	//player bullet bot position
	input  [9:0] player_bullet_pos_left_i,	//player bullet left position
	input  [9:0] player_bullet_pos_right_i,	//player bullet right position
	output [9:0] left_pos_o,			//ship left position
	output [9:0] right_pos_o,			//ship right position
	output [9:0] top_pos_o,				//ship top position
	output [9:0] bot_pos_o,				//ship bot position
	output [0:0] landed_o,				//ship has landed thus game over
	output [0:0] dead_o,				//ship is dead
	output [3:0] enemy_red_o,			//enemy red color 
	output [3:0] enemy_green_o,			//enemy green color
	output [3:0] enemy_blue_o			//enemy blue color
	);


	/****************************************************************************
	 *Implements a single enemey space ship 
	 *States are as follow:
	 *Idle Ship: not displayed and dead 
	 *Right: moves the ship to the right until border is hit every second
	 *Left: moves the ship to the left until border is hit every second
	 *Dead: signals that the ship is dead and also not displayed no respawn
	 ***************************************************************************/
	
	enum logic [3:0] {
		ERROR 		 = 4'b0000,
		IDLE  		 = 4'b0001,
		MOVING_RIGHT = 4'b0010,
		MOVING_LEFT  = 4'b0100,
		DEAD		 = 4'b1000
	} states;

	/*----- State Flags -----*/
	logic [3:0] present_l, next_l;

	logic [0:0] dead_l, landed, moving_right, moving_left, bounce;

	logic [9:0] left_l, right_l, top_l, bot_l;
	logic [9:0] next_left, next_right;
	logic [9:0] vertical_count, horizontal_count;

	always_ff @(posedge clk_i) begin
		if(reset_i) begin
			present_l <= IDLE;
		end else begin
			present_l <= next_l;
		end
	end
	
	/*----- Bullet Delay Counter -----*/
	// 1 sec = 60 frames, 2 sec = 120 frames
	logic [9:0] sec_count;
	counter #(.width_p(10), .reset_val_p(10'd0), .step_p(10'd1))
		delay_counter_inst
		(.clk_i(clk_i)
		,.reset_i(reset_i)
		,.up_i(frame_i)
		,.down_i('0)
		,.load_i((sec_count == (bullet_delay_p * 60) + 1) | hit_i)
		,.loaded_val_i('0)
		,.counter_o(sec_count)
		/* verilator lint_off PINCONNECTEMPTY */
		,.step_o()
		,.reset_val_o()
		/* verilator lint_on PINCONNECTEMPTY */
		);
	
	wire [0:0] right_boundary_hit, left_boundary_hit, boundary_hit;
	assign right_boundary_hit = (right_l == 10'd629);
	assign left_boundary_hit = (left_l == 10'd9);
	assign boundary_hit = (right_boundary_hit | left_boundary_hit);

	//counter for vertical movements
	counter #(.width_p(10),.reset_val_p(top_start_p),.step_p(10'd10))
		vertical_move_counter_inst 
		(.clk_i(clk_i)
		,.reset_i(reset_i)
		,.up_i(frame_i & boundary_hit & ~landed_o)
		,.down_i('0)
		,.load_i('0)
		,.loaded_val_i('0)
		,.counter_o(vertical_count)
		/* verilator lint_off PINCONNECTEMPTY */
		,.step_o()
		,.reset_val_o()
		/* verilator lint_on PINCONNECTEMPTY */
		);

	//counter for horizontal movements
	counter #(.width_p(10), .reset_val_p(10'd99), .step_p(10'd10))
		horizontal_move_counter_inst 
		(.clk_i(clk_i)
		,.reset_i(reset_i)
		,.up_i(frame_i & (moving_left | moving_right) & ~boundary_hit & ~all_dead_i)
		,.down_i('0)
		,.load_i(right_boundary_hit)
		,.loaded_val_i('0)
		,.counter_o(horizontal_count)
		/* verilator lint_off PINCONNECTEMPTY */
		,.step_o()
		,.reset_val_o()
		/* verilator lint_on PINCONNECTEMPTY */
		);

	logic [15:0] bullet_count;
	counter #(.width_p(10), .reset_val_p(top_pos_o + 20), .step_p(10'd10))
		enemy_bullet_counter_inst
		(.clk_i(clk_i)
		,.reset_i(reset_bullet)
		,.up_i(frame_i & bullet_move_up & (bullet_pres_bot < 10'd469) & pointed_to_i)
		,.down_i('0)
		,.load_i('0)
		,.loaded_val_i('0)
		,.counter_o(bullet_count)
		/* verilator lint_off PINCONNECTEMPTY */
		,.step_o()
		,.reset_val_o()
		/* verilator lint_on PINCONNECTEMPTY */
		);

	//registers for left pole
	always_ff @(posedge clk_i) begin
		if(reset_i) begin
			left_l <= left_start_p;
		end else begin 
			left_l <= next_left;
		end
	end

	/*----- Logic for bullet FSM -----*/
	logic [0:0] bullet_move_up, reset_bullet, bullet_active,
				bullet_next, bullet_pres, bullet_pres_top, bullet_pres_bot,
				bullet_hit_something, bullet_can_shoot, latch_shoot,
				bullet_is_flying;

	always_comb begin
		bounce = 1'b0;
		moving_right = 1'b0;
		moving_left = 1'b0;
		next_left = left_l;
		next_right = next_left + 10'd40;
		dead_l = 1'b0;
		case (present_l)
			MOVING_RIGHT: begin
				moving_right = 1'b1;
				next_left = left_l + horizontal_count;
				if(((horizontal_count + 1'b1) == pixel_avail_i) & ~hit_i) begin
					bounce = 1'b1;
					next_l = MOVING_LEFT;
				end else if (((horizontal_count + 1'b1) != pixel_avail_i) & ~hit_i & left_boundary_hit) begin
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
				next_left = left_l - horizontal_count;
				if(((horizontal_count+ 1'b1) == pixel_avail_i)&~hit_i ) begin
					bounce = 1'b0;
					next_l = MOVING_RIGHT;
				end else if (((horizontal_count + 1'b1) != pixel_avail_i) & ~hit_i & right_boundary_hit) begin
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
				next_l = DEAD;
			end
			default:
				next_l = DEAD;
		endcase

		/*----- Enemy Bullet FSM -----*/
		bullet_move_up = 1'b0;
		bullet_hit_something = 1'b0;
		reset_bullet = 1'b0;
		bullet_active = 1'b0;
		case (bullet_pres)
			bullet_can_shoot: begin
				if(latch_shoot) begin
					bullet_active = 1'b1;
					bullet_move_up = 1'b1;
					bullet_next = bullet_is_flying;
				end else begin
					reset_bullet = 1'b1;
					bullet_move_up = 1'b0;
					bullet_active = 1'b0;
					bullet_next = bullet_can_shoot;
				end
			end

			bullet_is_flying: begin
				bullet_move_up = 1'b1;
				reset_bullet = 1'b0;
				bullet_active = 1'b1;
				if(bullet_move_up & (~hit_player_i & (bullet_pres_top > 10'd10))) begin
					bullet_move_up = 1'b1;
					reset_bullet = 1'b0;
					bullet_active = 1'b1;
					bullet_next = bullet_is_flying;
				end else begin
					bullet_active = 1'b0;
					reset_bullet = 1'b1;
					bullet_move_up = 1'b0;
					bullet_next = bullet_can_shoot;
				end
			end

			default:
				bullet_next = bullet_pres;
			
		endcase
	end

	

	assign enemy_red_o = color_p[11:8];
	assign enemy_green_o = color_p[7:4];
	assign enemy_blue_o = color_p[3:0];

	assign dead_o = dead_l;
	assign left_pos_o = left_l;
	assign right_pos_o = right_l;
	assign top_pos_o = vertical_count + 10'd10;
	assign bot_pos_o = vertical_count + 10'd30;

endmodule
