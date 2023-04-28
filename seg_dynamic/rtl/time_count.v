module time_count (
    input   wire        clk     ,
    input   wire        rstn    ,

    output  reg         flag    
);

    
    parameter   MAX_500ms   =   25'd2500_0000;

    reg     [24:0]      cnt_500ms   ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_500ms <= 25'd0;
            flag <= 1'b0;
        end
        else if(cnt_500ms == MAX_500ms - 1'd1) begin
            cnt_500ms <= 25'd0;
            flag <= 1'b1;
        end
        else begin
            cnt_500ms <= cnt_500ms + 1'd1;
            flag <= 1'b0;
        end
    end


endmodule //time_count