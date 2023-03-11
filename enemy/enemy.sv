module enemy 
	#(parameter [11:0] color_p = 12'b1111_1111_1111)

	(
	.input [0:0] clk_i,
	.input [0:0] reset_i,
	.input [0:0] all_ships_dead_i,		//all ships have been destroyed
	.input [0:0] hit_i,					//hit by the player
	.output	[9:0] left_pos_o,			//ship left position
	.output [9:0] right_pos_o,			//ship right position
	.output [9:0] top_pos_o,			//ship top position
	.output [9:0] bot_pos_o,			//ship bot position
	.output [0:0] landed_o,				//ship has landed thus game over
	.output [0:0] dead_o,				//ship is dead
	);

	/****************************************************************************
	 *Implements a single enemey space ship 
	 *States are as follow:
	 *Idle Ship: not displayed and dead 
	 *Right: moves the ship to the right until border is hit every second
	 *Left: moves the ship to the left until border is hit every second
	 *Dead: signals that the ship is dead and also not displayed no respawn
	 ***************************************************************************/
	
endmodule
