module  beep
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire	[1:0]	flag		,
	
	output	reg				beep		
);

localparam	DO	=	18'd190839	,
			RE	=	18'd170068	,
			MI	=	18'd151515	,
			FA	=	18'd143266	,
			SO	=	18'd127551	,
			LA	=	18'd113636	,
			XI	=	18'd101215	;
localparam	DO_1_2	=	17'd19084  ,
			RE_1_2	=	17'd17007  ,
			MI_1_2	=	17'd15152  ,
			FA_1_2	=	17'd14327  ,
			SO_1_2  =	17'd12755  ,
			LA_1_2	=	17'd11364  ,
			XI_1_2	=	17'd10122  ;
localparam	CNT_EN_MAX	=	26'd50_000_000  ;
			
reg		[25:0]	cnt_en	;
reg		[2:0]	cnt_num	;
reg		[16:0]	cnt_T	;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_en  <=  26'd0  ;
	else  if(cnt_en == CNT_EN_MAX - 1'b1)
		cnt_en  <=  26'd0  ;
	else  
		cnt_en  <=  cnt_en + 1'b1  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_num  <=  3'd0  ;
	else  if((cnt_en == CNT_EN_MAX - 1'b1)&&(cnt_num == 3'd6))
		cnt_num  <=  3'd0  ;		
	else  if(cnt_en == CNT_EN_MAX - 1'b1)
		cnt_num  <=  cnt_num + 1'b1  ;
	else
		cnt_num  <=  cnt_num  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_T  <=  17'd0  ;
	else  if((cnt_num == 3'd0)&&(cnt_T == DO_1_2 - 1'b1))
		cnt_T  <=  17'd0  ;
	else  if((cnt_num == 3'd1)&&(cnt_T == RE_1_2 - 1'b1))
		cnt_T  <=  17'd0  ;		
	else  if((cnt_num == 3'd2)&&(cnt_T == MI_1_2 - 1'b1))
		cnt_T  <=  17'd0  ;
	else  if((cnt_num == 3'd3)&&(cnt_T == FA_1_2 - 1'b1))
		cnt_T  <=  17'd0  ;	
	else  if((cnt_num == 3'd4)&&(cnt_T == SO_1_2 - 1'b1))
		cnt_T  <=  17'd0  ;		
	else  if((cnt_num == 3'd5)&&(cnt_T == LA_1_2 - 1'b1))
		cnt_T  <=  17'd0  ;
	else  if((cnt_num == 3'd6)&&(cnt_T == XI_1_2 - 1'b1))
		cnt_T  <=  17'd0  ;			
	else  
		cnt_T  <=  cnt_T + 1'b1  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		beep  <=  1'b1  ;
	else  if((flag == 2'b01)||(flag == 2'b00))
		beep  <=  1'b1  ;
	else  if((cnt_num == 3'd0)&&(cnt_T == DO_1_2 - 1'b1))
		beep  <=  ~beep  ;
	else  if((cnt_num == 3'd1)&&(cnt_T == RE_1_2 - 1'b1))
		beep  <=  ~beep  ;		
	else  if((cnt_num == 3'd2)&&(cnt_T == MI_1_2 - 1'b1))
		beep  <=  ~beep  ;
	else  if((cnt_num == 3'd3)&&(cnt_T == FA_1_2 - 1'b1))
		beep  <=  ~beep  ;			
	else  if((cnt_num == 3'd4)&&(cnt_T == SO_1_2 - 1'b1))
		beep  <=  ~beep  ;		
	else  if((cnt_num == 3'd5)&&(cnt_T == LA_1_2 - 1'b1))
		beep  <=  ~beep  ;
	else  if((cnt_num == 3'd6)&&(cnt_T == XI_1_2 - 1'b1))
		beep  <=  ~beep  ;	
	else
		beep  <=  beep  ;

endmodule
		