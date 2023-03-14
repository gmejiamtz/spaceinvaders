`timescale 1ns/1ps
module testbench();
   localparam iterations_lp = 128;

   logic [0:0] reset_done = 1'b0;
   //inputs
   logic [0:0] left_i;
   logic [0:0] right_i;
   logic [0:0] shoot_i;
   logic [0:0] hit_i;
   logic [0:0] add_life_i;
   //outputs
	logic[0:0] alive_o,shot_laser_o,resume_o,reset_l,bullet_o,bullet_border;
	logic[9:0] left_pos_o,right_pos_o,gun_left_o,bullet_left,bullet_right,
      bullet_top,bullet_bot,gun_right_o;
   logic [1:0] bullet_present,bullet_next;
	logic [3:0] player_red_o,
		player_green_o,player_blue_o;
	logic[4:0] next_l, pres_l; 
   //clock
   wire [0:0]  clk_i;
   wire [0:0]  reset_i;
   wire [0:0]  error_counter_o;

   int			  itervar,errors;
   logic [5:0]		  test_vector [0:iterations_lp-1];

   initial begin
   		//test vector will hold:
		//{reset_i,add_life_i,hit_i,left_i,shoot_i,right_i}
      test_vector[7'h00] = 6'b10_0000;
      test_vector[7'h01] = 6'b10_0000;
      test_vector[7'h02] = 6'b10_0000;
      test_vector[7'h03] = 6'b10_0000;
      
      test_vector[7'h04] = 6'b00_0001;
      test_vector[7'h05] = 6'b00_0001;
      test_vector[7'h06] = 6'b00_0001;
      test_vector[7'h07] = 6'b00_0001;
      
      test_vector[7'h08] = 6'b00_0110;
      test_vector[7'h09] = 6'b00_0110;
      test_vector[7'h0a] = 6'b00_0110;
      test_vector[7'h0b] = 6'b00_0110;
      
      test_vector[7'h0c] = 6'b00_0101;
      test_vector[7'h0d] = 6'b00_0101;
      test_vector[7'h0e] = 6'b00_0101;
      test_vector[7'h0f] = 6'b00_0101;
      
      test_vector[7'h10] = 6'b00_0100;
      test_vector[7'h11] = 6'b00_0100;
      test_vector[7'h12] = 6'b00_0100;
      test_vector[7'h13] = 6'b00_0100;
      
      test_vector[7'h14] = 6'b00_0100;
      test_vector[7'h15] = 6'b00_0100;
      test_vector[7'h16] = 6'b00_0100;
      test_vector[7'h17] = 6'b00_0100;
      
      test_vector[7'h18] = 6'b00_0100;
      test_vector[7'h19] = 6'b00_0100;
      test_vector[7'h1a] = 6'b00_0100;
      test_vector[7'h1b] = 6'b00_0100;
      
      test_vector[7'h1c] = 6'b00_0100;
      test_vector[7'h1d] = 6'b00_0100;
      test_vector[7'h1e] = 6'b00_0100;
      test_vector[7'h1f] = 6'b00_0100;
      
      test_vector[7'h20] = 6'b00_0100;
      test_vector[7'h21] = 6'b00_0100;
      test_vector[7'h22] = 6'b00_0100;
      test_vector[7'h23] = 6'b00_0100;
      
      test_vector[7'h24] = 6'b00_0100;
      test_vector[7'h25] = 6'b00_0100;
      test_vector[7'h26] = 6'b00_0100;
      test_vector[7'h27] = 6'b00_0100;
      
      test_vector[7'h28] = 6'b00_0100;
      test_vector[7'h29] = 6'b00_0100;
      test_vector[7'h2a] = 6'b00_0100;
      test_vector[7'h2b] = 6'b00_0100;
      
      test_vector[7'h2c] = 6'b00_0100;
      test_vector[7'h2d] = 6'b00_0100;
      test_vector[7'h2e] = 6'b00_0100;
      test_vector[7'h2f] = 6'b00_0100;
      
      test_vector[7'h30] = 6'b00_0100;
      test_vector[7'h31] = 6'b00_0100;
      test_vector[7'h32] = 6'b00_0100;
      test_vector[7'h33] = 6'b00_0100;
      
      test_vector[7'h34] = 6'b00_0100;
      test_vector[7'h35] = 6'b00_0100;
      test_vector[7'h36] = 6'b00_0100;
      test_vector[7'h37] = 6'b00_0100;
      
      test_vector[7'h38] = 6'b00_0100;
      test_vector[7'h39] = 6'b00_0100;
      test_vector[7'h3a] = 6'b00_0100;
      test_vector[7'h3b] = 6'b00_0100;
      
      test_vector[7'h3c] = 6'b00_0100;
      test_vector[7'h3d] = 6'b00_0100;
      test_vector[7'h3e] = 6'b00_0100;
      test_vector[7'h3f] = 6'b00_0100;
   end

   nonsynth_clock_gen
     #(.cycle_time_p(10))
   cg
     (.clk_o(clk_i));

   nonsynth_reset_gen
     #(.num_clocks_p(1)
      ,.reset_cycles_lo_p(1)
      ,.reset_cycles_hi_p(10))
   rg
     (.clk_i(clk_i)
     ,.async_reset_o(reset_i));

   player
     #(.color_p(12'b1111_1111_1111))
   dut
     (.clk_i(clk_i)
     ,.reset_i(reset_l & reset_i)
     ,.move_left_i(left_i)
     ,.shoot_i(shoot_i)
     ,.frame_i(1'b1)
     ,.hit_enemy_i(1'b0)
      ,.move_right_i(right_i)
     ,.hit_i(hit_i)
	 ,.add_life_i(add_life_i)
	 ,.alive_o(alive_o)
	,.pos_left_o(left_pos_o)
	,.pos_right_o(right_pos_o)
	,.gun_left_o(gun_left_o)
   ,.gun_right_o(gun_right_o)
	,.player_red_o(player_red_o)
	,.player_green_o(player_green_o)
	,.player_blue_o(player_blue_o)
	,.next_states_o(next_l)
	,.pres_states_o(pres_l)
   ,.bullet_o(bullet_o)
   ,.bullet_left_o(bullet_left)
   ,.bullet_right_o(bullet_right)
   ,.bullet_top_o(bullet_top)
   ,.bullet_bot_o(bullet_bot)
   ,.bullet_pres_o(bullet_present)
   ,.bullet_next_o(bullet_next)
   ,.bullet_not_border(bullet_border)
	);

   initial begin
`ifdef VERILATOR
      $dumpfile("verilator.fst");
