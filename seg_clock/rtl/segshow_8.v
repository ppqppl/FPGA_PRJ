module segshow (
    input   wire            clk         ,
    input   wire            rstn        ,
    input   wire            flag_20ns   ,  
    input   wire    [4:0]   hour        ,   // 时
    input   wire    [5:0]   min         ,   // 分
    input   wire    [5:0]   sec         ,   // 秒

    output  reg     [7:0]   sel         ,
    output  reg     [7:0]   seg  
);

    parameter   sec_ti     =   2'd0    ;
    parameter   min_ti     =   2'd1    ;
    parameter   hour_ti    =   2'd2    ; 

    reg     [3:0]  num         ;
    wire    [3:0]   sec_low     ;
    wire    [3:0]   sec_hi      ;
    wire    [3:0]   min_low     ;
    wire    [3:0]   min_hi      ;
    wire    [3:0]   hour_low    ;
    wire    [3:0]   hour_hi     ;




    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            sel <= 8'b0000_0000;
        end
        else if(flag_20ns)begin
            sel <= {sel[0],sel[5:1]};
        end
        else begin
            sel <= sel;
        end
    end

    always @(*) begin
        case (sel)
            8'b1101_1111:  num = sec_low   ;
            8'b1110_1111:  num = sec_hi    ;
            8'b1111_0111:  num = min_low   ;
            8'b1111_1011:  num = min_hi    ;
            8'b1111_1101:  num = hour_low  ;
            8'b1111_1110:  num = hour_hi   ;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            seg <= 8'b1100_0000;
        end
        else begin
            case (num)
                4'd0:		seg <= 8'b1100_0000;//数码管显示0
                4'd1:		seg <= 8'b1111_1001;//数码管显示1
                4'd2: 		seg <= 8'b1010_0100;//数码管显示2
                4'd3: 		seg <= 8'b1011_0000;//数码管显示3
                4'd4: 		seg <= 8'b1001_1001;//数码管显示4
                4'd5: 		seg <= 8'b1001_0010;//数码管显示5
                4'd6: 		seg <= 8'b1000_0010;//数码管显示6
                4'd7: 		seg <= 8'b1111_1000;//数码管显示7
                4'd8: 		seg <= 8'b1000_0000;//数码管显示8
                4'd9:    	seg <= 8'b1001_0000;//数码管显示9
                default:	seg <= 8'b1100_0000;//数码管显示0
            endcase
        end
    end
    assign sec_low   = sec % 4'd10 ;
    assign sec_hi    = sec / 4'd10 ;
    assign min_low   = min % 4'd10 ;
    assign min_hi    = min / 4'd10 ;
    assign hour_low  = hour % 4'd10;
    assign hour_hi   = hour / 4'd10;

endmodule //segshow
/*
82000:
22:46:40
82000/3600 = 22
(82000%3600)/60 = 46
(82000%3600)%60 = 40
*/