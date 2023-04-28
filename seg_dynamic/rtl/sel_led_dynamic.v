module sel_led_dynamic (
    input   wire            clk     ,
    input   wire            rstn    ,
    input   wire            flag    ,

    output  reg     [5:0]   sel     ,
    output  reg     [7:0]   seg
);

    reg     [3:0]   cstate  ;
    reg     [3:0]   nstate  ;
    reg     [3:0]   value   ;
    reg     [3:0]   number  ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cstate <= 4'd0;
        end
        else begin
            cstate <= nstate;
        end
    end

    always @(*) begin
        case (cstate)
            4'd0 :  begin
                if(flag) begin
                    nstate = 4'd1;
                end
                else begin
                    nstate = 4'd0;
                end
            end
            4'd1 :  begin
                if(flag) begin
                    nstate = 4'd2;
                end
                else begin
                    nstate = 4'd1;
                end
            end
            4'd2 :  begin
                if(flag) begin
                    nstate = 4'd3;
                end
                else begin
                    nstate = 4'd2;
                end
            end
            4'd3 :  begin
                if(flag) begin
                    nstate = 4'd4;
                end
                else begin
                    nstate = 4'd3;
                end
            end
            4'd4 :  begin
                if(flag) begin
                    nstate = 4'd5;
                end
                else begin
                    nstate = 4'd4;
                end
            end
            4'd5 :  begin
                if(flag) begin
                    nstate = 4'd6;
                end
                else begin
                    nstate = 4'd5;
                end
            end
            4'd6 :  begin
                if(flag) begin
                    nstate = 4'd7;
                end
                else begin
                    nstate = 4'd6;
                end
            end
            4'd7 :  begin
                if(flag) begin
                    nstate = 4'd8;
                end
                else begin
                    nstate = 4'd7;
                end
            end
            4'd8 :  begin
                if(flag) begin
                    nstate = 4'd9;
                end
                else begin
                    nstate = 4'd8;
                end
            end
            4'd9 :  begin
                if(flag) begin
                    nstate = 4'd10;
                end
                else begin
                    nstate = 4'd9;
                end
            end
            4'd10 :  begin
                if(flag) begin
                    nstate = 4'd11;
                end
                else begin
                    nstate = 4'd10;
                end
            end
            4'd11 :  begin
                if(flag) begin
                    nstate = 4'd12;
                end
                else begin
                    nstate = 4'd11;
                end
            end
            4'd12 :  begin
                if(flag) begin
                    nstate = 4'd13;
                end
                else begin
                    nstate = 4'd12;
                end
            end
            4'd13 :  begin
                if(flag) begin
                    nstate = 4'd14;
                end
                else begin
                    nstate = 4'd13;
                end
            end
            4'd14 :  begin
                if(flag) begin
                    nstate = 4'd0;
                end
                else begin
                    nstate = 4'd14;
                end
            end
            default :   ;
        endcase
    end

        //位选信号切换模块
    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            sel <= 6'b011111;//初始化第一个数码管亮
        end 
        else if(flag)begin
            sel <= {sel[0],sel[5:1]};//每隔20us进行位移操作
        end 
        else begin
            sel <= sel;//其他时间保持不变
        end 
    end 


    always @(*) begin
        if(!rstn) begin
            value = 3'd0;
        end
        else begin
            case(cstate)
                4'd0:   begin
                                value = 4'h1;
                        end
                4'd1:   begin
                                value = 4'h2;
                        end
                4'd2:   begin
                                value = 4'h3;
                        end
                4'd3:   begin
                                value = 4'h4;
                        end
                4'd4:   begin
                                value = 4'h5;
                        end
                4'd5:   begin
                                value = 4'h6;
                        end
                4'd6:   begin
                                value = 4'h7;
                        end
                4'd7:   begin
                                value = 4'h8;
                        end
                4'd8:   begin
                                value = 4'h9;
                        end
                4'd9:   begin
                                value = 4'ha;
                        end
                4'd10:   begin
                                value = 4'hb;
                        end
                4'd11:   begin
                                value = 4'hc;
                        end
                4'd12:   begin
                                value = 4'hd;
                        end
                4'd13:   begin
                                value = 4'he;
                        end
                4'd14:   begin
                                value = 4'hf;
                        end
            default:		begin//默认就第1种情况
                                value = 3'd1;
                            end
            endcase
        end
    end

    // always @(*) begin
    //     if(!rstn) begin
    //         seg = 8'b0000_0000;
    //     end
    //     else begin
    //         case (value)
    //             3'd1:       seg = 8'b11111001;//根据数码管真值表查找
    //             3'd2:       seg = 8'b10100100;
    //             3'd3:       seg = 8'b10110000;
    //             3'd4:       seg = 8'b10011001;
    //             3'd5:       seg = 8'b10010010;
    //             3'd6:       seg = 8'b10000010;
	// 		    default :   seg = 8'b00000000;
    //         endcase
    //     end
    // end

    always @(*)begin
        if(!rstn)
            seg <= 8'b0;
        else begin
            case(value)//匹配16进制数
                4'h0:       seg <= 8'b1100_0000;//匹配到后参考共阴极真值表
                4'h1:       seg <= 8'b1111_1001;
                4'h2:       seg <= 8'b1010_0100;
                4'h3:       seg <= 8'b1011_0000;
                4'h4:       seg <= 8'b1001_1001;
                4'h5:       seg <= 8'b1001_0010;
                4'h6:       seg <= 8'b1000_0010;
                4'h7:       seg <= 8'b1111_1000;
                4'h8:       seg <= 8'b1000_0000;
                4'h9:       seg <= 8'b1001_0000;
                4'ha:       seg <= 8'b1000_1000;
                4'hb:       seg <= 8'b1000_0011;
                4'hc:       seg <= 8'b1100_0110;
                4'hd:       seg <= 8'b1010_0001;
                4'he:       seg <= 8'b1000_0110;
                4'hf:       seg <= 8'b1000_1110;
                default :   seg <= 8'b1100_0000;
            endcase
        end
    end


endmodule //sel_led_dynamic