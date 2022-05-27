`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2022 05:16:17 PM
// Design Name: 
// Module Name: cordic-test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define cordic_1K 'h26DD3B6A
`define half_pi 'h6487ED51
`define MUL 1073741824.000000
`define CORDIC_NTAB 32

function cordic(
	input int theta,
	output int s,
	output int c,
	input int n0);
begin

  localparam signed [31:0] cordic_ctab [0:31] = {'h3243F6A8, 'h1DAC6705, 'h0FADBAFC, 'h07F56EA6, 'h03FEAB76, 'h01FFD55B, 'h00FFFAAA, 
'h007FFF55, 'h003FFFEA, 'h001FFFFD, 'h000FFFFF, 'h0007FFFF, 'h0003FFFF, 'h0001FFFF, 'h0000FFFF, 'h00007FFF, 'h00003FFF, 
'h00001FFF, 'h00000FFF, 'h000007FF, 'h000003FF, 'h000001FF, 'h000000FF, 'h0000007F, 'h0000003F, 'h0000001F, 'h0000000F, 
'h00000008, 'h00000004, 'h00000002, 'h00000001, 'h00000000};
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


module cordic_test(

    );
    int s, c;
    initial
    begin
    	real p;
		int s,c;
		int i;    
		for(i=0;i<50;i++)
		begin
			p = (i/50.0)*3.1415926535897932384626433 / 2;        
			//use 32 iterations
			cordic((p*`MUL), s, c, 32);
			//these values should be nearly equal
			$display("%.32f : %.32f\n", s / `MUL, $sin(p));
		end    

    end
    
endmodule
