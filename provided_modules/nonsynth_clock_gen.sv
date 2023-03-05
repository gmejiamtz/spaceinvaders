module nonsynth_clock_gen
  #(parameter cycle_time_p = 10)
   (output bit clk_o);

   initial begin
      $display("%m with cycle_time_p ",cycle_time_p);
      assert(cycle_time_p >= 2)
	else $error("cannot simulate cycle time less than 2");
   end
   
   always #(cycle_time_p/2.0) begin
      /* verilator lint_off BLKSEQ */
      clk_o = ~clk_o;
      /* verilator lint_off BLKSEQ */
   end

endmodule