`else
      $dumpfile("iverilog.vcd");
`endif
      $dumpvars;

      $display();
      $display("  ______          __  __                    __            __    _ ______ ");
      $display(" /_  __/__  _____/ /_/ /_  ___  ____  _____/ /_     _____/ /_  (_) __/ /_");
      $display("  / / / _ \\/ ___/ __/ __ \\/ _ \\/ __ \\/ ___/ __ \\   / ___/ __ \\/ / /_/ __/");
      $display(" / / /  __(__  ) /_/ /_/ /  __/ / / / /__/ / / /  (__  ) / / / / __/ /_  ");
      $display("/_/  \\___/____/\\__/_.___/\\___/_/ /_/\\___/_/ /_/  /____/_/ /_/_/_/  \\__/  ");

      $display();
      $display("Begin Test:");

      itervar = 0;
	  

	for(itervar = 0; itervar <= iterations_lp; itervar++) begin
	  	$display("Test vector: %b",test_vector[itervar]);
      right_i = test_vector[itervar][0];
      shoot_i = test_vector[itervar][1];
      left_i = test_vector[itervar][2];
      hit_i = test_vector[itervar][3];
      add_life_i = test_vector[itervar][4];
      reset_l = test_vector[itervar][5];
	 	@(posedge clk_i);
      	$display("At Posedge %d: Player state machine data is as follows:",itervar);
		$display("Present States: %b, Next States: %b",pres_l,next_l);
		$display("Inputs:");
		$display("Left_i: %b, Right_i: %b, Shoot_i: %b, Hit_i: %b,Add_life_i: %b, Reset_i: %b",
			left_i,right_i,shoot_i,hit_i,add_life_i,reset_l);
      end

   end


   always @(negedge clk_i) begin
      // $display("At Negedge %d: data_i = %b, counter_o = %b, reset_i = %b ", itervar, data_i, counter_o, reset_i);
      if(next_l == 0 & itervar > 1) begin
      	$display("At Negedge %d: Player state machine data is as follows:",itervar);
		$display("Present States: %b, Next States: %b",pres_l,next_l);
		$display("Inputs:");
		$display("Left_i: %b, Right_i: %b, Shoot_i: %b, Hit_i: %b,Add_life_i: %b, Reset_i: %b",
			left_i,right_i,shoot_i,hit_i,add_life_i,reset_l);
		errors++;
	    $display("\033[0;31mError!\033[0m:State machine will lose its state!");
		if(errors > 1) begin
        $finish();
		end
      end else if ($countones(next_l) != 1 & itervar > 1) begin
      	$display("At Negedge %d: Player state machine data is as follows:",itervar);
		$display("Present States: %b, Next States: %b",pres_l,next_l);
		$display("Inputs:");
		$display("Left_i: %b, Right_i: %b, Shoot_i: %b, Hit_i: %b,Add_life_i: %b, Reset_i: %b",
			left_i,right_i,shoot_i,hit_i,add_life_i,reset_l);
		errors++;
	    $display("\033[0;31mError!\033[0m: State Machine will be in multiple states!");
		if(errors > 1) begin
      //  $finish();
		end
      end
	  if (itervar == 62) begin
      	  $finish();
	  end
   end


   final begin
      $display("Simulation time is %t", $time);
      if(|errors) begin
	 $display("\033[0;31m    ______                    \033[0m");
	 $display("\033[0;31m   / ____/_____________  _____\033[0m");
	 $display("\033[0;31m  / __/ / ___/ ___/ __ \\/ ___/\033[0m");
	 $display("\033[0;31m / /___/ /  / /  / /_/ / /    \033[0m");
	 $display("\033[0;31m/_____/_/  /_/   \\____/_/     \033[0m");
	 $display();
	 $display("Simulation Failed");

     end else begin
	 $display("\033[0;32m    ____  ___   __________\033[0m");
	 $display("\033[0;32m   / __ \\/   | / ___/ ___/\033[0m");
	 $display("\033[0;32m  / /_/ / /| | \\__ \\\__ \ \033[0m");
	 $display("\033[0;32m / ____/ ___ |___/ /__/ / \033[0m");
	 $display("\033[0;32m/_/   /_/  |_/____/____/  \033[0m");
	 $display();
	 $display("Simulation Succeeded!");
      end
   end

endmodule


