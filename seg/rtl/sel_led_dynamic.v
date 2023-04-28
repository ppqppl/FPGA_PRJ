module sel_led_dynamic (
    input   wire            clk     ,
    input   wire            rstn    ,
    input   wire            flag    ,

    output  reg     [5:0]   sel     ,
    output  reg     [7:0]   seg
);

    reg     [2:0]   cstate  ;
    reg     [2:0]   nstate  ;
    reg     [2:0]   value   ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cstate <= 3'd0;
        end
        else begin
            cstate <= nstate;
        end
    end

    always @(*) begin
        case (cstate)
            3'd0 :  begin
                if(flag) begin
                    nstate = 3'd1;
                end
                else begin
                    nstate = 3'd0;
                end
            end
            3'd1 :  begin
                if(flag) begin
                    nstate = 3'd2;
                end
                else begin
                    nstate = 3'd1;
                end
            end
            3'd2 :  begin
                if(flag) begin
                    nstate = 3'd3;
                end
                else begin
                    nstate = 3'd2;
                end
            end
            3'd3 :  begin
                if(flag) begin
                    nstate = 3'd4;
                end
                else begin
                    nstate = 3'd3;
                end
            end
            3'd4 :  begin
                if(flag) begin
                    nstate = 3'd5;
                end
                else begin
                    nstate = 3'd4;
                end
            end
            3'd5 :  begin
                if(flag) begin
                    nstate = 3'd6;
                end
                else begin
                    nstate = 3'd5;
                end
            end
            default :   ;
        endcase
    end

    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn) begin
    //         sel <= 6'b111111;
    //     end
    //     else begin
    //         sel <= 6'b000000;
    //     end
    // end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            value = 3'd0;
            sel = 6'b111111;
        end
        else begin
            case(cstate)
                3'd0:   begin
                                sel = 6'b111_110;//选择最右边数码管。 sel低有效
                                value = 3'd1;
                        end
                3'd1:   begin
                                sel = 6'b111_101;
                                value = 3'd2;
                        end
                3'd2:   begin
                                sel = 6'b111_011;
                                value = 3'd3;
                        end
                3'd3:   begin
                                sel = 6'b110_111;
                                value = 3'd4;
                        end
                3'd4:   begin
                                sel = 6'b101_111;
                                value = 3'd5;
                        end
                3'd5:   begin
                                sel = 6'b011_111;
                                value = 3'd6;
                        end
            default:		begin//默认就第1种情况
                                sel = 6'b111_110;
                                value = 3'd1;
                            end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            seg = 8'b0000_0000;
        end
        else begin
            case (value)
                3'd1:       seg = 8'b11111001;//根据数码管真值表查找
                3'd2:       seg = 8'b10100100;
                3'd3:       seg = 8'b10110000;
                3'd4:       seg = 8'b10011001;
                3'd5:       seg = 8'b10010010;
                3'd6:       seg = 8'b10000010;
			    default :   seg = 8'b00000000;
            endcase
        end
    end


endmodule //sel_led_dynamic