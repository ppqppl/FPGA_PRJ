module i2c_ctrl (
    input   wire    sys_clk,
    input   wire    sys_rstn,

    output  wire    scl,    // serial clock i2c 串行时钟
    inout   wire    sda     // serial data i2c 串行数据线
);

    localparam MAX_CLK  = 5'd24     ;    // 分频 1 MHz
    localparam MAX_1000 = 10'd999   ;    // 1000 us
    localparam IDLE     = 3'd0      ,    // 空闲状态
               START    = 3'd1      ,    // 起始状态
               SLAVE_ID = 3'd2      ,    // 从机地址状态
               WAIT     = 3'd3      ,    // 等待状态
               STOP     = 3'd4      ;    // 停止状态

    reg     [2:0]   nstate      ;
    reg     [2:0]   cstate      ;
    reg     [9:0]   cnt_wait    ;   // 等待 1000us 计数器
    reg     [4:0]   cnt_clk     ;   // i2c 系统时钟寄存器
    reg             i2c_clk     ;
    reg             skip_en_1   ;   // step1 跳转使能

    // 分频时钟设计
    always @(posedge sys_clk or negedge sys_rstn) begin
        if(!sys_rstn) begin
            cnt_clk <= 5'd0;
        end
        else if(cnt_clk == MAX_CLK) begin
            cnt_clk <= 5'd0;
        end
        else begin
            cnt_clk <= cnt_clk + 5'd1;
        end
    end

    // i2c_clk 时钟约束
    always @(posedge sys_clk or negedge sys_rstn) begin
        if(!sys_rstn) begin
            i2c_clk <= 1'b0;
        end
        else if(cnt_clk == MAX_CLK) begin
            i2c_clk <= ~i2c_clk;
        end
        else begin
            i2c_clk <= i2c_clk;
        end
    end

    // 1000us 计数器设计, 此处后期回进行改动
    // always @(posedge i2c_clk or negedge sys_rstn) begin // 这里以 i2c 时钟为基准
    //     if(!sys_rstn) begin
    //         cnt_wait <= 10'd0;
    //     end        
    //     else if(cnt_wait == MAX_1000) begin
    //         cnt_wait <= 10'd0;
    //     end
    //     else begin
    //         cnt_wait <= cnt_wait + 10'd1;
    //     end
    // end

    /* 以下代码全部是i2c_clk */
    // 三段式状态机，第一段
    always @(posedge sys_clk or negedge sys_rstn) begin
        if(!sys_rstn) begin
            cstate <= IDLE;
        end
        else begin
            cstate <= nstate;
        end
    end

    // 三段式状态机，第二段，描述状态转移
    always @(posedge sys_clk or negedge sys_rstn) begin
        case (cstate)
            IDLE    :   begin
                            if(cnt_clk == MAX_CLK) begin
                                nstate <= START;
                            end
                            else begin
                                nstate <= IDLE;
                            end
                        end
            START   :   begin
                            if(cnt_clk == MAX_CLK) begin
                                nstate <= SLAVE_ID;
                            end
                            else begin
                                nstate <= START;
                            end
                        end
            SLAVE_ID:   begin
                            if(cnt_clk == MAX_CLK) begin
                                nstate <= WAIT;
                            end
                            else begin
                                nstate <= SLAVE_ID;
                            end
                        end
            WAIT    :   begin
                            if(cnt_clk == MAX_CLK) begin
                                nstate <= STOP;
                            end
                            else begin
                                nstate <= WAIT;
                            end
                        end
            STOP    :   begin
                            nstate <= IDLE;
                        end
            default :   begin
                            nstate <= IDLE;
                        end
        endcase
    end
endmodule //i2c_ctrl