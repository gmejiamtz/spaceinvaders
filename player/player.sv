module player 
	#(parameter [11:0] color_p = 12'b0110_0000_0101)
	(input [0:0] clk_i 			//clock
	,input [0:0] reset_i		//reset button
	,input [0:0] move_left_i 	//move left
	,input [0:0] shoot_i 		//shoot and start and resume levels 
	,input [0:0] move_right_i 	//move right
	,input [0:0] hit_i 			//hit by enemy
	,output [0:0] alive_o		//player has more than 0 lives
	,output [9:0] pos_left_o	//left most position of player
	,output [9:0] pos_right_o	//right most position of player
	,output [0:0] level_beat_o	//player finished level no reset needed
	,output [0:0] game_won_o	//game won and requires manual reset
	,output [4:0] next_states	//outputs next states for debugging
	,output [4:0] pres_states	//outputs present states for debugging
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
	enum logic [5:0] {
		not_moving_and_alive   = 	6'b000001,
		moving_left_and_alive  = 	6'b000010,
		moving_right_and_alive = 	6'b000100,
		player_shot_and_alive  =	6'b001000,
		player_shot_and_dead   = 	6'b010000,
		player_beat_game	   =	6'b100000	
	} states;


	//state busses
	logic [5:0] present_l,next_l;
	//1 bit outputs
	logic [0:0] alive_l,level_beat_l,game_won_l,lose_life;
	//position busses 
	logic [9:0] left_l,right_l;
	//lives counter output
	logic [1:0] lives_counter_l;
	//level counter
	logic [8:0] level_counter_l;


	//state machine always_ff block
	//resets to 5'b00001
	always_ff @(posedge clk_i) begin
		if (reset_i) begin
			present_l <= 5'b00001;
		end else begin
			present_l <= next_l;
		end
	end

	//counter for lives
	//resets on reset input or resuming from either dead states 
	//increments on beating an even level if the max lives is not reached yet
	//decrements when the player is hit 
	counter #(.width_p(2),.reset_val_p(2'b10)) lives_counter_inst 
		(.clk_i(clk_i),
		.reset_i(reset_i),
		.up_i(level_beat_l & (lives_counter_l < 2'b11)),
		.down_i(lost_life & (lives_counter_l > 0)),
		.counter_o(lives_counter_l));


	//counter for levels
	counter #(.width_p(9),.reset_val_p(9'b0_0000_0001)) level_counter_inst 
		(.clk_i(clk_i),.reset_i(reset_i | level_counter_l[8]),
		.up_i(level_beat_l & ~present_l[5]),
		.down_i(1'b0),.counter_o(level_counter_l));


	//combinational logic for next states
	always_comb begin
		case (present_l)
			not_moving_and_alive: begin
				alive_l = 1'b1;
				lost_life = 1'b0;
				//stays in state 0
				if(~(move_right_i ^ move_left_i)) begin
					next_l = not_moving_and_alive;
				end
				//moves left
				if(~move_right_i & move_left_i) begin
					next_l = moving_left_and_alive; 
				end
				//move right
				if(move_right_i & ~move_left_i) begin
					next_l = moving_right_and_alive; 
				end
				//need logic to get hit by enemy
				if(hit_i & (lives_counter_life > 1)) begin
					lost_life = 1'b1;
					next_l = player_shot_and_alive;
				end
				//player loses game 
				if(hit_i & (lives_counter_life == 2'b00)) begin
					alive_l = 1'b0;
					next_l = player_shot_and_dead;
				end
			end

			moving_left_and_alive: begin
				alive_l = 1'b1;
				lost_life = 1'b0;
				//stay in state 1
				if(move_left_i & ~move_right & ~hit_left_border)
			end

				

		endcase
	end


endmodule

