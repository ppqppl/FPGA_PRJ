module AUTO_Buy(
    input    wire             clk       ,   //时钟 50M
    input    wire             rst_n     ,   //复位
    input    wire    [2:0]    key       ,   //按键
 
    output    wire             beep     ,   //蜂鸣器
    output    wire    [3:0]    led      ,   //售货机状态灯效
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
.key        ({key_value[2] && key_flag[2], key_value[1] && key_flag[1], key_value[0] && key_flag[0] }),
 
.led_value  (led_value)         ,
.price_put  (price_put)         ,
.price_need (price_need)        ,
.price_out  (price_out)			 
);
 
//led模块
led_drive inst_led(
.clk        (clk)               ,
.rst_n      (rst_n)             ,
.value      (led_value)         ,
 
.led        (led)
);
 
//音乐模块
freq_select inst_freq_select
(
.clk        (clk   )            ,
.rst_n      (rst_n )            ,
	     	
.status     (status)            , 
.spec_flag  (spec_flag)
);
 
//音乐灯效模块
lanterns inst_lanterns(
.clk        (clk   )            ,
.rst_n      (rst_n )            ,
.spec_flag  (spec_flag)         ,
        
.lan_led    (lan_led)
);
 
 
//蜂鸣器
beep_drive inst_beep_drive(
.clk        (clk)               ,
.rst_n      (rst_n)             ,
.flag       ((key_value[2] && key_flag[2]) || ( key_value[1] && key_flag[1]) || (key_value[0] && key_flag[0])),    
.status     (status)            ,
.beep       (beep)
);
 
//按键消抖
key_debounce inst_key_debounce_key0(
.clk        (clk)               ,
.rst_n      (rst_n)             ,
.key        (key[0])            ,
          
.flag       (key_flag[0])       ,
.key_value  (key_value[0])
);
 
key_debounce inst_key_debounce_key1(
.clk        (clk)               ,
.rst_n      (rst_n)             ,
.key        (key[1])            ,
          
.flag       (key_flag[1])       ,
.key_value  (key_value[1])
);
 
key_debounce inst_key_debounce_key2(
.clk        (clk)               ,
.rst_n      (rst_n)             ,
.key        (key[2])            ,
          
.flag       (key_flag[2])       ,
.key_value  (key_value[2])
);
 
endmodule

/*
1.默认只接收0.5元、1元投币。
⒉货物有4种可以选择，价格分别为0.5，1.5，2.4，3元。
3.满足当前选择的商品价格后自动出货，出货动作用4个LED做跑马灯(闪烁2s)表示。
4.超过前选择的商品价格之后，自动出货并找零，动作用4个LED做跑马灯表示(同样闪烁2s)。
5.显示当前投币的总额、当前选择的商品的价格以及找零的数目。
6.复位时播放音乐并显示彩灯。
7.投币不足目标价格时可以取消，动作用灯闪烁表示(2s)。


每个按键对应相应的功能:
key0:退货
key1:选择不同的价格(0.5;1.5;2.4，3.0)
key2:投币，按一次个位增加5，即为0.5
key3:投币，按一次十位增加1，即增加1 

按下key0后，蜂鸣器播放5秒的音乐，(音符+每个音符的空白时间)，每个音符对应一个外接彩灯闪烁灯
按下key1,key2,key3中任意一个，蜂鸣器会有0.2s的提示音
*/