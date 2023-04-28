module AUTO_Buy (
    input   wire            clk         ,
    input   wire            rstn        ,
    input   wire    [3:0]   key         , 

    output  wire    [1:0]   sel_0       ,
    output  wire    [5:0]   sel         ,
    output  wire    [7:0]   seg   
);

    wire    [3:0]    key_out     ;
    wire             flag        ;
    wire             flag_20ns   ;
    wire             flag_2s     ;
    wire             flag_charge ;

    parameter   MAX_500ms   =   25'd2500_0000   ,
                MAX_20NS    =   10'd999         ,
                MAX_2s      =   2'd2            ,
                MAX_1s      =   26'd4999_9999   ;

key_unbounce u_key_unbounce(
    .rstn    (rstn),
    .clk     (clk),
    .key     (key),
    .key_out (key_out)
);

regshow u_regshow(
    .clk         (clk),
    .rstn        (rstn),
    .key         (key_out),
    .flag        (flag),
    .flag_20ns   (flag_20ns),
    .flag_2s     (flag_2s), 
    .flag_charge (flag_charge),
    .sel_0       (sel_0),
    .sel         (sel),
    .seg         (seg)
);

time_count #(
    .MAX_500ms(MAX_500ms),
    .MAX_20NS(MAX_20NS),
    .MAX_1s(MAX_1s),
    .MAX_2s(MAX_2s)
) u_time_count(
    .clk         (clk),
    .rstn        (rstn),
    .flag_charge (flag_charge),
    .flag_20ns   (flag_20ns),
    .flag_2s     (flag_2s),
    .flag        (flag)
);

endmodule //AUTO_Buy