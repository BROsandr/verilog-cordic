`include "constants.vh"

module CordicIterational(
						input clk,
						input reset,
						input int theta,
						output int s,
						output int c,
						input int n0
						);
	int k, d, tx, ty, tz;
	int x, y, z;
	int n;
	
	always@(clk)
	begin
		if(reset)
		begin
			k = 0;
			d = 0;
			tx = 0;
			ty = 0;
			tz = 0;
			x = 0;
			y = 0;
			z = 0;
			n = 0;
		end
	end
	
	always@(clk)
	begin
		if(!reset)
		begin
			x = `cordic_1K;
			y = 0;
			z = theta;
			n = (n0>`CORDIC_NTAB) ? `CORDIC_NTAB : n0;
			for (k=0; k<n; ++k)
			begin
				d = z>>>31;
				//get sign. for other architectures, you might want to use the more portable version
				//d = z>=0 ? 0 : -1;
				tx = x - (((y>>>k) ^ d) - d);
				ty = y + (((x>>>k) ^ d) - d);
				tz = z - ((cordic_ctab[k] ^ d) - d);
				x = tx; y = ty; z = tz;
			end
			c = x; s = y;
		 end
	end
endmodule