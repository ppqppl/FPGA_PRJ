module  prj7620_beep_seg
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	
	output  reg  	[3:0]	flag		,
	output	wire			scl			,
	output	wire	[3:0]	led			,
	output	wire	[7:0]	dig			,
	output	wire	[5:0]	sel			,
	output	wire			beep		,
	
	inout	wire			sda	
);

wire	[7:0]	data		;
reg 	[3:0]	data_1		;
wire 	[3:0]	pedge		;

// always@(posedge sys_clk or negedge sys_rst_n)
// 	if(sys_rst_n == 1'b0)
// 		flag  <=  4'b0000  ;
// 	else  if(data[3:0] == 4'b0001)
// 		flag  <=  4'b0001  ;
// 	else  if(data[3:0] == 4'b0010)
// 		flag  <=  4'b0010  ;
// 	else  if(data[3:0] == 4'b0100)
// 		flag  <=  4'b0100  ;
// 	else  if(data[3:0] == 4'b1000)
// 		flag  <=  4'b1000  ;
// 	else
// 		flag  <=  flag  ;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		data_1 <= 4'b0000;
	end
	else begin
		data_1 <= data;
	end
end

assign pedge = data & ~data_1;
assign flag_hand = flag;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		flag <= 4'b0000;
	end
	else begin
		case (pedge)
			4'b0001: flag <= 4'b0001;
			4'b0010: flag <= 4'b0010;
			4'b0100: flag <= 4'b0100;
			4'b1000: flag <= 4'b1000;
			default : flag <= 4'b0000;
		endcase
	end
end

beep  beep_inst
(
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
	.flag		(flag[1:0]	),
	.beep		(beep		)
);

paj7620_top  paj7620_top_inst
(
	.sys_clk	(sys_clk	)	,
	.sys_rst_n	(sys_rst_n	)	,
	.scl		(scl		)	,
	.led		(led		)	,
	.data		(data		)	,
	.sda	    (sda	    )
);

seg_dynamic  seg_dynamic_inst
(
	.sys_clk	(sys_clk	)	,
	.sys_rst_n	(sys_rst_n	)	,
	.flag		(flag[3:2]	)	,
	.dig		(dig		)	,
	.sel	    (sel	    )
);

endmodule