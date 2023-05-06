module  i2c_ctrl
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire	[23:0]	cfg_data	,
	input	wire			i2c_start	,
	input	wire	[5:0]	cfg_num		,
	
	output	wire			scl			,							
	output	reg				cfg_start	,
	output	reg				i2c_clk		,
	output	reg		[2:0]	mode		,
	output	reg		[7:0]	po_data		,
	
	inout	wire			sda
);

localparam	CNT_CLK_MAX		=	5'd25	;
localparam	CNT_WAIT_MAX	=	10'd1000;
localparam	CNT_DELAY_MAX	=	10'd1000;
localparam	SLAVE_ID		=	7'h73	;
localparam	SENSOR_ADDR		=	8'hEF	;
localparam	DATA_ADDR		=	8'h43	;
localparam	IDLE		=	4'd0	,
			START		=	4'd1	,
			SLAVE_ADDR	=	4'd2	,
			WAIT		=	4'd3	,
			STOP		=	4'd4	,
			ACK_1		=	4'd5	,
			DEVICE_ADDR	=	4'd6	,
			ACK_2		=	4'd7	,
			DATA		=	4'd8	,
			ACK_3		=	4'd9	,
			NACK		=	4'd10	;

reg		[4:0]	cnt_clk		;	//分频计数器
reg		[9:0]	cnt_wait	;	//开始状态等待1000us计数器
reg				skip_en_0	;	//唤醒状态跳转信号
reg				skip_en_1	;	//激活bank0跳转信号
reg				skip_en_2	;	//配置0x00寄存器状态跳转信号
reg				skip_en_3	;	//读取0x00寄存器状态跳转信号
reg				skip_en_4	;	//配置51个操作寄存器
reg				skip_en_5	;	//配置0x43寄存器状态跳转信号
reg				skip_en_6	;	//读取0x43寄存器状态跳转信号
reg				error_en	;	//读取出来的值不是0x20，错误信号
reg		[3:0]	n_state		;	//次态
reg		[3:0]	c_state		;	//现态	
reg		[1:0]	cnt_i2c_clk	;	//对i2c_clk分频时钟个数计数			
reg		[2:0]	cnt_bit		;	//对传输的8bit数据进行计数	
reg				i2c_scl		;	//就是SCL		
reg				i2c_sda		;	//SDA赋值给i2c_sda
reg		[9:0]	cnt_delay	;	//发送完指令后等待1000us计数器			
reg				i2c_end		;	//i2c结束信号	
reg		[7:0]	po_data_reg	;	//采集数据，拼接完成后赋值给po_data
reg		[7:0]	slave_addr	;	//不同模式下7'h73+1'bx
reg		[7:0]	device_addr	;	//不同模式下寄存器地址变化
reg		[7:0]	wr_data		;	//向地址写入的数据
reg		[7:0]	rec_data	;	//唤醒操作读取0x00寄存器数据寄存
reg				ack			;
wire			sda_in		;
wire			sda_en		;

