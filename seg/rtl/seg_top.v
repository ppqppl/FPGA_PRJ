module SEG (
    input   wire    clk     ,
    input   wire    rstn    ,

    output  wire    [7:0]   sel     ,
    output  wire    [7:0]   seg
);
    parameter   MAX_500ms   =   25'd2500_0000;

    wire     flag_time    ;

    time_count #(.MAX_500ms(MAX_500ms)) u_time_count(
        .clk    (clk)       ,
        .rstn   (rstn)      ,
        .flag   (flag_time) 
    );
    segshow u_segshow(
        .clk     (clk)          ,
        .rstn    (rstn)         ,  
        .flag    (flag_time)    , 
        .sel     (sel)          ,
        .seg     (seg)   
    );

endmodule //seg_top