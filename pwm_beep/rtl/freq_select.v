module freq_select
(
	input  wire 	clk  ,//时钟信号
	input  wire 	rst_n,//复位信号
	
	output reg		flag//pwm标志     
	
);
parameter   CNT_MAX = 24'd14_999_999;//300ms
parameter   NUM_FRE = 6'd48			;//34个音符
parameter   DO_0    = 16'd52000     ;//0
parameter   DO  	= 16'd47750		;//1
parameter   RE  	= 16'd42550		;//2
parameter   MI  	= 16'd37900		;//3
parameter   FA  	= 16'd37550		;//4
parameter   SO  	= 16'd31850		;//5
parameter   LA      = 16'd28400		;//6
parameter   XI      = 16'd25400		;//7
reg  [23:0]  cnt_delay   ;//300ms计数器
reg  [5:0]	 lut_data    ;//乐谱数据寄存器
reg  [15:0]	 cnt_freq    ;//音符音频计数器
reg  [15:0]	 freq_data   ;//音符数据寄存器
wire [14:0]  duty_data   ;//占空比数据
wire 		 end_note    ;//音符结束标志
wire 		 end_spectrum;//音谱结束标志
//单个音符持续时间计时模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_delay <= 24'd0;
	end 
	else if(cnt_delay == CNT_MAX)begin
		cnt_delay <= 24'd0;
	end 
	else begin
		cnt_delay <= cnt_delay + 1'd1;
	end 
end 

//音符计时模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_freq <= 16'd0;
	end 
	else if(end_note)begin
		cnt_freq <= 16'd0;
	end 
	else begin
		cnt_freq <= cnt_freq + 1'd1;
	end 
end 

//音谱计时模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		lut_data <= 6'd0;
	end 
	else if(end_spectrum)begin
		lut_data <= 6'd0;
	end 
	else if(cnt_delay == CNT_MAX)begin
		lut_data <= lut_data + 1'd1;
	end 
	else begin
		lut_data <= lut_data;
	end 
end 

//音符查找表模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		freq_data <= DO;
	end 
	else begin
		case(lut_data)
            6'd0:	freq_data <= DO_0;    //0
			6'd1:	freq_data <= SO;    //5
			6'd2:	freq_data <= SO;	//5					
			6'd3:	freq_data <= MI;	//3				
			6'd4:	freq_data <= RE;	//2		
			6'd5:	freq_data <= MI;	//3				
			6'd6:	freq_data <= LA;    //6			
			6'd7:	freq_data <= RE;	//2				
			6'd8:	freq_data <= MI;	//3				
			6'd9:	freq_data <= SO;	//5				
			6'd10:	freq_data <= MI;    //3
			6'd11:	freq_data <= RE;    //2
			6'd12:	freq_data <= DO_0;    //0    
			6'd13:	freq_data <= SO;    //5
			6'd14:	freq_data <= SO;    //5
			6'd15:	freq_data <= MI;    //3
			6'd16:	freq_data <= RE;    //2
			6'd17:	freq_data <= MI;    //3
			6'd18:	freq_data <= SO;    //5
			6'd19:	freq_data <= RE;    //2
			6'd20:	freq_data <= MI;    //3
			6'd21:	freq_data <= SO;    //5
			6'd22:	freq_data <= RE;    //2
			6'd23:	freq_data <= DO;    //1
			6'd24:	freq_data <= DO_0;    //0
			6'd25:	freq_data <= DO;    //1
			6'd26:	freq_data <= RE;    //2
			6'd27:	freq_data <= MI;    //3
			6'd28:	freq_data <= SO;    //5
			6'd29:	freq_data <= LA;    //6
			6'd30:	freq_data <= SO;    //5
			6'd31:	freq_data <= MI;    //3
			6'd32:	freq_data <= SO;    //5
			6'd33:	freq_data <= MI;    //3
			6'd34:	freq_data <= MI;    //3
			6'd35:	freq_data <= RE;    //2
			6'd36:	freq_data <= RE;    //2
			6'd37:	freq_data <= DO_0;    //0
			6'd38:	freq_data <= DO;    //1
			6'd39:	freq_data <= RE;    //2
			6'd40:	freq_data <= DO;    //1
			6'd41:	freq_data <= RE;    //2
			6'd42:	freq_data <= DO;    //1
			6'd43:	freq_data <= RE;    //2
			6'd44:	freq_data <= RE;    //2
			6'd45:	freq_data <= MI;    //3
			6'd46:	freq_data <= SO;    //5
			6'd47:	freq_data <= MI;    //3
			6'd48:	freq_data <= MI;    //3
			default:freq_data <= DO;    //
		endcase  
	end         
end  

assign duty_data = freq_data >> 1;//占空比50%

assign end_note = cnt_freq == freq_data;
assign end_spectrum = lut_data == NUM_FRE && cnt_delay == CNT_MAX;
//pwm信号产生模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		flag <= 1'b0;
	end 
	else begin
		flag <= (cnt_freq >= duty_data) ? 1'b1 : 1'b0; 
	end 	 
