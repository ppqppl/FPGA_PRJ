module pwn(
	input 			clk			,
	input 			rst_n		,
	input 			cnt_en		,
	input 	[31:0]	counter_arr	,
	input 	[31:0]	counter_ccr	,
	output 	reg 	o_pwn
);

	// input clk;
	// input rst_n;
	// input cnt_en;
	// input [31:0]counter_arr;
	// input [31:0]counter_ccr;
	
	// output reg o_pwn;
	
	reg [31:0]counter;
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		counter <= 32'd0;
	else if(cnt_en)
		begin
			if(counter == 0)
				counter <= counter_arr;
			else 
				counter <= counter - 1'b1;
		end 
	else 
		counter <= counter_arr;
		
	always@(posedge clk or negedge rst_n)
	if(!rst_n)	
		o_pwn <= 1'b0;
	else if(counter >= counter_ccr)
		o_pwn <= 1'b0;
	else 
		o_pwn <= 1'b1;
endmodule 