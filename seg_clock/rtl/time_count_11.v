module time_count (
    input   wire            clk         ,
    input   wire            rstn        ,

    output  wire    [4:0]   hour        ,   // 时
    output  wire    [5:0]   min         ,   // 分
    output  wire    [5:0]   sec         ,   // 秒
    output  reg             flag_20ns   
);

    parameter   MAX_1S      =       26'd5000_0000,
                MAX_20NS    =       10'd999      ,
                MAX_1m      =       6'd60        ,
                MAX_1h      =       5'd24        ,
                MAX_DAY     =       17'd86400    ;

    reg     [25:0]      cnt_1s      ;
    reg     [5:0]       cnt         ;
    reg     [5:0]       cnt_1m      ;
    reg     [4:0]       cnt_1h      ;
    reg     [9:0]       cnt_20ns    ;
    reg     [16:0]      cnt_day     ;

// 秒
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_1s <= 26'd0;
        end
        else if(cnt_1s == MAX_1S - 1'd1) begin
            cnt_1s <= 26'd0;
        end
        else begin
            cnt_1s <= cnt_1s + 1'd1;
        end
    end
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt <= 6'd0;
        end
        else if(cnt == MAX_1m - 1'd1) begin
            cnt <= 6'd0;
        end
        else if(cnt_1s == MAX_1S - 1'd1) begin
            cnt <= cnt + 1;
        end
        else begin
            cnt <= cnt;
        end
    end

// 分

    always @(posedge clk or negedge rstn) begin
        if(rstn) begin
            cnt_1m = 6'd0;
        end
        else if(cnt == MAX_1m - 1'd1 && cnt_1m == MAX_1m - 1'd1 && cnt_1s == MAX_1S - 1'd1) begin
            cnt_1m = 6'd0;
        end
        else if(cnt == MAX_1m - 1'd1 && cnt_1s == MAX_1S - 1'd1) begin
            cnt_1m <= cnt_1m + 1'd1;
        end
        else begin
            cnt_1m <= cnt_1m;
        end
    end

// 时

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_day <= 17'd0;
        end
        else if(cnt_day == MAX_DAY - 1'd1 && cnt_1s == MAX_1S - 1'd1) begin
            cnt_day <= 17'd0;
        end
        else if(cnt_1s == MAX_1S - 1'd1) begin
            cnt_day <= cnt_day + 1'd1;
        end
        else begin
            cnt_day <= cnt_day;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_20ns <= 10'd0;
            flag_20ns <= 1'b0;
        end
        else if(cnt_20ns == MAX_20NS - 1'd1) begin
            cnt_20ns <= 10'd0;
            flag_20ns <= 1'b1;
        end
        else begin
            cnt_20ns <= cnt_20ns + 1'd1;
            flag_20ns <= 1'b0;
        end
    end

    assign hour = cnt_day / 12'd3600            ;
    assign min  = (cnt_day % 12'd3600) / 6'd60  ;
    assign sec  = cnt_day % 6'd60               ;
endmodule //time_count