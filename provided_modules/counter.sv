module counter
  #(parameter width_p = 4
   ,parameter [width_p -1:0] reset_val_p = 0)
   (input [0:0] clk_i
   ,input [0:0] reset_i
   ,input [0:0] up_i
   ,input [0:0] down_i
   ,output [width_p-1:0] counter_o);

   // Implement a parameterized up/down counter. You must use behavioral verilog
   //
   // counter_o must reset to '0 at the positive edge of clk_i when reset_i is 1
   //
   // counter_o must have the following behavior at the positive edge of clk_i when reset_i is 0:
   // 
   // * Maintain the same value when up_i and down_i are both 1 or both 0.
   // 
   // * Increment by 1 when up_i is 1 and down_i is 0
   //
   // * Decrement by 1 when down_i is 1 and up_i is 0 
   //
   // * Use two's complement: -1 == '1 (Remember: decrementing by 1 is the same as adding negative 1)
   //
   // If the counter value overflows, return to 0. If the counter value underflows, return to the maximum value.
   //
   // (In other words you don't need to handle over/underflow conditions).
   // 
   // Your code here:
	logic [width_p-1:0] q_r; //always ff output
	wire [width_p-1:0] up_bus,down_bus; //up and down 
	wire [0:0] toggle_sel,sub_sel; //up^down and down & toggle_sel
	wire [width_p-1:0] new_in_bus,dff_in_bus; //feed into d flip flops
	assign up_bus = counter_o + 1'b1;
	assign down_bus = counter_o - 1'b1;
	assign new_in_bus = down_bus[width_p-1:0] & {width_p{sub_sel}}
		| up_bus[width_p-1:0] & ~{width_p{sub_sel}};
	assign toggle_sel = up_i ^ down_i;
	assign sub_sel = down_i & toggle_sel;
	assign dff_in_bus = counter_o & ~{width_p{toggle_sel}}
		| new_in_bus & {width_p{toggle_sel}};
	always_ff @(posedge clk_i) begin
		if(reset_i) begin //if reseting
			q_r <= reset_val_p;
		end else begin //else shift reg
			q_r <= dff_in_bus;
		end
	end
	assign counter_o = q_r;
	
endmodule


