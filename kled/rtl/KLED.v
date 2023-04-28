module KLED (
    input  wire       clk   ,
    input  wire [3:0] key   ,
    input  wire       rstn  ,
    output wire [3:0] led   ,
    output reg        flag  ,
    output reg  [3:0] key_v
);
    
    parameter MAX = 26'd5000_0000;
    reg [25:0] cnt;
    reg [3:0]  led_r;

    parameter MAX_20ms = 20'd100_0000;
    reg [19:0] cnt_20ms;
    reg [3:0]  key_flag;
    reg        start;

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
            led_r <= 4'b0001;
        end
        else if(key_v[0] == 0) begin
            if (cnt == MAX - 1) begin
                led_r <= {led_r[0],led_r[3:1]};
            end
            else begin
                led_r <= led_r;
            end
        end
        else begin
            led_r <= led_r;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_20ms <= 0;
            key_flag = 4'b1111;
        end
        else begin
            key_flag = key;
            if(key_flag != key) begin
                cnt_20ms <= MAX_20ms;
            end
            else begin
                if(cnt_20ms > 0) begin
                    cnt_20ms <= cnt_20ms - 1;
                end
                else begin
                    cnt_20ms <= 0;
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            flag <= 0;
            key_v <= 4'b1111;
        end
        else begin
            if(cnt_20ms == 1)begin
                flag <= 1;
                key_v <= key;
            end
            else begin
                flag <= 0;
                key_v <= key_v;
            end
        end
    end

    assign led = led_r;
endmodule