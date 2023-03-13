module enemy 
	#(parameter [11:0] color_p = 12'b1111_1111_1111,
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
	logic [0:0] moving_right,moving_left,one_sec,bounce,dead_l;
	logic[9:0] left_p,right_p,top_p,bot_p,
		step_o_cnt,move_reset_o,move_count,
		next_left,next_right;

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
	counter #(.width_p(10),.reset_val_p(10'99),.step_p(10'd10))
		horizontal_move_counter_inst (
		.clk_i(clk_i),.reset_i(reset_i),
		.up_i(frame_i & (moving_left | moving_right)),
		.down_i(1'b0),.load_i(bounce),.loaded_val_i(10'b0),
		.counter_o(move_count),.step_o(step_o_cnt),
		.reset_val_o(move_reset_o));

	//registers for left pole

	always_ff @(posedge clk_i) begin
		if(reset_i) begin
			left_p <= left_start_p;
		end else begin 
			left_p <= next_left;
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
			idle : begin
				if(start_i) begin
					next_l = right;
				end else begin
					next_l = idle;
				end
			end
			
			right: begin
				moving_right = 1'b1;
				next_left = left_l + move_count;
				if(((move_count+ 1'b1) == pixel_avail_i)&~hit_i ) begin
					bounce = 1'b1;
					next_l = left;
				end else if (((move_count + 1'b1) != pixel_avail_i) & ~hit_i) begin
					bounce = 1'b0;
					next_l = right;
				end else begin
					bounce = 1'b0;
				dead_l = 1'b1;
					next_l = dead;
				end

			end
		
			left: begin

			moving_left = 1'b1;
			next_left = left_l - move_count;
				if(((move_count+ 1'b1) == pixel_avail_i)&~hit_i ) begin
					bounce = 1'b1;
					next_l = right;
				end else if (((move_count + 1'b1) != pixel_avail_i) & ~hit_i) begin
					bounce = 1'b0;
					next_l = left;
				end else begin
					bounce = 1'b0;
				dead_l = 1'b1;
					next_l = dead;
				end

			end

			dead: 
				dead_l = 1'b1;
				if(start_i) begin
					
				end

endmodule
