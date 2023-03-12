module enemy 
	#(parameter [11:0] color_p = 12'b1111_1111_1111,
	 parameter [9:0] top_start_p = 10'b00_0000_1001,
	 parameter [9:0] left_start_p =10'b00_0000_1001,
	 parameter [9:0] ship_id_p = 10'd1)
	(
	input [0:0] clk_i,
	input [0:0] reset_i,				//when all ships dead and 5 seconds have passed
	input [0:0] hit_i,					//hit by the player
	input [0:0] frame_i,				//a frame has been processed for timing
	input [9:0]	pixel_avail_i,			//ammount of pixels available for movement
	input [9:0]	top_ship_pointer_i,		//pointer to the ship above
	input [9:0] bot_ship_pointer_i,		//pointer to the ship below
	output [9:0] left_pos_o,			//ship left position
	output [9:0] right_pos_o,			//ship right position
	output [9:0] top_pos_o,				//ship top position
	output [9:0] bot_pos_o,				//ship bot position
	output [0:0] landed_o,				//ship has landed thus game over
	output [0:0] dead_o					//ship is dead
	);

	/****************************************************************************
	 *Implements a single enemey space ship 
	 *States are as follow:
	 *Idle Ship: not displayed and dead 
	 *Right: moves the ship to the right until border is hit every second
	 *Left: moves the ship to the left until border is hit every second
	 *Dead: signals that the ship is dead and also not displayed no respawn
	 ***************************************************************************/
	
	enum logic [3:0]{
		error = 4'b0000,
		idle  = 4'b0001,
		right = 4'b0010,
		left  = 4'b0100,
		dead  = 4'b1000
	}states;

	logic[3:0] next_l,pres_l;
	logic [0:0] moving_right,moving_left,one_sec;
	logic[9:0] left_p,right_p,top_p,bot_p,
		step_o_cnt,move_reset_o;

	always_ff @(posedge clk_i) begin
		if(reset_i) begin
			pres_l <= idle;
		end else begin
			pres_l <= next_l;
		end
	end
	
	//counter for vertical movements
	counter #(.width_p(10),.reset_val_p(top_start_p),.step_p(10'd10))
		vertical_move_counter_inst (
		.clk_i(clk_i),.reset_i(reset_i),.up_i(frame_i & boundry_hit& ~landed_o),
		.down_i(1'b0),.load_i(1'b0),.loaded_val_i(10'b0),
		.counter_o(top_l),.step_o(step_o_cnt),.reset_val_o(move_reset_o));
	//counter for horizontal movements
	counter #(.width_p(10),.reset_val_p(left_start_p),.step_p(10'd10))
		horizontal_move_counter_inst (
		.clk_i(clk_i),.reset_i(reset_i),.up_i(frame_i & (moving_left | moving_right)),
		.down_i(1'b0),.load_i(1'b0),.loaded_val_i(10'b0),
		.counter_o(top_l),.step_o(step_o_cnt),.reset_val_o(move_reset_o));
	
	

endmodule
