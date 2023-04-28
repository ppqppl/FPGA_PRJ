module key_drive (
    input   wire clk,
    input   wire rst_n,
    input   wire [2:0] key, //按键
    output  reg [19:0] value //输出到数码管显示的值
);

parameter MAX_VALUE = 20'd1024;     //最大显示数字

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        value <= 20'd0;
    end

    else if (value >= MAX_VALUE) begin
        value <= 20'd0;
    end

    // 根据按下的键进行对应的操作
    else begin
        if(key[0]) begin
            value <= 2;
        end
        else if (key[1]) begin
            value <= 3;
        end
        else if (key[2]) begin
            value <= 4;
        end
        else begin
            value <= value;
        end
    end
end
endmodule
