library verilog;
use verilog.vl_types.all;
entity pwn is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        cnt_en          : in     vl_logic;
        counter_arr     : in     vl_logic_vector(31 downto 0);
        counter_ccr     : in     vl_logic_vector(31 downto 0);
        o_pwn           : out    vl_logic
    );
end pwn;
