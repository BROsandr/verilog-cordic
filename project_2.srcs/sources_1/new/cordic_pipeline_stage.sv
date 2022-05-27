`include "constants.vh"

module CordicPipelineStage(
					input clk,
					input reset,
					input en,
					input int z_i,
					output int z_o,
					input int x_i,
					output int x_o,
					input int y_i,
					output int y_o,
					input int k
					);
	
	int d, tx, ty, tz;
	
	always@(posedge clk)
		if(reset)
		begin
			d = 0;
			tx = 0;
			ty = 0;
			tz = 0;
		end
	
	always@(posedge clk)
	begin	
		if(!reset && en)
		begin
			d = z_i>>>31;
			//get sign. for other architectures, you might want to use the more portable version
			//d = z>=0 ? 0 : -1;
			tx = x_i - (((y_i>>>k) ^ d) - d);
			ty = y_i + (((x_i>>>k) ^ d) - d);
			tz = z_i - ((cordic_ctab[k] ^ d) - d);
			x_o <= tx; y_o <= ty; z_o <= tz;
		end 
    end
endmodule