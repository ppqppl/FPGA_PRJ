module pwn_gen (
    input   wire        clk     ,
    input   wire        rstn    ,

    output  wire        pwm
);

    parameter   MAX300  =   24'd1500_0000   ;
    
    reg     [23:0]      cnt_300     ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_300 <= 24'd0;
        end
        else if(cnt_300 == MAX300 - 1'd1) begin
            cnt_300 <= 24'd0;
        end
        else begin
            cnt_300 <= cnt_300 + 1'd1;
        end
    end


endmodule //pwn_gen