`timescale 1ns/1ns
`define clk_period 20

module pwn_tb;

	reg clk;
	reg rst_n;
	reg cnt_en;
	reg [31:0]counter_arr;
	reg [31:0]counter_ccr;
	
	wire o_pwn;
	
	pwn pwn0(
		.clk(clk),
		.rst_n(rst_n),
		.cnt_en(cnt_en),
		.counter_arr(counter_arr),
		.counter_ccr(counter_ccr),
		.o_pwn(o_pwn)
	);
	
	initial clk = 1;
	always#(`clk_period/2)clk = ~clk;
	
	initial begin
		rst_n = 0;
		cnt_en = 0;
		counter_arr = 0;
		counter_ccr = 0;
		#(`clk_period*20+1);
		rst_n = 1;
		#(`clk_period*10);
		counter_arr = 999;
		counter_ccr = 400;
		#(`clk_period*10);
		cnt_en = 1;
		#100050;
		
		counter_ccr = 700;
		#100050;
		cnt_en = 0;
		counter_arr = 499;
		counter_ccr = 255;
		#(`clk_period*10);
		cnt_en = 1;
		#50050;
		
		counter_ccr = 100;
		#50050;
	end 



endmodule 