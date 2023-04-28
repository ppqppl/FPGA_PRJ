module segshow (
    input   wire            clk     ,
    input   wire            rstn    ,  
    input   wire            flag    , 

    output  reg     [7:0]   sel     ,
    output  reg     [7:0]   seg  
);
    
    reg     [3:0]       number      ;

    always @(posedge clk or negedge rstn)begin
        if(!rstn)//如果按复位键0
            sel <= 8'b0000_0000;//则默认为高电平
        else 
            sel <= 8'b1111_1111;//否则为低电平
    end

    always @(posedge clk or negedge rstn)begin
        if(!rstn)
            number <= 4'h0;
        else if(flag)begin
            if(number < 4'hf)
                number <= number + 1'h1;
            else 
                number <= 4'h0;
        end
        else begin
            number <= number;
        end
    end

    always @(posedge clk or negedge rstn)begin
        if(!rstn)
            seg <= 8'b0;
        else begin
            case(number)//匹配16进制数
                4'h0:       seg <= 8'b1100_0000;//匹配到后参考共阴极真值表
                4'h1:       seg <= 8'b1111_1001;
                4'h2:       seg <= 8'b1010_0100;
                4'h3:       seg <= 8'b1011_0000;
                4'h4:       seg <= 8'b1001_1001;
                4'h5:       seg <= 8'b1001_0010;
                4'h6:       seg <= 8'b1000_0010;
                4'h7:       seg <= 8'b1111_1000;
                4'h8:       seg <= 8'b1000_0000;
                4'h9:       seg <= 8'b1001_0000;
                4'ha:       seg <= 8'b1000_1000;
                4'hb:       seg <= 8'b1000_0011;
                4'hc:       seg <= 8'b1100_0110;
                4'hd:       seg <= 8'b1010_0001;
                4'he:       seg <= 8'b1000_0110;
                4'hf:       seg <= 8'b1000_1110;
                default :   seg <= 8'b1100_0000;
            endcase
        end
    end

endmodule //segshow