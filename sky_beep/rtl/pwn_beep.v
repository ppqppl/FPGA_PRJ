module pwn_beep(clk,rst_n,beep);

	input clk;
	input rst_n;
	
	output beep;
	
	reg [31:0]counter_arr;
	wire [31:0]counter_ccr;
	
	reg [25:0]delay_cnt;
	reg [4:0]number;
	
	localparam 
		L1 = 191130,
		L2 = 170241,
		L3 = 151698,
		L4 = 143183,
		L5 = 127550,
		L6 = 113635,
		L7 = 101234;

	assign counter_ccr = counter_arr >> 1;
	
	pwn pwn1(
		.clk(clk),
		.rst_n(rst_n),
		.cnt_en(1'b1),
		.counter_arr(counter_arr),
		.counter_ccr(counter_ccr),
		.o_pwn(beep)
	);
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		delay_cnt <= 25'd0;
	else if(delay_cnt == 0)
		delay_cnt <= 25'd24999999;
	else 
		delay_cnt <= delay_cnt + 1'b1;
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		number <= 5'd0;
	else if(delay_cnt == 0)
		begin
			if(number == 5'd7)
				number <= 5'd0;
			else 
				number <= number + 1'b1;		
		end 
	else 
		number <= number;
	
	always@(*)
		case(number)
			0:counter_arr = L1;
			1:counter_arr = L2;
			2:counter_arr = L3;
			3:counter_arr = L4;
			4:counter_arr = L5;
			5:counter_arr = L6;
			6:counter_arr = L7;
			default:counter_arr = L1;
		endcase
endmodule 