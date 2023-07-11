module sky(
	input 		clk,
	input 		rst_n,
	
	output 		beep
);


	
	reg [31:0]counter_arr;
	wire [31:0]counter_ccr;
	
	reg [22:0]delay;
	
	reg [9:0]beat;
	
	parameter delay_max = 22'd349_9999;
	
	localparam 
		L1 = 191130,
		L2 = 170241,
		L3 = 151698,
		L4 = 143183,
		L5 = 127550,
		L6 = 113635,
		L7 = 101234,
		
		M1 = 95546,
		M2 = 85134,
		M3 = 75837,
		M4 = 71581,
		M5 = 63775,
		M6 = 56817,
		M7 = 50617,
		
		H1 = 47823,
		H2 = 42563,
		H3 = 37921,
		H4 = 35793,
		H5 = 31887,
		H6 = 27408,
		H7 = 25309;

	assign counter_ccr = counter_arr >> 1;
	
	pwn pwn1
	(
		.clk(clk),
		.rst_n(rst_n),
		.cnt_en(1'b1),
		.counter_arr(counter_arr),
		.counter_ccr(counter_ccr),
		.o_pwn(beep)
	);
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		delay <= 22'd0;
	else if (delay == 22'd0)
		delay <= delay_max;
	else 
		delay <= delay - 1'b1;
		
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		beat <= 10'd0;
	else if(delay == 0)
		begin
			if(beat == 10'd1023)
				beat <= 10'd0;
			else
				beat <= beat + 1'b1;
		end
	else 
		beat <= beat;
		
	always@(*)
		case(beat)
			
			// 如果你突然打了个喷嚏
			1,2,3,4,6,7,8,9,10,11,12,13,15,16,17,18,19,20:counter_arr = H1;
			21,22,23,24,25,26:counter_arr = M6;
			27,28,29,30:counter_arr = H1;
			// 那一定就是我在想你
			32,33:counter_arr = H1;
			34,35,36,37,38,39,40,41:counter_arr = M5;
			42,43,44,45:counter_arr = H2;
			46,47:counter_arr = M7;
			48,49,50,51,52,53:counter_arr = H1;
			54,55,56,57:counter_arr = M5;
			// 如果半夜被手机吵醒
			59,60:counter_arr = M5;
			61,62,64,65,66,67,68,69,70,71:counter_arr = H1;
			72,73,74,75:counter_arr = H3;
			76,77,78,79,80,81,82,83:counter_arr = H1;
			84,85,86,87:counter_arr = M6;
			// 啊那是因为我关心
			89,90,91,92:counter_arr = M6;
			93,94,95,96,97,98,99,100:counter_arr = M5;
			101,102,103,104:counter_arr = H2;
			105,106:counter_arr = M7;
			107,108,109,110,111,112:counter_arr = H1;
			// 常常想 你说的话是不是别有用心
			115,116,117,118:counter_arr = M3;
			119,120,121,122:counter_arr = M4;
			123,124,125,126,127,128,129,130:counter_arr = M5;
			131,132,133,134,135,136,137,138:counter_arr = H1;
			139,140,141,142,143,144,145,146:counter_arr = M7;
			147,148,149,150,151,152,153,154,155,156,157,158:counter_arr = M6;
			159,160,161,162:counter_arr = M5;
			163,164,165,166:counter_arr = M2;
			167,168,169,170,171,172,173,174:counter_arr = M4;
			175,176,177,178:counter_arr = M3;
			// 明明很想相信
			184,185,186,187,180,181,182,183:counter_arr = M1;
			188,189,190,191:counter_arr = M6;
			192,193:counter_arr = M7;
			194,195,196,197,198,199:counter_arr = M6;
			200,201,202,203:counter_arr = M5;
			// 却又忍不住怀疑
			205,206,207,208:counter_arr = M3;
			209,210,211,212:counter_arr = M4;
			213,214,215,216:counter_arr = M5;
			217,218,219,220:counter_arr = M6;
			222,221:counter_arr = M7;
			228,223,224,225,226,227:counter_arr = M6;
			232,229,230,231:counter_arr = M5;
			// 在你的心里
			241,234,235,236,237,238,239,240:counter_arr = M5;
			249,242,243,244,245,246,247,248,250,251,252,253:counter_arr = H1;
			254,255,256,257,258,259,260,261:counter_arr = M6;
			// 我是否就是唯一
			263,264,265,266:counter_arr = M6;
			267,268,269,270:counter_arr = M5;
			271,272,273,274,275,276,277,278:counter_arr = H2;
			279,280:counter_arr = M7;
			281,282,283,284,285,286,287,288:counter_arr = H1;
			// // 爱 就是有我常烦着你
			290,291,292,293:counter_arr = H3;
			294,295,296,297,298,299,300,301:counter_arr = H4;
			305,304,302,303:counter_arr = H3;
			312,313,306,307,308,309,310,311:counter_arr = H1;
			317,316,314,315:counter_arr = M6;
			320,321,318,319:counter_arr = M7;
			322,323:counter_arr = H1;
			324,325,326,327,328,329:counter_arr = H2;

			// Ho ~ baby
			
			// 情话多说一点 想我就多看一眼
			// 表现多一点点 让我能 真的看见 ( Come On. Come on)
			// Oh ~ Bye
			// 少说一点 想陪你不只一天
			// 多一点 让我 心甘情愿 ~~~爱你
			default:counter_arr = 0;
		endcase 
endmodule