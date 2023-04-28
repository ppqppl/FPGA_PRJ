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
    wire            nedge           ;
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
            beep <= 1'b1;
        end
        else begin
            case (cstate)
                IDLE    :   begin
                    led_r <= lock;
                    case (sel)
                    6'b011111: number = 4'd2;
                    6'b101111: number = 4'd6;
                    6'b110111: number = 4'd8;
                    6'b111011: number = 4'd8;
                    6'b111101: number = 4'd8;
                    6'b111110: number = 4'd8;
                    default:   number = 4'd8;
                    endcase
                end   
                S1      :   begin
                    led_r <= s1_led;
                    case (sel)
                    6'b011111: number = 4'd4;
                    6'b101111: number = 4'd8;
                    6'b110111: number = 4'd8;
                    6'b111011: number = 4'd8;
                    6'b111101: number = 4'd8;
                    6'b111110: number = 4'd8;
                    default:   number = 4'd8;
                    endcase
                end 
                S2      :   begin
                    led_r <= s2_led;
                    case (sel)
                    6'b011111: number = 4'd4;
                    6'b101111: number = 4'd4;
                    6'b110111: number = 4'd8;
                    6'b111011: number = 4'd8;
                    6'b111101: number = 4'd8;
                    6'b111110: number = 4'd8;
                    default:   number = 4'd8;
                    endcase
                end
                S3      :   begin
                    led_r <= s3_led;
                    case (sel)
                    6'b011111: number = 4'd4;
                    6'b101111: number = 4'd4;
                    6'b110111: number = 4'd4;
                    6'b111011: number = 4'd8;
                    6'b111101: number = 4'd8;
                    6'b111110: number = 4'd8;
                    default:   number = 4'd8;
                    endcase
                end 
                S4      :   begin
                    led_r <= unlock;
                    case (sel)
                    6'b011111: number = 4'd2;
                    6'b101111: number = 4'd6;
                    6'b110111: number = 4'd5;
                    6'b111011: number = 4'd7;
                    6'b111101: number = 4'd8;
                    6'b111110: number = 4'd8;
                    default:   number = 4'd8;
                    endcase
                end 
                Error   : begin 
                    beep = ~beep;
                    led_r <= error_led;
                    case (sel)
                    6'b011111: number = 4'd1;
                    6'b101111: number = 4'd2;
                    6'b110111: number = 4'd1;
                    6'b111011: number = 4'd1;
                    6'b111101: number = 4'd4;
                    6'b111110: number = 4'd8;
                    default:   number = 4'd8;
                    endcase
                    
                end 
                default :begin
                    beep = beep;
                    led_r <= lock;
                    case (sel)
                    6'b011111: number = 4'd8;
                    6'b101111: number = 4'd8;
                    6'b110111: number = 4'd8;
                    6'b111011: number = 4'd8;
                    6'b111101: number = 4'd8;
                    6'b111110: number = 4'd8;
                    default:   number = 4'd8;
                    endcase
                end   
            endcase
        end
    end

    // 数码管
    // always @(posedge clk or negedge rstn)begin
	//     if(!rstn)//如果按复位键0
	// 	    sel <= 6'b111111;//则默认为高电平
	//     else 
	// 	    sel <= 6'b000000;//否则为低电平
    // end

    //位选信号切换模块
    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            sel <= 6'b011111;//初始化第一个数码管亮
        end 
        else if(cnt_shuma == MAX_shuma - 1'd1)begin
            sel <= {sel[0],sel[5:1]};//每隔20us进行位移操作
        end 
        else begin
            sel <= sel;//其他时间保持不变
        end 
    end 

    always @(posedge clk or negedge rstn)begin
        if(!rstn)
            seg <= 8'b0;
        else begin
            case(number)//匹配16进制数
                4'd1:    seg <= 8'b1000_1111;   // r
                4'd2:    seg <= 8'b1100_0000;   // o
                4'd3:    seg <= 8'b1000_1100;   // p
                4'd4:    seg <= 8'b1000_0100;   // e
                4'd5:    seg <= 8'b1100_1000;   // n
                4'd6:    seg <= 8'b1100_0111;   // l
                4'd7:    seg <= 8'b1100_0001;   // u
                4'd8:    seg <= 8'b1111_1111;   // no
                default : seg <= 8'b1100_0000;
            endcase
        end
    end

    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn) begin
    //         beep <= 1'b0;
    //     end
    //     else if(cstate == Error) begin
    //         beep <= ~beep;
    //     end
    //     else begin
    //         beep <= beep;
    //     end
    // end

    assign nedge = (~key_r0[0] && key_r1[0])||(~key_r0[1] && key_r1[1])||(~key_r0[2] && key_r1[2])||(~key_r0[3] && key_r1[3]);//检测下降沿
    assign led = led_r;
endmodule //fsm