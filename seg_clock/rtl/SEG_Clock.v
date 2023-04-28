module SEG_Clock (
    input   wire        clk     ,
    input   wire        rstn    ,

    output  wire [5:0]  sel     ,
    output  wire [7:0]  seg     
);

    parameter   MAX_1S      =       26'd5000_0000,
                MAX_20NS    =       10'd999        ,
                MAX_DAY     =       17'd86400    ;

    wire            flag        ;
    wire    [4:0]   hour_top        ;   // 时
    wire    [5:0]   min_top        ;   // 分
    wire    [5:0]   sec_top        ;   // 秒

    time_count #(
        .MAX_1S     (MAX_1S)    ,
        .MAX_20NS   (MAX_20NS)  ,
        .MAX_DAY    (MAX_DAY)
    ) u_time_count(
        .clk         (clk)      ,
        .rstn        (rstn)     ,
        .hour        (hour_top) ,   // 时
        .min         (min_top)  ,   // 分
        .sec         (sec_top)  ,   // 秒
        .flag_20ns   (flag)
    );

    segshow u_segshow(
        .clk         (clk)      ,
        .rstn        (rstn)     ,
        .flag_20ns   (flag)     ,  
        .hour        (hour_top) ,   // 时
        .min         (min_top)  ,   // 分
        .sec         (sec_top)  ,   // 秒
        .sel         (sel)      ,
        .seg         (seg)
);

endmodule //SEG_Clock