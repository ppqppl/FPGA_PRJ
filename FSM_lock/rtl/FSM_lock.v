module FSM_lock (
    input       wire            clk     ,
    input       wire            rstn    ,
    input       wire    [3:0]   key_in  ,   // 稳定按键信号

    output      wire    [3:0]   led
);

    parameter Max_1s    =   26'd5000_0000;
    parameter Max_20ms  =   25'd2500_0000;

    // 空间状态

    parameter   IDLE    =   3'd0    ;
    parameter   S1      =   3'd1    ;
    parameter   S2      =   3'd2    ;
    parameter   S3      =   3'd3    ;
    parameter   OK      =   3'd4    ;
    parameter   Error   =   3'd5    ;

    // 动作空间
    parameter   lock        =   4'b1111 ;
    parameter   ublock      =   4'b0000 ;
    parameter   s1_led      =   4'b1110 ;
    parameter   s2_led      =   4'b1100 ;
    parameter   s3_led      =   4'b1000 ;
    parameter   s4_led      =   4'b0000 ;
    parameter   error_led   =   4'b0101 ;

    reg     [25:0]      cnt_1s      ;
    reg     [24:0]      cnt_20ms    ;
    reg     [2:0]       cstate      ;
    reg     [2:0]       nstate      ;
    reg     [3:0]       led_r       ;


    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cstate = IDLE;
        end
        else begin
            cstate = nstate;
        end
    end

    always @(*) begin
        case (cstate)
            IDLE: begin
                if(key_in[0]) begin
                    nstate = S1;
                end
                else if(key_in[1]||key_in[2]||key_in[3]) begin
                    nstate = Error;
                end
                else begin
                    nstate = IDLE;
                end
            end
            S1: begin
                if(key_in[1]) begin
                    nstate = S2;
                end
                else if(key_in[0]||key_in[2]||key_in[3]) begin
                    nstate = Error;
                end
                else begin
                    nstate = S1;
                end
            end
            S2: begin
                if(key_in[2]) begin
                    nstate = S3;
                end
                else if(key_in[0]||key_in[1]||key_in[3]) begin
                    nstate = Error;
                end
                else begin
                    nstate = S2;
                end
            end
            S3: begin
                if(key_in[3]) begin
                    nstate = OK;
                end
                else if(key_in[0]||key_in[1]||key_in[2]) begin
                    nstate = Error;
                end
                else begin
                    nstate = S3;
                end
            end
            OK: begin
                if(key_in[3]) begin
                    nstate = IDLE;
                end
                else begin
                    nstate = OK;
                end
            end
            Error: begin
                if(key_in[3]) begin
                    nstate = IDLE;
                end
                else begin
                    nstate = Error;
                end
            end
            default:    ;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            led_r <= lock;
        end
        else begin
            case (cstate)
                IDLE    :   led_r = lock        ;   
                S1      :   led_r = s1_led      ;
                S2      :   led_r = s2_led      ;
                S3      :   led_r = s3_led      ;
                OK      :   begin
                   led_r = ublock;
                end
                Error   :   led_r = error_led   ;
                default :   led_r = lock        ;
            endcase
        end
    end

    assign led = led_r;

endmodule //FSM_lock