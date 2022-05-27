`timescale 1ns / 1ps

`define cordic_1K 'h26DD3B6A
`define half_pi 'h6487ED51
`define MUL 1073741824.000000
`define CORDIC_NTAB 32

  localparam signed [31:0] cordic_ctab [0:31] = {'h3243F6A8, 'h1DAC6705, 'h0FADBAFC, 'h07F56EA6, 'h03FEAB76, 'h01FFD55B, 'h00FFFAAA, 
'h007FFF55, 'h003FFFEA, 'h001FFFFD, 'h000FFFFF, 'h0007FFFF, 'h0003FFFF, 'h0001FFFF, 'h0000FFFF, 'h00007FFF, 'h00003FFF, 
'h00001FFF, 'h00000FFF, 'h000007FF, 'h000003FF, 'h000001FF, 'h000000FF, 'h0000007F, 'h0000003F, 'h0000001F, 'h0000000F, 
'h00000008, 'h00000004, 'h00000002, 'h00000001, 'h00000000};

function cordic(
	input int theta,
	output int s,
	output int c,
	input int n0);
begin
	int k, d, tx, ty, tz;
	  int x, y, z;
	  int n;
      x = `cordic_1K;y=0;z=theta;
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
endfunction

reg clk = 0;

module cordic_stage(
	input clk,
	input int z_i,
	output int z_o,
	input int x_i,
	output int x_o,
	input int y_i,
	output int y_o,
	input int k
	);
	
	int d, tx, ty, tz;
	always@(clk)
	begin	
		d = z_i>>>31;
		//get sign. for other architectures, you might want to use the more portable version
		//d = z>=0 ? 0 : -1;
		tx = x_i - (((y_i>>>k) ^ d) - d);
		ty = y_i + (((x_i>>>k) ^ d) - d);
		tz = z_i - ((cordic_ctab[k] ^ d) - d);
		x_o = tx; y_o = ty; z_o = tz;
    end
endmodule

module cordic_pipeline(
	input int theta,
	output wire signed [31:0] s,
	output wire signed [31:0] c,
	input int n0);
	  int x[0:32], y[0:32], z[0:32];
  		
  		cordic_stage stage(.clk(clk), .z_i(theta), .x_i(`cordic_1K), .y_i(0), .k(0), .z_o(z[1]), .x_o(x[1]), .y_o(y[1]));
  		
 genvar k;
 generate
   for (k=1; k<32; ++k)
	  begin
		cordic_stage stage(.clk(clk), .z_i(z[k]), .x_i(x[k]), .y_i(y[k]), .k(k), .z_o(z[k + 1]), .x_o(x[k + 1]), .y_o(y[k + 1]));
	  end
 endgenerate
  		

 assign c = x[32];assign s = y[32];
endmodule

module cordic_test(

    );
    always #10 clk = !clk;
    real p = (10/50.0)*3.1415926535897932384626433 / 2;
    real p0 = p * `MUL;
    
    int s, c;
    cordic_pipeline pipe(p0, s, c, 32);
    initial
    begin    
			//use 32 iterations
			//these values should be nearly equal
			repeat(100)
			@(clk);
			$display("%.32f : %.32f\n", s / `MUL, $sin(p));    

    end
    
endmodule
