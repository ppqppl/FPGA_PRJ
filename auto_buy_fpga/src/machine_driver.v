module machine_drive(
	input    wire			   clk			,        //时钟信号
	input    wire			   rst_n		   ,			//复位信号
	input    wire	[2:0] 	key			,        //3个按键 KEY4-key[2]:1元 KEY3-key[1]:0.5元 KEY2-key[0]：更换商品价格
	
	output	reg 	[3:0] 	led_value	,			//对应led显示效果的类型
	output 	reg 	[6:0] 	price_put	,			//用户投入的钱
	output 	reg 	[6:0] 	price_need	,			//商品价格
	output 	reg 	[6:0] 	price_out				//找零
);
 
 
 
//四种商品对应价格
parameter	P1 = 7'd5 ;
parameter	P2 = 7'd15;
parameter	P3 = 7'd24;
parameter	P4 = 7'd30;
 
parameter MAX_TIME = 28'd100_000_000;	//退款过程持续时间
reg 	[1 :0] 	price_tmp			   ;	//当前商品价格
reg 	[27:0] 	cnt_time 			   ;   //用作退款过程计时
reg 				flag_can_operation   ;	//可以继续投币和切换商品
reg 				flag_is_retreat_end  ;	//结算完毕
		 
		 
wire				flag_is_retreat      ;	//开始结算
wire				flag_price_is_enough ;	//可以买下商品
reg	[6:0] 	price_put_last       ;	//结算前的投币数
	
//结算倒计时模块
always @(posedge clk,negedge rst_n) begin
	if(!rst_n)begin
		cnt_time <= 28'd0;          //初始设置计数器为0
		flag_can_operation <= 1'b1 ;//设置KEY键可操作
		flag_is_retreat_end <= 1'b0;//设置结算完毕标志为0
	end
	else begin
		if (flag_is_retreat) begin     //开始结算
			cnt_time <= MAX_TIME;       //计数器设置最大值
			flag_can_operation <= 1'b0 ;//当前处于结算状态，设置KEY键不可用
			flag_is_retreat_end <= 1'b0;//设置结算未完毕
		end
		else if(cnt_time > 28'd1) begin //计数器数值大于1
			cnt_time <= cnt_time - 28'd1;//倒计时
			flag_can_operation <= 1'b0;  //当前处于结算状态，设置KEY键不可操作
			flag_is_retreat_end <= 1'b0; //设置结算未完毕
		end
 
		else if(cnt_time == 28'd1) begin//计数器倒计时数到1
			cnt_time <= 28'd0;           //计数器清零
			flag_can_operation <= 1'b1;  //结算完毕，设置KEY键可操作
			flag_is_retreat_end <= 1'b1; //设置结算完毕
		end
		else begin
			cnt_time <= cnt_time;
			flag_can_operation <= flag_can_operation;
			flag_is_retreat_end <= 1'b0;
		end
			
	end
	 
end
//按下KEY2-key[0]切换商品价格 
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)begin
		price_tmp<= 2'd0;  //初始设置商品价格为1号商品
	end
	else if(flag_can_operation) begin//当前按键可操作
		// 当没有投币的时候按下 KEY2-key[0] 为切换商品 
		if(key[0] && ! price_put) begin
			price_tmp <= (price_tmp + 2'd1) % 4;//%操作，循环切换
		end
		else begin
			price_tmp <= price_tmp;	//没有按下切换按键，当前商品价格保持
		end
	end
	else begin
		price_tmp <= price_tmp;	
	end 
end
// 切换商品价格
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		price_need<=P1;
	else
		case(price_tmp)
			2'b00 : price_need<=P1;
			2'b01 : price_need<=P2;
			2'b10 : price_need<=P3;
			2'b11 : price_need<=P4;
			default:price_need<=P1;
		endcase 
end
//切换商品价格时led灯光效果
always @(posedge clk,negedge rst_n) begin
	if(!rst_n)
		led_value <= 4'd1;
	//退款的时候判断是 补差价 或者 全额退款
	//补差价为流水灯效果
	//全额退款为闪烁效果	
	else if(flag_is_retreat)begin//开始结算
		led_value <= price_put_last >= price_need ? 4'd6 : 4'd7 ;//当前投币数大于等于商品价格，LED状态为6，否则状态为7
	end
 
	//正常操作状态根据当前选择商品亮起对应商品led
	else if(flag_can_operation)begin
		case(price_tmp)
			2'b00 : led_value <= 4'd2;
			2'b01 : led_value <= 4'd3;
			2'b10 : led_value <= 4'd4;
			2'b11 : led_value <= 4'd5;
			default:led_value <= 4'd2;
		endcase
	end
	
	else 
		led_value <= led_value;
end
//用户通过按键进行投币
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)begin
		price_put_last<=7'd0;//累计投币数初始化为0
	end
	else if(flag_can_operation) begin//当前按键可操作
		//超过100 或者 
		if(price_put_last>=7'd100 || flag_is_retreat) begin//当前投币大于10超过可显示数字或开始结算，投币清零
			price_put_last<=7'd0;
		end
		/*
			按下 key[2] 投币 + 10
			按下 key[1] 投币 + 5
		*/	
		else begin
			if(key[2])//KEY4-key[2]投币1元
				price_put_last<=price_put_last+7'd10;
			else if(key[1])//KEY3-key[1]投币0.5元
				price_put_last<=price_put_last+7'd5;
			else	
				price_put_last<=price_put_last;
		end
	end
	else begin
		price_put<=price_put;
	end
end
 
//投币数码显示保持2s
always @(posedge clk,negedge rst_n) begin
	if(!rst_n)begin
		price_put<=7'd0;
	end
	else if(!flag_can_operation)//按键不可操作
		price_put <= price_put;//输出投币保持
	else 
		price_put <= price_put_last;//否则将当前投币值赋值给输出投币寄存器
end
// 输出找零
always @(posedge clk,negedge rst_n) begin
	if(!rst_n)begin
		price_out <= 7'd0;//初始找零0元
	end
	//结算完毕,归零
	else if(flag_is_retreat_end) begin
	 	price_out =7'd0 ;
	end	
	//当退款标志到来,计算退款金额为 补差价 或者 全额退款
	else if(flag_is_retreat) begin//开始结算
		price_out <= price_put_last >= price_need ? price_put_last - price_need : price_put_last ;//当前投币大于商品价格则找零差值，否则找零为0
	end
	else begin
		price_out <= price_out;
	end
end
//当投币可以买下商品
assign flag_price_is_enough = price_put_last >= price_need;//当前投币数大于等于商品价格，投币足够标志置1
//为了保证在结算前得到最后一次投币数量
// assign price_put_last = price_put;
// 当币足够 或者 在投币过程选择切换商品则开始退款
assign flag_is_retreat = flag_price_is_enough || (price_put && key[0]);//投币足够或退款，结算处理标志置1
endmodule