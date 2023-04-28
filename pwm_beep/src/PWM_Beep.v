module beep_music(

	input wire clk,
	input wire rst_n,
	
	output reg beep

);
	parameter CLK_FRE   = 50 ;

	reg [31:0]cnt;

	wire [19:0]duty_data;
	
	reg [7:0]address;
	wire [7:0]time_music;
	reg [31:0]time_cycle;

	wire [7:0]hz_sel;
	
	wire [19:0]cycle;
	reg [19:0]cnt_cycle;

	time_music time_music0(
		.address(address),
		.clock(clk),
		.q(time_music)
	);
	
	hz_sel hz_sel0(
		.address(address),
		.clock(clk),
		.q(hz_sel)
	);
	
	hz hz0(
		.hz_sel(hz_sel),
		.cycle(cycle)
	);


	
	//单个音符时间计数值
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		time_cycle<=32'd0;
	else
		time_cycle<=time_music*(CLK_FRE*1000000/8) ;
	
	//计时器
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt<=1'b0;
	else if(cnt==time_cycle)
		cnt<=1'b0;
	else
		cnt<=cnt+1'b1;
	
	//频率rom计数器加一
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		address<=1'b0;
	else if(address==8'd111 && cnt==time_cycle)
		address<=1'b0;
	else if(cnt==time_cycle)
		address<=address+1'b1;
		
	//频率计数器
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt_cycle<=1'b0;
	else if(cnt_cycle==cycle || cnt==time_cycle)
		cnt_cycle<=1'b0;
	else
		cnt_cycle<=cnt_cycle+1'b1;
		
	//占空比
	assign duty_data=cycle/4;
	
	//蜂鸣器输出PWM
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		beep=1'b0;
	else if(cnt_cycle>=duty_data)
		beep=1'b1;
	else
		beep=1'b0;

endmodule 