assign	scl		=	i2c_scl		;
assign	sda_in	=	sda			;	//从设备发送到主机的数据
assign	sda_en	=	((c_state == ACK_1)||(c_state == ACK_2)||(c_state == ACK_3)||((c_state == DATA)&&(mode == 3'd3))||((c_state == DATA)&&(mode == 3'd6))) ? 1'b0 : 1'b1		;	//主机控制sda有效
assign	sda		=	(sda_en == 1'b1) ? i2c_sda : 1'bz  ;

always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cfg_start  <=  1'b0  ;
	else
		cfg_start  <=  i2c_end  ;

always@(*)
	case(mode)
		3'd0	:slave_addr	=	{SLAVE_ID,1'b0}  ;
		3'd1	:begin
					slave_addr  =	{SLAVE_ID,1'b0}  ;
					device_addr	=	SENSOR_ADDR  ;
					wr_data		=	8'h00  ;
				 end
		3'd2	:begin
					slave_addr  =	{SLAVE_ID,1'b0}  ;
					device_addr	=	8'h00  ;		
				 end
		3'd3	:slave_addr  = 	{SLAVE_ID,1'b1}  ;
		3'd4	:begin
					slave_addr	<=  cfg_data[23:16]  ;
					device_addr	<=  cfg_data[15:8]   ;
					wr_data	    <=  cfg_data[7:0]	 ;
				 end
		3'd5	:begin	
					slave_addr  <=  {SLAVE_ID,1'b0}  ;
					device_addr	<=  DATA_ADDR  ;
				 end
		3'd6	:slave_addr  =  {SLAVE_ID,1'b1}  ;
		default	:begin
					slave_addr	<=  8'd0 ;
					device_addr	<=  8'd0 ;
					wr_data	    <=  8'd0 ;		
				 end
    endcase

//
//分频计数器进行计数
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_clk  <=  5'd0  ;
	else  if(cnt_clk == CNT_CLK_MAX - 1'b1)  
		cnt_clk  <=  5'd0  ;
	else
		cnt_clk  <=  cnt_clk + 1'b1  ;
	
//产生i2c驱动时钟	
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		i2c_clk  <=  1'b0  ;
	else  if(cnt_clk == CNT_CLK_MAX - 1'b1)
		i2c_clk  <=  ~i2c_clk  ;
	else
		i2c_clk  <=  i2c_clk  ;
//

//状态机第一段
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		c_state  <=  IDLE  ;
	else
		c_state  <=  n_state  ;
		
//状态机第二段
always@(*)
	case(c_state)
		IDLE		:	if((skip_en_0 == 1'b1)||(skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  =  START  ;
						else
							n_state  =  IDLE  ;
		START		:	if((skip_en_0 == 1'b1)||(skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  =  SLAVE_ADDR  ;
						else
							n_state  =  START  ;
		SLAVE_ADDR	:	if(skip_en_0 == 1'b1)
							n_state  =  WAIT  ;
						else  if((skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  =  ACK_1  ;
						else
							n_state  =  SLAVE_ADDR  ;
		ACK_1		:	if((skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1))
							n_state  =  DEVICE_ADDR  ;
						else  if((skip_en_3 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  =  DATA  ;
						else
							n_state  =  ACK_1  ;
		DEVICE_ADDR	:	if((skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1))
							n_state  =  ACK_2  ;
						else
							n_state  =  DEVICE_ADDR  ;
		ACK_2		:	if((skip_en_1 == 1'b1)||(skip_en_4 == 1'b1))
							n_state  =  DATA  ;
						else  if((skip_en_2 == 1'b1)||(skip_en_5 == 1'b1))
							n_state  =  STOP  ;
						else
							n_state  =  ACK_2  ;
		DATA		:	if((skip_en_1 == 1'b1)||(skip_en_4 == 1'b1))
							n_state  =  ACK_3  ;
						else  if((skip_en_3 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  =  NACK  ;
						else  if(error_en == 1'b1)
							n_state  =  IDLE  ;
						else
							n_state  =  DATA  ;
		ACK_3		:	if((skip_en_1 == 1'b1)||(skip_en_4 == 1'b1))
							n_state  =  STOP  ;
						else
							n_state  =  ACK_3  ;
		WAIT		:	if(skip_en_0 == 1'b1)
							n_state  =  STOP  ;
						else
							n_state  =  WAIT  ;
		NACK		:	if((skip_en_3 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  =  STOP  ;
						else
							n_state  =  NACK  ;
	    STOP		:	if((skip_en_0 == 1'b1)||(skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  =  IDLE  ;
						else
							n_state  =  STOP  ;
		default		:	n_state  =  IDLE  ;
    endcase

//状态机第三段	
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		begin
			cnt_wait	<=  10'd0	;
			skip_en_0	<=  1'b0	;
			skip_en_1	<=  1'b0	;
			skip_en_2   <=  1'b0	;
			skip_en_3   <=  1'b0 	;
			skip_en_4   <=  1'b0	;
			skip_en_5   <=  1'b0	;
			skip_en_6	<=  1'b0	;
			error_en	<=  1'b0	;
			cnt_i2c_clk	<=  2'd0	;
			cnt_bit		<=  3'd0	;
			cnt_delay	<=  10'd0	;
			mode		<=  3'd0	;
			i2c_end		<=  1'b0	;
		end
	else
		case(c_state)
			IDLE		:begin
							cnt_wait  <=  cnt_wait + 1'b1  ;
							if((cnt_wait == CNT_WAIT_MAX - 2'd2)&&(mode == 3'd0))
								skip_en_0  <=  1'b1  ;
							else
								skip_en_0  <=  1'b0  ;
							if((cnt_wait == CNT_WAIT_MAX - 2'd2)&&(mode == 3'd1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;	
							if((cnt_wait == CNT_WAIT_MAX - 2'd2)&&(mode == 3'd2))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((cnt_wait == CNT_WAIT_MAX - 2'd2)&&(mode == 3'd3))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((i2c_start == 1'b1)&&(mode == 3'd4))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((cnt_wait == CNT_WAIT_MAX - 2'd2)&&(mode == 3'd5))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;
							if((cnt_wait == CNT_WAIT_MAX - 2'd2)&&(mode == 3'd6))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;								
						 end
			START		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;			
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd0))
								skip_en_0  <=  1'b1  ;
							else
								skip_en_0  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd2))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd3))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd4))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd5))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd6))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;								
						 end
			SLAVE_ADDR	:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if(cnt_i2c_clk == 2'd3)
								cnt_bit  <=  cnt_bit + 1'b1  ;
							else
								cnt_bit  <=  cnt_bit  ;			
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd0))
								skip_en_0  <=  1'b1  ;
							else
								skip_en_0  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd2))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd3))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd4))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd5))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd6))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;									
						 end
			ACK_1		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd1)&&(ack == 1'b1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd2)&&(ack == 1'b1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd3)&&(ack == 1'b1))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd4)&&(ack == 1'b1))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd5)&&(ack == 1'b1))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd6)&&(ack == 1'b1))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;									
						 end
			DEVICE_ADDR	:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if(cnt_i2c_clk == 2'd3)
								cnt_bit  <=  cnt_bit + 1'b1  ;
							else
								cnt_bit  <=  cnt_bit  ;								
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd2))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd4))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd5))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;								
						 end
			ACK_2		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd1)&&(ack == 1'b1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd2)&&(ack == 1'b1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd4)&&(ack == 1'b1))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd5)&&(ack == 1'b1))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;								
						 end
			DATA		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if(cnt_i2c_clk == 2'd3)
								cnt_bit  <=  cnt_bit + 1'b1  ;
							else
								cnt_bit  <=  cnt_bit  ;				
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd3)&&(rec_data == 8'h20))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd4))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd6))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;								
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd3)&&(rec_data != 8'h20))
								begin
									error_en  <=  1'b1  ;
									mode	  <=  3'd0  ;
								end
							else
								begin
									error_en  <=  1'b0  ;
									mode	  <=  mode  ;
								end							
						 end
			ACK_3		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd1)&&(ack == 1'b1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd4)&&(ack == 1'b1))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;								
						 end						 
			WAIT		:begin
							if((cnt_delay == CNT_DELAY_MAX - 2'd2)&&(mode == 3'd0))
								skip_en_0  <=  1'b1  ;
							else
								skip_en_0  <=  1'b0  ;
							cnt_delay  <=  cnt_delay + 1'b1  ;
						 end
			NACK		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd3)&&(ack == 1'b1))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd6)&&(ack == 1'b1))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;								
						 end
			STOP		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;			
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd0))
								skip_en_0  <=  1'b1  ;
							else
								skip_en_0  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd1))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd2))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd3))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd4))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd5))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd6))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;									
							if(cnt_i2c_clk == 2'd2)
								i2c_end  <=  1'b1  ;
							else
								i2c_end  <=  1'b0  ;						    
							if((i2c_end == 1'b1)&&(mode <= 3'd3))
								mode  <=  mode + 1'b1  ;
							else  if((mode == 3'd4)&&(i2c_end == 1'b1)&&(cfg_num == 6'd51))
								mode  <=  mode + 1'b1  ;
							else  if((i2c_end == 1'b1)&&(mode == 3'd5))
								mode  <=  mode + 1'b1  ;
							else
								mode  <=  mode  ;
						 end
			default		:begin
							cnt_wait  	<=  10'd0   ;
							skip_en_0	<=  1'b0	;
							skip_en_1	<=  1'b0	;
							skip_en_2   <=  1'b0	;
							skip_en_3   <=  1'b0	;
							skip_en_4   <=  1'b0	;
							skip_en_5   <=  1'b0	;
							skip_en_6   <=  1'b0	;
							error_en	<=  1'b0	;
							cnt_i2c_clk	<=  2'd0	;
							cnt_bit		<=  3'd0	;
							cnt_delay	<=  10'd0	;
							mode		<=  mode	;
							i2c_end		<=  1'b0	;
						 end
		endcase
		
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		rec_data  <=  8'd0  ;
	else
		case(c_state)
			DATA	:	if((mode == 3'd3)&&(cnt_i2c_clk == 2'd1))
							rec_data  <=  {rec_data[6:0],sda_in}  ;
						else
							rec_data  <=  rec_data  ;
			default	:	rec_data  <=  8'd0  ;
		endcase
		
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_data_reg  <=  8'd0  ;
	else  
		case(c_state)
			DATA	:	if((mode == 3'd6)&&(cnt_i2c_clk == 2'd1))
							po_data_reg  <=  {po_data_reg[6:0],sda_in}  ;
						else
							po_data_reg  <=  po_data_reg  ;
			default	:	po_data_reg  <=  po_data_reg  ;
		endcase
		
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_data  <=  8'd0  ;
	else  if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd6))
		po_data  <=  po_data_reg  ;
	else
		po_data  <=  po_data  ;
		
always@(*)
	case(c_state)
		ACK_1,ACK_2,ACK_3  :  ack  =  ~sda_in  ;
		NACK			   :  ack  =  i2c_sda  ;
		default	:	ack  =  1'b0  ;
	endcase
		
always@(*)
	case(c_state)
		IDLE		:	i2c_scl  =  1'b1  ;
		START		:	if(cnt_i2c_clk == 2'd3)
							i2c_scl  =  1'b0  ;
						else
							i2c_scl  =  1'b1  ;
		SLAVE_ADDR,ACK_1,DEVICE_ADDR,ACK_2,DATA,ACK_3,NACK
					:	if((cnt_i2c_clk == 2'd0)||(cnt_i2c_clk == 2'd3))
							i2c_scl  =  1'b0  ;
						else
							i2c_scl  =  1'b1  ;
		WAIT		:	i2c_scl  =  1'b0  ;
		STOP		:	if(cnt_i2c_clk == 2'd0)
							i2c_scl  =  1'b0  ;
						else
							i2c_scl  =  1'b1  ;
		default		:	i2c_scl  =  1'b1  ;
    endcase
	
always@(*)
	case(c_state)
		IDLE		:	i2c_sda  =  1'b1  ;
		START		:	if(cnt_i2c_clk == 2'd0)
							i2c_sda  =  1'b1  ;
						else
							i2c_sda  =  1'b0  ;
		SLAVE_ADDR	:	i2c_sda  =  slave_addr[7 - cnt_bit]  ;
		ACK_1,ACK_2,ACK_3
					:	i2c_sda	 =  1'b0  ;
		NACK		:	i2c_sda  =  1'b1  ;
		DEVICE_ADDR	:	i2c_sda  =  device_addr[7 - cnt_bit]  ;
		DATA		:	i2c_sda  =  wr_data[7 - cnt_bit]  ;
		WAIT		:	i2c_sda  =  1'b0  ;
		STOP		:	if((cnt_i2c_clk == 2'd0)||(cnt_i2c_clk == 2'd1))
							i2c_sda  <=  1'b0  ;
						else
							i2c_sda  <=  1'b1  ;
		default		:	i2c_sda  <=  1'b1  ;
    endcase

endmodule
