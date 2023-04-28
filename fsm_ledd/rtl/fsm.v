/***三段式状态机***/
module fsm(
    input   wire          clk  ,//时钟
    input   wire          rst_n,//复位，下降沿有效

    output  wire [2: 0]   led
);
parameter MAX_CNT = 26'd50_000_000;
parameter MAX_83  = 7'd83;
reg [25: 0] cnt_1s;
reg [6: 0]  cnt_83;
//状态空间(state space)
parameter IDLE   = 2'd0, 
          RED    = 2'd1,
          GREEN  = 2'd2,
          YELLOW = 2'd3; 
//动作空间(action space)
parameter NO    = 3'b000,
          STOP  = 3'b001,
          RUSH  = 3'b010,
          READY = 3'b100;
reg [1: 0] cstate;//current state,现态
reg [1: 0] nstate;//next state,次态
reg [2: 0] led_r ;

//1s计数器
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_1s <= 26'd0;
    end 
    else if(cnt_1s == MAX_CNT - 1'd1)begin
        cnt_1s <= 26'd0;
    end   
    else begin
        cnt_1s <= cnt_1s + 1'd1;
    end   
end 

//83s计数器
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_83 <= 7'd0;
    end 
    else if(cnt_83 == MAX_83 - 1'd1 && cnt_1s == MAX_CNT - 1'd1)begin
        cnt_83 <= 7'd0;
    end
    else if(cnt_1s == MAX_CNT - 1'd1)begin
        cnt_83 <= cnt_83 + 1'd1;
    end 
    else begin
        cnt_83 <= cnt_83;
    end 
end 

//三段式状态机，第一段，时许逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cstate <= IDLE;//初始当前状态为空闲
    end 
    else begin
        cstate <= nstate;//次态赋值给现态
    end 
end
//三段式状态机，第二段，组合逻辑
always @(*)begin
    case(cstate)
        IDLE:  nstate = RED;    
        RED:   begin
                    if(cnt_83 == 59 && cnt_1s == MAX_CNT - 1'd1)begin
                        nstate = GREEN;
                    end 
                    else begin
                        nstate = cstate; 
                    end 
               end 
        GREEN: begin
                    if(cnt_83 == 79 && cnt_1s == MAX_CNT - 1'd1)begin
                        nstate = YELLOW;
                    end
                    else begin
                        nstate = cstate;
                    end 
               end
        YELLOW:begin
                    if(cnt_83 == 82 && cnt_1s == MAX_CNT - 1'd1)begin
                        nstate = RED;
                    end 
                    else begin
                        nstate = cstate;
                    end 
               end 
        default:   nstate = IDLE;
    endcase
end 
//有限状态机，第三段，时许逻辑
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        led_r <= NO;
    end 
    else begin
        case(cstate)
            IDLE:    led_r  <= NO      ;
            RED :    led_r  <= STOP    ;
            GREEN:   led_r  <= RUSH    ;
            YELLOW:  led_r  <= READY   ;
            default: led_r  <= NO      ;
        endcase
    end 
end 
assign led = led_r;
endmodule 