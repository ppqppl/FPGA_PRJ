module  prj7620_beep_seg
(
	input	wire			clk		,
	input	wire			rst_n	,
	
	output	wire			scl			,
	output	wire	[3:0]	led			,
	output	wire	[7:0]	dig			,
	output	wire	[5:0]	sel			,
	output	wire			beep		,
	
	inout	wire			sda	
);

wire	[7:0]	data		;
reg		[3:0]	flag		;
reg 	[3:0]	data_1		;
wire 	[3:0]	pedge		;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_1 <= 4'b0000;
	end
	else begin
		data_1 <= data;
	end
end

assign pedge = data & ~data_1;
assign flag_hand = flag;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		flag <= 4'b0000;
	end
	else begin
		case (pedge)
			4'b0001: flag <= 4'b0001;
			4'b0010: flag <= 4'b0010;
			4'b0100: flag <= 4'b0100;
			4'b1000: flag <= 4'b1000;
			default : flag <= 4'b0000;
		endcase
	end
end

beep  beep_inst
(
	.sys_clk	(clk	),
	.sys_rst_n	(rst_n	),
	.flag		(flag[1:0]	),
	.beep		(beep		)
);

paj7620_top  paj7620_top_inst
(
	.sys_clk	(clk	)	,
	.sys_rst_n	(rst_n	)	,
	.scl		(scl		)	,
	// .led		(led		)	,
	.data		(data		)	,
	.sda	    (sda	    )
);

// seg_dynamic  seg_dynamic_inst
// (
// 	.sys_clk	(clk	)	,
// 	.sys_rst_n	(rst_n	)	,
// 	.flag		(flag[3:2]	)	,
// 	.dig		(dig		)	,
// 	.sel	    (sel	    )
// );


wire            status;         //音乐播放驱使蜂鸣器标志
wire    [2:0]   key_flag;       //按键消抖完成标志
wire    [2:0]   key_value;      //按键消抖完成后的按键值
wire    [4:0]   led_value;      //售货机驱使led模块效果的值
wire    [6:0]   price_put;      //售货机输出到数码管的投币值
wire    [6:0]   price_need;     //售货机输出到数码管的商品价格
wire    [6:0]   price_out;      //售货机输出到数码管的退款
wire    [2:0]   spec_flag;      //音乐模块输出的音符,用于音乐灯效
 

//数码管位选模块
sel_drive inst_sel_drive(
.clk            (clk)           ,
.rst_n          (rst_n)         ,
.price_put      (price_put)     ,      
.price_need     (price_need)    ,     
.price_out      (price_out)     ,  
.sel            (sel)
);
 
//数码管段选模块
seg_drive inst_seg_drive(
.clk            (clk)           ,	
.rst_n          (rst_n)         ,
 
.price_put      (price_put)     ,      
.price_need     (price_need)    ,     
.price_out      (price_out)     ,   
.sel            (sel)           ,          
.seg            (dig)
	
);

//售货机模块
buy inst_buy(
.clk        (clk)               ,
.rstn       (rst_n)             ,
.flag       (flag)              ,
 
.led_value  (led_value)         ,
.price_put  (price_put)         ,
.price_need (price_need)        ,
.price_out  (price_out)			 
);

//led模块
beep_led_drive inst_led_beep(
.clk        (clk)               ,
.rst_n      (rst_n)             ,
.value      (led_value)         ,
 
// .beep		(beep)				,
.led        (led)				
);
 
endmodule