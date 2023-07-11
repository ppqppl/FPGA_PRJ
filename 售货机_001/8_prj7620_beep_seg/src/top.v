module top (
    input       wire        clk         ,
    input       wire        rstn        ,
    // input    wire    [3:0]    key       ,   //按键
	
	output	wire			scl			,
	output	wire	[3:0]	led			,
	output	wire	[7:0]	dig			,
	output	wire	[5:0]	sel			,
	output	wire			beep		,
	
	inout	wire			sda	
);

wire [3:0]  flag;

AUTO_Buy u_AUTO_Buy(
    .clk       (clk),   //时钟 50M
    .rst_n     (rstn),   //复位
    .key       (flag),   //按键
    .beep      (beep),   //蜂鸣器
    // .led       (led),   //售货机状态灯效
    .sel       (sel),   //数码管位选
    .seg       (dig),   //数码管段选
    .lan_led   (lan_led)   //音乐播放灯效
 
);

prj7620_beep_seg u_prj7620_beep_seg(
	.sys_clk		(clk),
	.sys_rst_n	    (rstn),
	.scl			(scl),
	.led			(led),
	// .dig			(dig),
    .flag           (flag),
	// .sel			(sel),
//	.beep		    (beep),
	.sda	        (sda)
);

endmodule //top