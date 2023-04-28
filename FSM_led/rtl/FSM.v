module FSM (
    input       wire            clk ,
    input       wire            rstn,

    output      wire    [2:0]   led
);

    parameter   Max     =   4'd10          ;
    parameter   Max_1s  =   26'd5000_0000   ;

// 状态空间（state space）
    parameter   IDLE    =   2'd0    ;
    parameter   Red     =   2'd1    ;
    parameter   Green   =   2'd2    ;
    parameter   Yellow  =   2'd3    ;

// 动作空间（action space）
    parameter   No      =   3'b000  ;
    parameter   Stop    =   3'b001  ;
    parameter   Rush    =   3'b010  ;
    parameter   Ready   =   3'b100  ;

    reg     [1:0]   cstate          ;   // current state 现态
    reg     [1:0]   nstate          ;   // next state 次态
    reg     [2:0]   led_r           ;
    reg     [3:0]   cnt             ;
    reg     [26:0]  cnt_1s          ;

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
            IDLE:   nstate = Red;
            Red: begin
                if(cnt == 5) begin
                    nstate = Green;
                end
                else begin
                    nstate = cstate; 
                end
            end
            Green: begin
                if(cnt == 8) begin
                    nstate = Yellow;
                end
                else begin
                    nstate = cstate;
                end
            end
            Yellow: begin
                if(cnt == 9) begin
                    nstate = Red;
                end
                else begin
                    nstate = cstate;
                end
            end
            default: begin
                nstate = IDLE;
            end    
        endcase
    end

    // 三段式状态机，第三段，时序逻辑
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            led_r <= No;
        end
        else begin
            case (cstate)
                IDLE    :   led_r <= No     ;
                Red     :   led_r <= Stop   ;
                Green   :   led_r <= Rush   ;
                Yellow  :   led_r <= Ready  ;
                default :   led_r <= No     ;
            endcase
        end
    end
    assign led = led_r;

endmodule //fsm