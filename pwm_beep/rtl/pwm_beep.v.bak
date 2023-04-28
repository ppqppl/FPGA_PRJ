module PWM_Beep(
	input  wire clk  ,
	input  wire rst_n,
	
	output wire beep
);

parameter   CNT_MAX = 24'd14_999_999;//300ms
parameter   DO  	= 16'd47750		;//1
parameter   RE  	= 16'd42250		;//2
parameter   MI  	= 16'd37900		;//3
parameter   FA  	= 16'd37550		;//4
parameter   SO  	= 16'd31850		;//5
parameter   LA      = 16'd28400		;//6
parameter   XI  	= 16'd25400		;//7
wire flag;

//实例化音频选择模块
freq_select#(
.CNT_MAX 	(CNT_MAX),
.DO  	  	(DO)     ,
.RE  	  	(RE)     ,
.MI  	  	(MI)     ,
.FA  	  	(FA)     ,
.SO  	  	(SO)     ,
.LA     	(LA)     ,
.XI  	  	(XI)
) u_freq_select(

.clk		(clk)  ,
.rst_n		(rst_n),
		
.flag		(flag)
);
//实例化pwm产生模块
gen_pwm	u_gen_pwm
(
.clk		(clk)  ,
.rst_n		(rst_n),
.flag		(flag) ,
		
.beep		(beep)
);
endmodule 
