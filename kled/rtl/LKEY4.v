module key_led (
    input   wire            clk     ,
    input   wire            rst_n   ,
    input   wire     [3:0]  key     ,
    
    output  wire     [3:0]  led 
);
    

//按键控制0.5s循环流水灯
parameter MAX = 25'd25_000_000;
reg     [24:0]  cnt     ;
reg     [3:0]   led_r   ;

//按键消抖

parameter MAX20 = 20'd1_000_000;
reg     [19:0]      cnt_20  ;
reg                 start   ;//稳定信号开始
reg      [3:0]      key_r0  ;//按键信号寄存器0
reg      [3:0]      key_r1  ;//按键信号寄存器1
wire                nedge   ;//下降沿信号
reg      [3:0]      flag    ;//开启流水灯信号


// always @(posedge clk or negedge rst_n) begin
    // if(!rst_n)begin
        // cnt <= 25'd0;
    // end
    // else if(cnt == MAX- 1'd1)begin
        // cnt <= 25'd0;
    // end
    // else begin
        // cnt <= cnt + 1'd1;
    // end
// end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        led_r <= 4'b0000;
    end
    else if(flag[0])begin
        led_r <= {led_r[3:1],~led_r[0]};
    end
    else if(flag[1])begin
        led_r <= {led_r[3:2],~led_r[1],led_r[0]};
    end
    else if(flag[2])begin
        led_r <= {led_r[3],~led_r[2],led_r[1:0]};
    end
    else if(flag[3])begin
        led_r <= {~led_r[3],led_r[2:0]};
    end
    else begin
        led_r <= led_r;
    end
end

assign led = led_r;



//20ms倒计时计数器
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_20 <= 20'd0;//修改
    end
    else if(start)begin
        if(cnt_20 == 1'b1)begin
            cnt_20 <= MAX20;//修改
        end
        else begin
            cnt_20 <= cnt_20 - 1'b1;
        end
    end
    else begin
        cnt_20 <= cnt_20;
    end
end


always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        key_r0 <= 4'b1111;
        key_r1 <= 4'b1111;
    end
    else begin
        key_r0 <= key;//打一拍，同步时钟域
        key_r1 <= key_r0;//打一拍，检测按键下降沿
    end
end
assign nedge = (~key_r0[0] && key_r1[0])||(~key_r0[1] && key_r1[1])||(~key_r0[2] && key_r1[2])||(~key_r0[3] && key_r1[3]);//检测下降沿

//start信号约束
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        start <= 1'b0;
    end
    else if(nedge)begin
        start <= 1'b1;
    end
    else if(cnt_20 == 1'b1)begin
        start <= 1'b0;
    end
    else begin
        start <= start;
    end
end

//约束flag信号
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        flag <= 4'b0000;
    end
    else if(cnt_20 == 1'b1)begin
        flag <= ~key_r0;
    end
    else begin
        flag <= 4'b0000;
    end
end


endmodule