end         
endmodule                


// module freq_select
// (
// 	input  wire 	clk  ,//时钟信号
// 	input  wire 	rst_n,//复位信号
	
// 	output reg		flag//pwm标志     
	
// );
// parameter   CNT_MAX = 24'd14_999_999;//300ms
// parameter   NUM_FRE = 6'd33			;//34个音符
// parameter   DO  	= 16'd47750		;//1
// parameter   RE  	= 16'd42250		;//2
// parameter   MI  	= 16'd37900		;//3
// parameter   FA  	= 16'd37550		;//4
// parameter   SO  	= 16'd31850		;//5
// parameter   LA      = 16'd28400		;//6
// parameter   XI      = 16'd25400		;//7
// reg  [23:0]  cnt_delay   ;//300ms计数器
// reg  [5:0]	 lut_data    ;//乐谱数据寄存器
// reg  [15:0]	 cnt_freq    ;//音符音频计数器
// reg  [15:0]	 freq_data   ;//音符数据寄存器
// wire [14:0]  duty_data   ;//占空比数据
// wire 		 end_note    ;//音符结束标志
// wire 		 end_spectrum;//音谱结束标志
// //单个音符持续时间计时模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		cnt_delay <= 24'd0;
// 	end 
// 	else if(cnt_delay == CNT_MAX)begin
// 		cnt_delay <= 24'd0;
// 	end 
// 	else begin
// 		cnt_delay <= cnt_delay + 1'd1;
// 	end 
// end 

// //音符计时模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		cnt_freq <= 16'd0;
// 	end 
// 	else if(end_note)begin
// 		cnt_freq <= 16'd0;
// 	end 
// 	else begin
// 		cnt_freq <= cnt_freq + 1'd1;
// 	end 
// end 

// //音谱计时模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		lut_data <= 6'd0;
// 	end 
// 	else if(end_spectrum)begin
// 		lut_data <= 6'd0;
// 	end 
// 	else if(cnt_delay == CNT_MAX)begin
// 		lut_data <= lut_data + 1'd1;
// 	end 
// 	else begin
// 		lut_data <= lut_data;
// 	end 
// end 

// //音符查找表模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		freq_data <= DO;
// 	end 
// 	else begin
// 		case(lut_data)
// 			6'd0:	freq_data <= DO;
// 			6'd1:	freq_data <= RE;
// 			6'd2:	freq_data <= MI;						
// 			6'd3:	freq_data <= DO;					
// 			6'd4:	freq_data <= DO;					
// 			6'd5:	freq_data <= RE;					
// 			6'd6:	freq_data <= MI;					
// 			6'd7:	freq_data <= DO;					
// 			6'd8:	freq_data <= MI;					
// 			6'd9:	freq_data <= FA;					
// 			6'd10:	freq_data <= SO;
// 			6'd11:	freq_data <= MI;
// 			6'd12:	freq_data <= FA;
// 			6'd13:	freq_data <= SO;
// 			6'd14:	freq_data <= SO;
// 			6'd15:	freq_data <= LA;
// 			6'd16:	freq_data <= SO;
// 			6'd17:	freq_data <= FA;
// 			6'd18:	freq_data <= MI;
// 			6'd19:	freq_data <= DO;
// 			6'd20:	freq_data <= SO;
// 			6'd21:	freq_data <= LA;
// 			6'd22:	freq_data <= SO;
// 			6'd23:	freq_data <= FA;
// 			6'd24:	freq_data <= MI;
// 			6'd25:	freq_data <= DO;
// 			6'd26:	freq_data <= RE;
// 			6'd27:	freq_data <= SO;
// 			6'd28:	freq_data <= DO;
// 			6'd29:	freq_data <= DO;
// 			6'd30:	freq_data <= RE;
// 			6'd31:	freq_data <= SO;
// 			6'd32:	freq_data <= DO;
// 			6'd33:	freq_data <= DO;
// 			default:freq_data <= DO;
// 		endcase  
// 	end         
// end  

// assign duty_data = freq_data >> 1;//占空比50%

// assign end_note = cnt_freq == freq_data;
// assign end_spectrum = lut_data == NUM_FRE && cnt_delay == CNT_MAX;
// //pwm信号产生模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		flag <= 1'b0;
// 	end 
// 	else begin
// 		flag <= (cnt_freq >= duty_data) ? 1'b1 : 1'b0; 
// 	end 	 
// end         
// endmodule                


// module freq_select
// (
// 	input  wire 	clk  ,//时钟信号
// 	input  wire 	rst_n,//复位信号
	
// 	output reg		flag//pwm标志     
	
