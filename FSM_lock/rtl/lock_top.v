module lock_top (
    input   wire    clk     ,
    input   wire    rstn    ,
    input   wire    [3:0]   key,   // 稳定按键信号

    output  wire    [3:0]   led

);
    wire [3:0]  key_out;

FSM_lock (
    .clk            (clk),
    .rstn           (rstn),
    .key_in         (key_out),

    .led            (led)
);

key_debounce (
    .clk            (clk) ,
    .rstn           (rstn) , 
    .key            (key) , 

    .key_out        (key_out) 
);

endmodule //lock_top