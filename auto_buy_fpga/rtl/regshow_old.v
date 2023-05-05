module regshow (
    input   wire            clk         ,
    input   wire            rstn        ,
    input   wire    [3:0]   key         ,
    input   wire            flag        ,
    input   wire            flag_20ns   ,
    input   wire            flag_2s     , 
    
    output  reg             flag_charge ,
    output  reg     [1:0]   sel_0       ,
    output  reg     [5:0]   sel         ,
    output  reg     [7:0]   seg         
);

    parameter  IDLE        =   4'd0    ;
    parameter  BUY         =   4'd1    ;
    parameter  PAY         =   4'd2    ;
    parameter  CHANGE      =   4'd3    ;

    reg     [3:0]       cstate      ;
    reg     [3:0]       nstate      ;
    reg     [4:0]       number      ;
    wire    [4:0]       num6        ;   // 6-1 从左到右
    wire    [4:0]       num5        ;
    wire    [4:0]       num4        ;
    wire    [4:0]       num3        ;
    wire    [4:0]       num2        ;
    wire    [4:0]       num1        ;

    reg     [19:0]      money_show  ;   // 总钱数
    reg     [19:0]      money_total ;   // 总钱数
    reg     [4:0]       money_pay   ;   // 应该付的钱
    reg     [4:0]       money_paid  ;   // 已经付的钱
    reg     [4:0]       money_charge;   // 找零
    reg                 flag_buy    ;   // 是否购买

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            sel <= 6'b011111;
        end
        else if(flag_20ns)begin
            sel <= {sel[0],sel[5:1]};
        end
        else begin
            sel <= sel;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cstate <= IDLE;
        end
        else begin
            cstate <= nstate;
        end
    end

    always @(*) begin   // 售货机状态判断
        if(!rstn) begin
            flag_buy = 1'b0;
        end
        case (cstate)
            IDLE: begin
                if(key[2]&&!flag_buy) begin
                    nstate = BUY;
                    flag_buy = 1'b1;
                end
                else begin
                    nstate = IDLE;
                end
            end
            BUY: begin
                if(key[2]&&flag_buy) begin
                    nstate = PAY;
                    flag_buy = 1'b0;
                end
                else begin
                    nstate = BUY;
                end
            end
            PAY: begin
                if((key[2] && money_paid == money_pay)||(money_paid > money_pay)) begin
                    nstate = CHANGE;
                end
                else begin
                    nstate = PAY;
                end
            end
            CHANGE: begin
                if(flag_2s) begin
                    nstate = IDLE;
                    flag_buy = 1'b0;
                    flag_charge = 1'd0;
                end
                else begin
                    nstate = CHANGE;
                    flag_charge = 1'd1;
                end
            end
            default:    ;
        endcase
    end

    always @(posedge clk or negedge rstn) begin   // 数码管显示
        if(!rstn) begin
            money_total <= 20'd200;
        end
        else begin
            case (cstate)
                IDLE: begin
                    money_show <= money_total;
                    // num1 <= 4'd0;
                    // num2 <= 4'd0;
                    // num3 <= 4'd0;
                    // num4 <= 4'd0;
                    // num5 <= 4'd0;
                    // num6 <= 4'd0;
                end
                BUY: begin
                    if(key[0]) begin
                        money_pay <= 4'd15;
                    end
                    else if(key[1]) begin
                        money_pay <= 5'd20;
                    end
                    else begin
                        money_pay <= money_pay;
                    end
                end
                PAY: begin
                    if(key[0]) begin
                        money_paid <= money_paid + 3'd5;
                    end
                    else if(key[1]) begin
                        money_paid <= money_paid + 5'd20;
                    end
                    else begin
                        money_paid <= money_paid;
                    end
                end
                CHANGE: begin
                    money_charge = money_paid - money_pay;
                    if(flag_2s) begin
                        money_total <= money_total + money_pay;
                        money_paid <= 1'd0;
                        money_pay <= 1'd0;
                        money_charge <= 1'd0;
                    end
                    else begin
                        money_paid <= money_paid;
                        money_charge <= money_charge;
                        money_pay <= money_pay;
                        money_total <= money_total;
                    end
                end
            endcase
        end
    end

    always @(*) begin
        case (sel)
            6'b011111:  number = num6;
            6'b101111:  number = num5;
            6'b110111:  number = num4;
            6'b111011:  number = num3;
            6'b111101:  number = num2;
            6'b111110:  number = num1;
        endcase
    end

    always @(posedge clk or negedge rstn)begin
        if(!rstn)
            seg <= 8'b0;
        else begin
            case(number)//匹配16进制数
                5'd0:       seg <= 8'b1100_0000;//匹配到后参考共阴极真值表
                5'd1:       seg <= 8'b1111_1001;
                5'd2:       seg <= 8'b1010_0100;
                5'd3:       seg <= 8'b1011_0000;
                5'd4:       seg <= 8'b1001_1001;
                5'd5:       seg <= 8'b1001_0010;
                5'd6:       seg <= 8'b1000_0010;
                5'd7:       seg <= 8'b1111_1000;
                5'd8:       seg <= 8'b1000_0000;
                5'd9:       seg <= 8'b1001_0000;
                5'd10:      seg <= 8'b0100_0000;//匹配到后参考共阴极真值表
                5'd11:      seg <= 8'b0111_1001;
                5'd12:      seg <= 8'b0010_0100;
                5'd13:      seg <= 8'b0011_0000;
                5'd14:      seg <= 8'b0001_1001;
                5'd15:      seg <= 8'b0001_0010;
                5'd16:      seg <= 8'b0000_0010;
                5'd17:      seg <= 8'b0111_1000;
                5'd18:      seg <= 8'b0000_0000;
                5'd19:      seg <= 8'b0001_0000;
                5'd20:      seg <= 8'b1111_1111;
                default :   seg <= 8'b1100_0000;
            endcase
        end
    end

    assign  num1 = money_show % 4'd10;
    assign  num2 = (money_show % 7'd100) / 4'd10 + 4'd10;
    assign  num3 = (money_show % 10'd1000) / 7'd100;
    assign  num4 = (money_show / 10'd1000) % 4'd10;
    assign  num5 = (money_show / 14'd10000) % 4'd10;
    assign  num6 = money_show / 17'd10_0000;

 endmodule//regshow