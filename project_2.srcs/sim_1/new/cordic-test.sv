`timescale 1ns / 1ps

module CordicTest();
    reg clk = 0;
    reg reset = 0;
    reg en = 0;
    always #10 clk = !clk;
    
    real p;
    real p0;
    
    int s, c;
    CordicPipeline pipe(.clk(clk), .en(en), .reset(reset), .theta(p0), .s(s), .c(c), .n0(32));
    event printResults;
    initial
    begin    
    
    	@(posedge clk) reset = 1;
    	@(posedge clk) reset = 0;
    	@(posedge clk) en = 1;
		p = (23/50.0)*`PI / 2;
		p0 = p * `MUL;
		->printResults;
		//use 32 iterations
		//these values should be nearly equal


    end
    
    initial
    begin
    	@(printResults);
		repeat(32) @(posedge clk);
		$display("%.32f : %.32f\n", s / `MUL, $sin(p));    
    end
    
endmodule
