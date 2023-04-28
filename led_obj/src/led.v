module LED_obj (
    input       wire            clk         ,
    input       wire            rst_n       ,
	input 	    wire 	        key         , 
	output 	    reg 	        flag        ,// 0抖动, 1抖动结束
    output      reg             key_value   ,
    output      wire    [3:0]   led_on
);
    parameter  MAX_1s = 26'd50_000_000;
    parameter  MAX_500ms = 25'd25_000_000;
    parameter  MAX_NUM = 20'd1_000_000;
    reg     [25:0]              cnt1s;
    reg     [3:0]               led_r;
    
    reg [19:0] delay_cnt;//1_000_000
    reg key_reg;//key上一次的值

    //计数1s计数器设计
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin                                 //复位
            cnt1s <= 26'd0;
        end
        else if (cnt1s == MAX_500ms -1'b1) begin
            cnt1s <= 26'd0;
        end
        else begin
            cnt1s <= cnt1s + 1'd1;
        end
    end

    always @(posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            led_r <= 4'b0001;
        end
        else if (cnt1s == MAX_500ms - 1'b1) begin
            led_r <= {led_r[0],led_r[3:1]};
        end
        else begin
            led_r <= led_r;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            key_reg <= 1;
            delay_cnt <= 0;
        end
        
        else begin
            key_reg <= key;
            //当key为1 key 为0 表示按下抖动,开始计时
            if(key_reg  != key  ) begin 
            delay_cnt <= MAX_NUM ;
            end
            else begin
                if(delay_cnt > 0)
                    delay_cnt <= delay_cnt -1;
                else
                    delay_cnt <= 0;
            end
        end
    end


    //当计时完成,获取key的值
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            flag <= 0;
            key_value <= 1;
        end

        else begin
            
            // 计时完成 处于稳定状态,进行赋值
            if(delay_cnt == 1) begin
                flag <= 1;
                key_value <= key;
            end
            else begin
                flag <= 0;
                key_value <= key_value;
            end
        end
    end

    assign led_on = led_r;

endmodule