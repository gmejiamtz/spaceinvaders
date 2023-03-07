module player 
	#(parameter lives_p = 3
	,parameter [11:0] color_p = 12'b0110_0000_0101)
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
	enum logic [4:0] {
		not_moving_and_alive   = 	5'b00001,
		moving_left_and_alive  = 	5'b00010,
		moving_right_and_alive = 	5'b00100,
		player_shot_and_alive  =	5'b01000,
		player_shot_and_dead   = 	5'b10000
	} states;


	//state busses
	logic [4:0] present_l,next_l;
	//1 bit outputs
	logic [0:0] alive_l,level_beat_l,game_won_l;
	//position busses 
	logic [9:0] left_l,right_l;

	//state machine always_ff block
	//resets to 5'b00001
	always_ff @(posedge clk_i) begin
		if (reset_i) begin
			present_l <= 5'b00001;
		end else begin
			present_l <= next_l;
		end
	end

	//combinational logic for next states
	always_comb begin
		case (present_l)
			not_moving_and_alive: begin
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
			end
				

		endcase
	end


endmodule