// );
// parameter   CNT_MAX = 23'd4_999_999;//300ms
// parameter   NUM_FRE = 6'd54			;//34个音符
// parameter   DO_0    = 16'd52000     ;//0
// parameter   DO  	= 16'd47750		;//1
// parameter   RE  	= 16'd42550		;//2
// parameter   MI  	= 16'd37900		;//3
// parameter   FA  	= 16'd37550		;//4
// parameter   SO  	= 16'd31850		;//5
// parameter   LA      = 16'd28400		;//6
// parameter   XI      = 16'd25400		;//7
// reg  [23:0]  cnt_delay   ;//300ms计数器
// reg  [5:0]	 lut_data    ;//乐谱数据寄存器
// reg  [15:0]	 cnt_freq    ;//音符音频计数器
// reg  [15:0]	 freq_data   ;//音符数据寄存器
// wire [14:0]  duty_data   ;//占空比数据
// wire 		 end_note    ;//音符结束标志
// wire 		 end_spectrum;//音谱结束标志
// //单个音符持续时间计时模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		cnt_delay <= 23'd0;
// 	end 
// 	else if(cnt_delay == CNT_MAX)begin
// 		cnt_delay <= 23'd0;
// 	end 
// 	else begin
// 		cnt_delay <= cnt_delay + 1'd1;
// 	end 
// end 

// //音符计时模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		cnt_freq <= 16'd0;
// 	end 
// 	else if(end_note)begin
// 		cnt_freq <= 16'd0;
// 	end 
// 	else begin
// 		cnt_freq <= cnt_freq + 1'd1;
// 	end 
// end 

// //音谱计时模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		lut_data <= 6'd0;
// 	end 
// 	else if(end_spectrum)begin
// 		lut_data <= 6'd0;
// 	end 
// 	else if(cnt_delay == CNT_MAX)begin
// 		lut_data <= lut_data + 1'd1;
// 	end 
// 	else begin
// 		lut_data <= lut_data;
// 	end 
// end 

// //音符查找表模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		freq_data <= DO;
// 	end 
// 	else begin
// 		case(lut_data)
//             6'd0:	freq_data <= 0 ;    
// 			6'd1:	freq_data <= LA;    
// 			6'd2:	freq_data <= LA;						
// 			6'd3:	freq_data <= MI;					
// 			6'd4:	freq_data <= MI;			
// 			6'd5:	freq_data <= LA;					
// 			6'd6:	freq_data <= 0 ;    			
// 			6'd7:	freq_data <= 0 ;					
// 			6'd8:	freq_data <= 0 ;					
// 			6'd9:	freq_data <= LA;					
// 			6'd10:	freq_data <= LA;    
// 			6'd11:	freq_data <= LA;    
// 			6'd12:	freq_data <= 0 ;      
// 			6'd13:	freq_data <= 0 ;    
// 			6'd14:	freq_data <= 0 ;    
// 			6'd15:	freq_data <= LA;    
// 			6'd16:	freq_data <= LA;    
// 			6'd17:	freq_data <= MI;    
// 			6'd18:	freq_data <= MI;    
// 			6'd19:	freq_data <= LA;    
// 			6'd20:	freq_data <= 0 ;    
// 			6'd21:	freq_data <= 0 ;    
// 			6'd22:	freq_data <= 0 ;    
// 			6'd23:	freq_data <= LA;    
// 			6'd24:	freq_data <= LA;  
// 			6'd25:	freq_data <= LA;    
// 			6'd26:	freq_data <= 0 ;    
// 			6'd27:	freq_data <= 0 ;    
// 			6'd28:	freq_data <= LA;    
// 			6'd29:	freq_data <= LA;    
// 			6'd30:	freq_data <= LA;    
// 			6'd31:	freq_data <= LA;    
// 			6'd32:	freq_data <= LA;    
// 			6'd33:	freq_data <= MI;    
// 			6'd34:	freq_data <= MI;    
// 			6'd35:	freq_data <= LA;    
// 			6'd36:	freq_data <= 0 ;    
// 			6'd37:	freq_data <= 0 ;  
// 			6'd38:	freq_data <= 0 ;    
// 			6'd39:	freq_data <= LA;    
// 			6'd40:	freq_data <= LA;    
// 			6'd41:	freq_data <= LA;    
// 			6'd42:	freq_data <= 0 ;    
// 			6'd43:	freq_data <= 0 ;    
// 			6'd44:	freq_data <= 0 ;    
// 			6'd45:	freq_data <= LA;    
// 			6'd46:	freq_data <= LA;    
// 			6'd47:	freq_data <= MI;    
// 			6'd48:	freq_data <= MI;    
// 			6'd49:	freq_data <= LA;    
// 			6'd50:	freq_data <= 0 ;    
// 			6'd51:	freq_data <= 0 ;    
// 			6'd52:	freq_data <= 0 ;    
// 			6'd53:	freq_data <= LA;    
// 			6'd54:	freq_data <= LA;    
// 			default:freq_data <= 0;    
// 		endcase  
// 	end         
// end  

// assign duty_data = freq_data >> 1;//占空比50%

// assign end_note = cnt_freq == freq_data;
// assign end_spectrum = lut_data == NUM_FRE && cnt_delay == CNT_MAX;
// //pwm信号产生模块
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		flag <= 1'b0;
// 	end 
// 	else begin
// 		flag <= (cnt_freq >= duty_data) ? 1'b1 : 1'b0; 
// 	end 	 
// end         
// endmodule      