module gen_pwm
(
	input  wire 	clk  ,//时钟
	input  wire 	rst_n,//复位信号
	input  wire 	flag ,//pwm标志信号
	
	output reg 		beep//蜂鸣器信号
);

//pwm控制蜂鸣器模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		beep <= 1'b1;
	end 
	else if(flag)begin
		beep <= 1'b0;
	end 	
	else begin
		beep <= 1'b1;
	end 
end 
endmodule 
