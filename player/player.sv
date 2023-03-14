module player 
	#(parameter [11:0] color_p = {4'h5, 4'hE, 4'h5})
	//parameter bus is color in {Red,Green,Blue} format
	
	(input [0:0] clk_i 			//clock
	,input [0:0] reset_i		//reset button
	,input [0:0] move_left_i 	//move left - left button
	,input [0:0] shoot_i 		//shoot and start and resume levels - center button
	,input [0:0] frame_i		//input for a frame
	,input [0:0] move_right_i 	//move right -right button
	,input [0:0] hit_i 			//hit by enemy
	,input [0:0] hit_enemy_i	//player shoot enemy and can shoot again
	,input [0:0] add_life_i		//add a life due to beating levels
	,output [0:0] alive_o		//player has more than 0 lives
	,output [9:0] pos_left_o	//left most position of player
	,output [9:0] pos_right_o	//right most position of player
	,output [9:0] gun_left_o	//location of gun, half of the ship size plus 1
	,output [9:0] gun_right_o	//location of gun
	,output [3:0] player_red_o	//ammount of red the player is for display
	,output [3:0] player_green_o//ammount of green the player is for display
	,output [3:0] player_blue_o	//ammount of blue the player is for display
	,output [4:0] next_states_o	//outputs next states for debugging
	,output [4:0] pres_states_o	//outputs present states for debugging
	,output [0:0] bullet_o		//high when bullet flying
	,output [9:0] bullet_left_o //left side of bullet
	,output [9:0] bullet_right_o//right side of bullet
	,output [9:0] bullet_top_o  //top of bullet
	,output [9:0] bullet_bot_o	//bot of bullet
	,output [1:0] bullet_pres_o
	,output [1:0] bullet_next_o
	,output [0:0] bullet_not_border
	);

	/****************************************************************************
	 * Implements a state machine representing the player ship
	 * States are as follows:
	 * State 0: Stationary but alive: not moving and not dead - can shoot
	 * State 1: Moving left - moves left until border - can shoot
	 * State 2: Moving right - moves right until border - can shoot
	 * State 3: Lost Life but not dead - hit by bullet but not dead
	 * -flash ship and freeze level until button 1 is pressed to resume game 
	 * -resumes paused level with button 1 press
	 * State 4: Lost Life and Dead - hit by bullet and lost all lives
	 * -ship removed from screen and display lost game message
	 * -resumes game with button 1 but will reset level and lives and score
	 ***************************************************************************/
	
	//state enum for player state machine
	typedef enum logic [4:0] {
		player_state_failed	   =	5'b00000, //state 5
		not_moving_and_alive   = 	5'b00001, //state 0
		moving_left_and_alive  = 	5'b00010, //state 1
		moving_right_and_alive = 	5'b00100, //state 2
		player_shot_and_alive  =	5'b01000, //state 3
		player_shot_and_dead   = 	5'b10000  //state 4
	}states; 
	typedef	enum logic [1:0] {
		bullet_can_shoot = 2'b01,
		bullet_is_flying = 2'b10
	}bullet_state;
	
	
	//state busses
	logic [4:0] present_l,next_l;
	//1 bit outputs
	logic [0:0] alive_l,lose_life,reset_player_pos,player_left,player_right,
		new_game_l,bullet_active,latch_shoot;
	//position busses 
	logic [9:0] left_l,right_l,gun_pos_l,gun_pos_r,
		step_left,left_reset,bullet_pres_top,
		bullet_pres_bot,
		bullet_pres_left;
	//lives counter output
	logic [1:0] lives_counter_l,live_step,live_reset,
		bullet_next,bullet_pres;
	//left border max
	localparam left_border = 9;
	localparam right_border = 629;

	//bullet info
	logic [0:0] bullet_hit_something,bullet_move_up,reset_bullet;
	


	//state machine always_ff block
	//resets to 5'b00001
	always_ff @(posedge clk_i) begin
		if (reset_i) begin
			present_l <= 5'b00001;
		end else begin

			present_l <= next_l;
			//assert (next_l != player_state_failed) else 
			//$display("Asserted next_l != player_state_failed! State has been lost!");

		end
	end

	//bullet fsm and info needed
	always_ff @(posedge clk_i) begin
		if (~bullet_active) begin
			bullet_pres_left <= left_l + 10'd17;
		end else if(shoot_i & ~bullet_active) begin
			bullet_pres_left <= left_l + 10'd17;
		end
	end

	always_ff @(posedge clk_i) begin
		if(reset_i) begin
			bullet_pres <= bullet_can_shoot;
		end else begin
			bullet_pres <= bullet_next;
		end
	end
	always_ff @(posedge clk_i) begin
		if(~shoot_i & (bullet_pres_top == 10'd424) | (bullet_pres_top <= 10'd10)) begin
			latch_shoot <= 1'b0;
		end else if (shoot_i & (bullet_pres_top == 10'd424)) begin
			latch_shoot <= 1'b1;
		end

	end

		
	//counter for lives
	//resets on reset input or resuming from either dead states 
	//increments on beating an even level if the max lives is not reached yet
	//decrements when the player is hit 
	counter #(.width_p(2),.reset_val_p(2'b10),.step_p(2'b01)) 
		lives_counter_inst 
		(.clk_i(clk_i),
		.reset_i(new_game_l),
		.up_i(add_life_i & (lives_counter_l < 2'b11) & frame_i),
		.down_i(lose_life & (lives_counter_l > 0) & frame_i),
		.load_i(1'b0),.loaded_val_i(2'b00),
		.counter_o(lives_counter_l),
		.step_o(live_step),
		.reset_val_o(live_reset));

	/*
	//counter for levels
	counter #(.width_p(9),.reset_val_p(9'b0_0000_0001)) level_counter_inst 
		(.clk_i(clk_i),.reset_i(reset_i | level_counter_l[8]),
		.up_i(level_beat_l & ~present_l[4]),
		.down_i(1'b0),.counter_o(level_counter_l));
	*/
	//counter to move 
	counter #(.width_p(10),.reset_val_p(10'd249),.step_p(10'd5)) 
		left_player_counter_inst 
		(.clk_i(clk_i),.reset_i(reset_player_pos),
		.up_i(player_right & (right_border > (right_l)) & frame_i),
		.down_i(player_left & (left_border < (left_l)) & frame_i),
		.load_i(1'b0),.loaded_val_i(10'b0),
		.counter_o(left_l),
		.step_o(step_left),
		.reset_val_o(left_reset));

	//counter to move bullet 
	counter #(.width_p(10),.reset_val_p(10'd424),.step_p(10'd10)) 
		bullet_counter_inst 
		(.clk_i(clk_i),.reset_i(reset_bullet),
		.up_i(1'b0),
		.down_i(frame_i & bullet_move_up & (bullet_pres_top > 10'd10)),
		.load_i(1'b0),.loaded_val_i(10'b0),
		.counter_o(bullet_pres_top),
		.step_o(),
		.reset_val_o());



	//combinational logic for next states
	always_comb begin
		right_l = left_l + 10'd40;
		gun_pos_l = (left_l + 10'd15);
		gun_pos_r = (left_l + 10'd25);
		alive_l = 1'b1;
		new_game_l = 1'b0;
		lose_life = 1'b0;
		player_left = 1'b0;
		reset_player_pos = 1'b1;
		player_right = 1'b0;
		case (present_l)
			not_moving_and_alive: 
			begin
				//stays in state 0
				reset_player_pos = 1'b0;
				if(~hit_i &  (
				~(move_right_i ^ move_left_i) | 
				move_left_i & (left_border >= left_l) | move_right_i & (right_border <= right_l))) begin
					next_l = not_moving_and_alive;
				end
				//moves left
				else if(~hit_i & ~move_right_i & move_left_i) begin
					player_left = 1'b1;
					next_l = moving_left_and_alive; 
				end
				//move right
				else if(~hit_i & move_right_i & ~move_left_i) begin
					player_right = 1'b1;
					next_l = moving_right_and_alive; 
				end
				//need logic to get hit by enemy
				else if(hit_i & (lives_counter_l > 2'b00)) begin
					lose_life = 1'b1;
					next_l = player_shot_and_alive;
				end
				//player loses game 
				else if(hit_i & (lives_counter_l == 2'b00)) begin
					alive_l = 1'b0;
					next_l = player_shot_and_dead;
				end 
				//error happened and go to lost game state
				else begin
					next_l = player_state_failed;
				end
			end

			moving_left_and_alive: begin
				player_left = 1'b1;
				reset_player_pos = 1'b0;
				//stay in state 1 - move left
				if(~hit_i & move_left_i & ~move_right_i & (left_border < left_l)) begin
					next_l = moving_left_and_alive;
				end
				//go back to state 0 - dont move 
				else if(~hit_i & (move_left_i & ~move_right_i & (left_border >= left_l) |
				~(move_left_i ^ move_right_i))) begin
					player_left = 1'b0;
					next_l = not_moving_and_alive;
				end
				//go to state 2 - move right
				else if(~move_left_i & move_right_i & ~hit_i) begin
					player_left = 1'b0;
					player_right = 1'b1;
					next_l = moving_right_and_alive;
				end
				//go to state 3 - player shot but still has lives
				else if(hit_i & (lives_counter_l > 2'b00)) begin
					player_left = 1'b0;
					lose_life = 1'b1;
					next_l = player_shot_and_alive;
				end
				//go to state 4 - player shot and has no lives
				else if(hit_i & (lives_counter_l == 2'b00)) begin
					player_left = 1'b0;
					alive_l = 1'b0;
					next_l = player_shot_and_dead;
				end else begin
					next_l = player_state_failed;
				end
			end

			moving_right_and_alive: begin
				player_right = 1'b1;
				//stay in state 1 - move left
				reset_player_pos = 1'b0;
				if(~hit_i & move_left_i & ~move_right_i) begin
					player_right = 1'b0;
					player_left = 1'b1;
					next_l = moving_left_and_alive;
				end
				//go back to state 0 - dont move 
				else if(~hit_i & (move_left_i & ~move_right_i &
					(right_border <= right_l) |
					~(move_left_i ^ move_right_i))) begin
					player_right = 1'b0;
					next_l = not_moving_and_alive;
				end
				//go to state 2 - move right
				else if(~hit_i & (~move_left_i & move_right_i & 
					(right_border > right_l))) begin
					next_l = moving_right_and_alive;
				end
				//go to state 3 - player shot but still has lives
					else if(hit_i & (lives_counter_l > 2'b00)) begin
					lose_life = 1'b1;
					player_right = 1'b0;
					next_l = player_shot_and_alive;
				end
				//go to state 4 - player shot and has no lives
				else if(hit_i & (lives_counter_l == 2'b00)) begin
					alive_l = 1'b0;
					player_right = 1'b0;
					next_l = player_shot_and_dead;
				end else begin
					next_l = player_state_failed;
				end
			end
		
			player_shot_and_alive: begin
			reset_player_pos = 1'b0;
			if(shoot_i & ~(move_left_i ^ move_right_i)) begin
				reset_player_pos = 1'b1;
				next_l = not_moving_and_alive;
			end else if (shoot_i & move_left_i & ~move_right_i) begin
				reset_player_pos = 1'b1;
				player_left = 1'b1;
				next_l = moving_left_and_alive;
			end else if (shoot_i & ~move_left_i & move_right_i) begin
				reset_player_pos = 1'b1;
				player_right = 1'b1;
				next_l = moving_right_and_alive;
			end else begin //i dont think this state can transition to the error state
				next_l = player_shot_and_alive;
			end
			end

			player_shot_and_dead: begin
			alive_l = 1'b0;
			reset_player_pos = 1'b0;
			if(shoot_i & ~(move_left_i ^ move_right_i)) begin
				reset_player_pos = 1'b1;
				alive_l = 1'b1;
				new_game_l = 1'b1;
				next_l = not_moving_and_alive;
			end else if (shoot_i & move_left_i & ~move_right_i) begin
				reset_player_pos = 1'b1;
				player_left = 1'b1;
				alive_l = 1'b1;
				new_game_l = 1'b1;
				next_l = moving_left_and_alive;
			end else if (shoot_i & ~move_left_i & move_right_i) begin
				reset_player_pos = 1'b1;
				player_right = 1'b1;
				alive_l = 1'b1;
				new_game_l = 1'b1;
				next_l = moving_right_and_alive;
			end else begin //i dont think this state can transition to the error state
				next_l = player_shot_and_dead;
			end
			
			end
		//error state if in no state
			player_state_failed:
			next_l = player_state_failed;
		//if in multple states at the same time
			default:
			next_l = present_l;
			
		endcase

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
				if(bullet_move_up & (~hit_enemy_i & (bullet_pres_top > 10'd10))) begin
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

	//assign output

	//colors
	assign player_red_o = color_p[11:8];
	assign player_green_o = color_p[7:4];
	assign player_blue_o = color_p[3:0];
	
	//player data
	assign alive_o = alive_l;
	assign pos_left_o = left_l;
	assign pos_right_o = right_l;
	assign gun_left_o = gun_pos_l;
	assign gun_right_o = gun_pos_r;

	//bullet data
	assign bullet_left_o = bullet_pres_left;
	assign bullet_right_o = bullet_left_o + 10'd6;
	assign bullet_top_o = bullet_pres_top;
	assign bullet_bot_o = bullet_pres_top + 10'd10;
	assign bullet_o = bullet_active;

	assign bullet_pres_o = bullet_pres;
	assign bullet_next_o = bullet_next;	
	assign bullet_not_border = bullet_move_up;
	//debugging state ouputs
	assign next_states_o = next_l;
	assign pres_states_o = present_l;
	
endmodule
