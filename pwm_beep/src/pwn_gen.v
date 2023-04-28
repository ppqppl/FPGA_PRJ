module pwn_gen (
    input   wire        clk     ,
    input   wire        rstn    ,

    output  wire        pwm
);

    parameter   MAX300  =   24'd1500_0000   ;
    parameter   Notes   =   6'd44           ;
    parameter   DO  	= 16'd47750		    ;//1
    parameter   RE  	= 16'd42550		    ;//2
    parameter   MI  	= 16'd37900		    ;//3
    parameter   FA  	= 16'd37550		    ;//4
    parameter   SO  	= 16'd31850		    ;//5
    parameter   LA      = 16'd28400		    ;//6
    parameter   XI      = 16'd25400		    ;//7
    
    reg     [23:0]      cnt_300     ;
    reg     [5:0]       cnt_note    ;
    reg     [15:0]      cnt_freq    ;
    reg     [5:0]       lut_data    ;

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

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cnt_note <= 6'd0;
    end
    else if(cnt_note == Notes && cnt_300 == MAX300) begin
        cnt_note <= 6'd0;
    end
    else if(cnt_300 == MAX300) begin
        cnt_note <= cnt_note + 1'd1;
    end
    else begin
        cnt_note <= cnt_note;
    end
end


endmodule //pwn_gen