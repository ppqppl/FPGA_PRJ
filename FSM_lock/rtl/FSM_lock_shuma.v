module FSM (
    input       wire            clk     ,
    input       wire            rstn    ,
    input       wire    [3:0]   key     ,

    output      wire    [3:0]   led     ,
    output      reg     [5:0]   sel     ,
    output      reg     [7:0]   seg     ,
	output 	    reg 	        beep        //蜂鸣器信号

);

    parameter   Max     =   4'd10          ;
    parameter   Max_1s  =   26'd5000_0000  ;
    
    parameter   MAX_20ms =  20'd100_0000   ;
    parameter   MAX_shuma =  10'd999   ;

// 状态空间（state space）
    parameter   IDLE    =   3'd0    ;
    parameter   S1      =   3'd1    ;
    parameter   S2      =   3'd2    ;
    parameter   S3      =   3'd3    ;
    parameter   S4      =   3'd4    ;
    parameter   Error   =   3'd5    ;

// 动作空间（action space）
    parameter   No          =   4'b0000  ;
    parameter   lock        =   4'b1111  ;
    parameter   unlock      =   4'b0000  ;
    parameter   error_led   =   4'b0101  ;
    parameter   s1_led      =   4'b0001  ;
    parameter   s2_led      =   4'b0011  ;
    parameter   s3_led      =   4'b0111  ;

// 其他变量
    reg     [2:0]   cstate          ;  // current state 现态
    reg     [2:0]   nstate          ;  // next state 次态
    reg     [3:0]   led_r           ;
    reg     [3:0]   cnt             ;
    reg             start           ;  // 稳定信号开始
    reg     [26:0]  cnt_1s          ;
    reg     [9:0]   cnt_shuma       ;
    reg     [19:0]  cnt_20ms        ;
    reg     [3:0]   key_r0          ;  // 按键信号寄存器0
    reg     [3:0]   key_r1          ;  // 按键信号寄存器1
    wire    [3:0]   nedge           ;
    reg     [3:0]   flag            ;  // 按键判断
    reg     [3:0] 	number	        ;  //显示时分秒寄存器

//  按键消抖

    // 20ms 倒计时计数器设计
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_20ms <= 20'd0;
        end
        else if(start) begin
            if(cnt_20ms == 1'd1)begin
                cnt_20ms <= MAX_20ms;
            end
            else begin
                cnt_20ms <= cnt_20ms - 1'd1; 
            end
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

//  计时器

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_1s <= 26'd0;
        end
        else if(cnt_1s == Max_1s - 1'd1) begin
            cnt_1s <= 26'd0;
        end
        else begin
            cnt_1s <= cnt_1s + 1'd1;
        end
        // else if(cstate == S4) begin  // 当解锁开始计时
        //     cnt_1s <= cnt_1s + 1'd1;
        // end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_shuma <= 10'd0;
        end
        else if(cnt_shuma == MAX_shuma - 1'd1) begin
            cnt_shuma <= 10'd0;
        end
        else begin
            cnt_shuma <= cnt_shuma + 1'd1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt <= 4'd0;
        end
        else if(cnt == Max - 1) begin
            cnt <= 4'd0;
        end
        else if(cnt_1s == Max_1s - 1) begin
            cnt <= cnt + 1'd1;
        end
        else begin
            cnt <= cnt;
        end
    end

//  状态机

    // 三段式状态机，第一段，时序逻辑
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cstate <= IDLE; // 初始当前状态为空闲
        end
        else begin
            cstate <= nstate;   // 次态赋值给现态
        end
    end

    // 三段式状态机，第二段，组合逻辑
    always @(*) begin
        case (cstate)
            IDLE: begin
                if(flag[0])begin//按下第1个按键，输入密码1
                    nstate = S1;
                end 
                else if(flag[1]||flag[2]||flag[3]) begin
                    nstate = Error;
                end
                else begin
                    nstate = IDLE;
                end 
            end 
            S1: begin
                if(flag[1])begin
                    nstate = S2;
                end 
                else if(flag[0]||flag[3]||flag[2])begin
                    nstate = Error;
                end 
                else begin
                    nstate = S1;
                end 
            end 
            S2: begin
                if(flag[2])begin
                    nstate = S3;
                end 
                else if(flag[0]||flag[1]||flag[3])begin
                    nstate = Error;
                end 
                else begin
                    nstate = S2;
                end 
            end 
            S3: begin
                if(flag[3])begin
                    nstate = S4;
                end 
                else if(flag[0]||flag[1]||flag[2])begin
                    nstate = Error;
                end 
                else begin
                    nstate = S3;
                end
            end 
            S4: begin//解锁状态
                if(flag[3])begin
                    nstate = IDLE;
                end
                else begin
                    nstate = S4;
                end 
            end 
            Error: begin
                if(flag[3])begin
                    nstate = IDLE;
                end 
                else begin
                    nstate = Error;
                end
            end
            default:;
        endcase
    end

    // 三段式状态机，第三段，时序逻辑
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            led_r <= No;
        end
        else begin
            case (cstate)
                IDLE    :    led_r <= lock;
                S1      :    led_r <= s1_led;
                S2      :    led_r <= s2_led;
                S3      :    led_r <= s3_led;
                S4      :    led_r <= unlock;
                Error   :    led_r <= error_led;
                default :    led_r <= lock; 
            endcase
        end
    end

    assign nedge = ~key_r0 & key_r1;
    assign led = led_r;
endmodule //fsm