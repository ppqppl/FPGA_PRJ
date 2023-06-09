module AUTO_Buy(
    input    wire             clk       ,   //时钟 50M
    input    wire             rst_n     ,   //复位
    input    wire    [3:0]    key       ,   //按键
 
    output    wire             beep     ,   //蜂鸣器
    // output    wire    [3:0]    led      ,   //售货机状态灯效
    output    wire    [5:0]    sel      ,   //数码管位选
    output 	  wire    [7:0]    seg      ,   //数码管段选
    output    wire    [6:0]    lan_led      //音乐播放灯效
 
);
 
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
.seg            (seg)
	
);
 
//售货机模块
machine_drive inst_machine_drive(
.clk        (clk)               ,
.rst_n      (rst_n)             ,
// .key        ({key_value[2] && key_flag[2], key_value[1] && key_flag[1], key_value[0] && key_flag[0] }),
.key        (key)               ,
 
.led_value  (led_value)         ,
.price_put  (price_put)         ,
.price_need (price_need)        ,
.price_out  (price_out)			 
);
 
// //led模块
// led_drive inst_led(
// .clk        (clk)               ,
// .rst_n      (rst_n)             ,
// .value      (led_value)         ,
 
// .led        (led)
// );
 
// //音乐模块
// freq_select inst_freq_select
// (
// .clk        (clk   )            ,
// .rst_n      (rst_n )            ,
	     	
// .status     (status)            , 
// .spec_flag  (spec_flag)
// );
 
// //音乐灯效模块
// lanterns inst_lanterns(
// .clk        (clk   )            ,
// .rst_n      (rst_n )            ,
// .spec_flag  (spec_flag)         ,
        
// .lan_led    (lan_led)
// );
 
 
// //蜂鸣器
// beep_drive inst_beep_drive(
// .clk        (clk)               ,
// .rst_n      (rst_n)             ,
// .flag       ((key_value[2] && key_flag[2]) || ( key_value[1] && key_flag[1]) || (key_value[0] && key_flag[0])),    
// .status     (status)            ,
// .beep       (beep)
// );
 
// //按键消抖
// key_debounce inst_key_debounce_key0(
// .clk        (clk)               ,
// .rst_n      (rst_n)             ,
// .key        (key[0])            ,
          
// .flag       (key_flag[0])       ,
// .key_value  (key_value[0])
// );
 
// key_debounce inst_key_debounce_key1(
// .clk        (clk)               ,
// .rst_n      (rst_n)             ,
// .key        (key[1])            ,
          
// .flag       (key_flag[1])       ,
// .key_value  (key_value[1])
// );
 
// key_debounce inst_key_debounce_key2(
// .clk        (clk)               ,
// .rst_n      (rst_n)             ,
// .key        (key[2])            ,
          
// .flag       (key_flag[2])       ,
// .key_value  (key_value[2])
// );
 
endmodule
