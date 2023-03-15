module ram_1r1w_sync
  #(parameter [31:0] width_p = 8
  ,parameter [31:0] depth_p = 128
  ,parameter  filename_p = "memory_init_file.hex")
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [0:0] wr_valid_i
  ,input [width_p-1:0] wr_data_i
  ,input [$clog2(depth_p) - 1 : 0] wr_addr_i

  ,input [$clog2(depth_p) - 1 : 0] rd_addr_i
  ,output [width_p-1:0] rd_data_o);

  logic [width_p-1:0] mem [depth_p-1:0];
  initial begin
    $readmemh(filename_p, mem);
  end
  
  logic [width_p-1:0] rd_addr_l;
  always_ff @(posedge clk_i) begin : rd_block
    if (reset_i) begin
      rd_addr_l <= '0;
    end else begin
      rd_addr_l <= mem[rd_addr_i];
    end
  end

  always_ff @(posedge clk_i) begin : wr_block
    if (wr_valid_i & ~reset_i) begin
      mem[wr_addr_i] <= wr_data_i;
    end
  end
  assign rd_data_o = rd_addr_l;

endmodule
