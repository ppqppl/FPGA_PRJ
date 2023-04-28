module KLED (
    input  wire       clk   ,
    input  wire [3:0] key   ,
    input  wire       rstn  ,
    output wire [3:0] led   
);
    
    parameter MAX = 26'd5000_0000;
    reg [25:0] cnt;
    reg [3:0]  led_r;

    parameter MAX_20ms = 20'd100_0000;
    reg     [19:0] cnt_20ms ;
    reg     [3:0]  key_flag ;
    reg            start    ;   // 稳定信号开始
    reg     [3:0]  key_r0   ;  // 按键信号寄存器0
    reg     [3:0]  key_r1   ;  // 按键信号寄存器1
    wire    [3:0]  nedge    ;
    reg     [3:0]  flag     ;    // 开启流水灯
    reg     [3:0]  counter  ;   // 按键计数

    // 20ms 倒计时计数器设计
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_20ms <= MAX_20ms;
        end
        else if(start) begin
            if(cnt_20ms == 1'd1)begin
                cnt_20ms <= 20'd0;
            end
            else begin
                cnt_20ms <= cnt_20ms - 1'd1; 
            end
        end
        else if(flag && cnt_20ms == 1'b1) begin
            cnt_20ms <= MAX_20ms;
        end
        else begin
            cnt_20ms <= cnt_20ms;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            key_r0 <= 4'b1111;
            key_r1 <= 4'b1111;
        end
        else begin
            key_r0 <= key;  // 打一拍，同步时钟域
            key_r1 <= key_r0;    // 打一拍，检测按键下降沿 
        end
    end

    // start 信号约束
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            start <= 1'b0;
        end
        else if(nedge) begin
            start <= 1'b1;
        end
        else if(cnt_20ms == 1'b1) begin
            start <= 1'b0;
        end
        else begin
            start <= start;
        end
    end
    // 约束 flag 信号
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            flag <= 4'b0000;
        end
        else if(cnt_20ms == 1'b1) begin
            flag <= ~key_r0;
        end
        else begin
            flag <= 4'b0000;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt <= 26'd0;
        end
        else if(cnt == MAX - 1'd1) begin
            cnt <= 26'd0;
        end
        else begin
            cnt <= cnt + 1'd1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            led_r <= 4'b0000;
            counter <= 4'b1111;
        end
        else if(flag[0]) begin
                led_r[0] <= ~led_r[0];
        end
        else if(flag[1]) begin
                led_r[1] <= ~led_r[1];
        end
        else if(flag[2]) begin
                led_r[2] <= ~led_r[2];
        end
        else if(flag[3]) begin
                led_r[3] <= ~led_r[3];
        end
        else begin
            led_r <= led_r;
        end
    end

    assign nedge = ~key_r0 & key_r1;
    assign led = led_r;
endmodule

     
     
     
     
     
     
     
     
     
     
     
     
     
     
    