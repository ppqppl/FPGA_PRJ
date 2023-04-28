module lanterns(
	input 	wire 			clk,
	input 	wire 			rst_n,
	input 	wire [2:0] 	spec_flag,//音符
	
	output 	wire [6:0] 	lan_led 	//彩灯
);
 
 
reg [6:0] led_r;
 
//led工作
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		led_r<=7'b000_0000;
	else
		case(spec_flag)
			3'd1: led_r<=7'b000_0001;
			3'd2: led_r<=7'b000_0010;
			3'd3: led_r<=7'b000_0100;
			3'd4: led_r<=7'b000_1000;
			3'd5: led_r<=7'b001_0000;
			3'd6: led_r<=7'b010_0000;
			3'd7: led_r<=7'b100_0000;
			default:led_r<=7'b000_0000;
		endcase
	
end
assign lan_led=led_r;
 
endmodule
 