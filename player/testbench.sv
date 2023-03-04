module player 
	#(parameter lives_p = 3
	,parameter [11:0] color_p = 12'b0110_0000_0101)
	(input [0:0] clk_i 			//clock
	,input [0:0] move_left_i 	//move left
	,input [0:0] shoot_i 		//shoot and start and resume levels 
	,input [0:0] move_right_i 	//move right
	,input [0:0] hit_i 			//hit by enemy
	,output [0:0] alive_o		//player has more than 0 lives
	,output [9:0] pos_left_o	//left most position of player
	,output [9:0] pos_right_o	//right most position of player
	,output [0:0] level_beat_o	//player finished level no reset needed
	,output [0:0] game_won_o	//game won and requires manual reset
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
	
	//state busses
	logic [4:0] present_l,next_l;
	//1 bit outputs
	logic [0:0] alive_l,level_beat_l,game_won_l;
	//position busses 
	logic [9:0] left_l,right_l;
endmodule
