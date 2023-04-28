module KLED(
	input 				clk  ,//时钟50MHz
	input 				rst_n,//复位信号，下降沿有效negtive
	input 	[3:0]		key  ,//四个按键
	
	output 	reg [3:0]	led   //四个led灯
	
);

parameter TIME = 24'd10_000_000;//0.2S
reg [23:0]	cnt ;//计数器0.2S
reg [1:0]	state;//记录四个led状态

//0.2s计数器模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin//复位
		cnt <= 24'd0;//计数器清0
	end 
	else if(cnt == TIME - 1)begin//记满10_000_000,0~9_999_999
		cnt <= 24'd0;//计数器清0
	end 
	else begin
		cnt <= cnt + 1'd1;//其他情况下计数器加1
	end 
end 

//状态计数模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin//复位信号
		state <= 2'd0;//状态清0
	end 
	else if(cnt == TIME - 1)begin//记满10_000_000,0~9_999_999 0.2s
		state <= state + 2'd1;//状态加1
	end 
	else begin
	state <= state;//其他情况状态保持不变
	end 
end 

//状态控制led模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin//复位信号
		led <= 4'b0000;//led全灭
	end 
	else if(key[0] == 0)begin//右边第1个按键按下，按键低电平0有效
		case(state)//判断状态的值
			2'd0: ;//右边第1个led灯亮
			default:led[0] <= ~led[0];//默认情况不能忘，可以不写，但是要把stat情况考虑完
		endcase 
	end 
	else if(key[1] == 0)begin//右边第2个按键按下，按键低电平0有效
		case(state)//判断状态的值
			// 2'd0:;//左边第1个led灯亮
		    default: led[1] <= ~led[1];
		endcase 
	end 
	else if(key[2] == 0)begin//右边第3个按键按下，按键低电平0有效
		case(state)
			// 2'd0: ;//全亮
		    default: led[2] <= ~led[2];
		endcase 
	end
	else if(key[3] == 0)begin//右边第4个按键按下，按键低电平0有效
		case(state)
			// 2'd0: ;//全亮
		    default: led[3] <= ~led[3];
		endcase 
	end
	else begin
		led <= led;//其他情况默认保持现状
	end 
end 
endmodule 
