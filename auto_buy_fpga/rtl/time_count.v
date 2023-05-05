module time_count (
    input   wire        clk         ,
    input   wire        rstn        ,
    input   wire        flag_charge ,

    output  reg         flag_20ns   ,
    output  reg         flag_2s     ,
    output  reg         flag        
);

    
    parameter   MAX_500ms   =   25'd2500_0000   ,
                MAX_20NS    =   10'd999         ,
                MAX_2s      =   2'd2            ,
                MAX_1s      =   26'd4999_9999   ;

    reg     [24:0]      cnt_500ms   ;
    reg     [9:0]       cnt_20ns    ;
    reg     [1:0]       cnt_2s      ;
    reg     [25:0]      cnt         ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt <= 26'd0;
            flag <= 1'b0;
        end
        else if(cnt == MAX_1s) begin
            cnt <= 26'd0;
            flag <= 1'b1;
        end
        else begin
            cnt <= cnt + 1'd1;
            flag <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_500ms <= 25'd0;
        end
        else if(cnt_500ms == MAX_500ms - 1'd1) begin
            cnt_500ms <= 25'd0;
        end
        else begin
            cnt_500ms <= cnt_500ms + 1'd1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_20ns <= 10'd0;
            flag_20ns <= 1'b0;
        end
        else if(cnt_20ns == MAX_20NS) begin
            cnt_20ns <= 10'd0;
            flag_20ns <= 1'b1;
        end
        else begin
            cnt_20ns <= cnt_20ns + 1'd1;
            flag_20ns <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_2s <= 2'd0;
            flag_2s <= 1'b0;
        end
        else if(cnt_2s == MAX_2s) begin
            cnt_2s <= 2'd0;
            flag_2s <= 1'b1;
        end
        else if(cnt == MAX_1s && flag_charge) begin
            cnt_2s <= cnt_2s + 1'd1;
            flag_2s <= 1'b0;
        end
        else begin
            cnt_2s <= cnt_2s;
        end
    end

endmodule //time_count