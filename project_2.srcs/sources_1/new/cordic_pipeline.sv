`include "constants.vh"

module CordicPipeline(
						input clk,
						input reset,
						input en,
						input int theta,
						output wire signed [31:0] s,
						output wire signed [31:0] c,
						input int n0);
	int x[0:32], y[0:32], z[0:32];
	
	CordicPipelineStage stage(.clk(clk), .reset(reset), .en(en), .z_i(theta), .x_i(`cordic_1K), .y_i(0), .k(0), .z_o(z[1]), .x_o(x[1]), .y_o(y[1]));
  		
  	always @(posedge clk)
  		if(reset)
  		begin
  			for(int i = 0; i < 33; ++i)
  			begin
  				x[i] = 0;
  				y[i] = 0;
  				z[i] = 0;
  			end
  		end
  		
	genvar k;
	generate
		for (k=1; k<32; ++k)
		begin
			CordicPipelineStage stage(.reset(reset), .en(en), .clk(clk), .z_i(z[k]), .x_i(x[k]), .y_i(y[k]), .k(k), .z_o(z[k + 1]), .x_o(x[k + 1]), .y_o(y[k + 1]));
		end 
	endgenerate
		
	
	assign c = x[32];
	assign s = y[32];
endmodule