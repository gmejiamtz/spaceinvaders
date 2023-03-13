module player 
	#(parameter [11:0] color_p = {4'h5, 4'hE, 4'h5})
	//parameter bus is color in {Red,Green,Blue} format
	
	(input [0:0] clk_i 			//clock
	,input [0:0] reset_i		//reset button
	,input [0:0] move_left_i 	//move left - left button
	,input [0:0] shoot_i 		//shoot and start and resume levels - center button
	,input [0:0] move_right_i 	//move right -right button
	,input [0:0] hit_i 			//hit by enemy
	,input [0:0] add_life_i		//add a life due to beating levels
	,output [0:0] alive_o		//player has more than 0 lives
	,output [0:0] shot_laser_o	//spawn bullet
	,output [0:0] resume_o		//resuming a game
	,output [9:0] pos_left_o	//left most position of player
	,output [9:0] pos_right_o	//right most position of player
	,output [9:0] gun_pos_o		//location of gun, half of the ship size plus 1
	,output [3:0] player_red_o	//ammount of red the player is for display
	,output [3:0] player_green_o//ammount of green the player is for display
	,output [3:0] player_blue_o	//ammount of blue the player is for display
	,output [4:0] next_states_o	//outputs next states for debugging
	,output [4:0] pres_states_o	//outputs present states for debugging
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
	enum logic [4:0] {
		player_state_failed	   =	5'b00000, //state 5
		not_moving_and_alive   = 	5'b00001, //state 0
		moving_left_and_alive  = 	5'b00010, //state 1
		moving_right_and_alive = 	5'b00100, //state 2
		player_shot_and_alive  =	5'b01000, //state 3
		player_shot_and_dead   = 	5'b10000  //state 4
	}states; 
	
	
	//state busses
	logic [4:0] present_l,next_l;
	//1 bit outputs
	logic [0:0] alive_l,lose_life,reset_player_pos,player_left,player_right,
		new_game_l;
	//position busses 
	logic [9:0] left_l,right_l,gun_pos_l,step_left,left_reset;
	//lives counter output
	logic [1:0] lives_counter_l,live_step,live_reset;
	//left border max
	localparam left_border = 9;
	localparam right_border = 619;
	


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

	//counter for lives
	//resets on reset input or resuming from either dead states 
	//increments on beating an even level if the max lives is not reached yet
	//decrements when the player is hit 
	counter #(.width_p(2),.reset_val_p(2'b10),.step_p(2'b01)) 
		lives_counter_inst 
		(.clk_i(clk_i),
		.reset_i(new_game_l),
		.up_i(add_life_i & (lives_counter_l < 2'b11)),
		.down_i(lose_life & (lives_counter_l > 0)),
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
	counter #(.width_p(10),.reset_val_p(10'd249),.step_p(10'd10)) 
		left_player_counter_inst 
		(.clk_i(clk_i),.reset_i(reset_player_pos),
		.up_i(player_right & (right_border > (right_l))),
		.down_i(player_left & (left_border < (left_l))),
		.load_i(1'b0),.loaded_val_i(10'b0),
		.counter_o(left_l),
		.step_o(step_left),
		.reset_val_o(left_reset));


	//combinational logic for next states
	always_comb begin
		right_l = left_l + 10'd40;
		gun_pos_l = (right_l >> 1) - 10'd5;
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
	assign gun_pos_o = gun_pos_l;

	//debugging state ouputs
	assign next_states_o = next_l;
	assign pres_states_o = present_l;
	
endmodule

