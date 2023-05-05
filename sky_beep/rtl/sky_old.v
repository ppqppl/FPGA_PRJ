//天空之城  简易音乐播放，方法比较笨

module sky(clk,rst_n,beep);

	input clk;
	input rst_n;
	
	output beep;
	
	reg [31:0]counter_arr;
	wire [31:0]counter_ccr;
	
	reg [22:0]delay;
	
	reg [9:0]beat;
	
	parameter delay_max = 23'd4_599_999;
	
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
		delay <= 23'd0;
	else if (delay == 23'd0)
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
			// 0,1,2,3:counter_arr = M6;
			// 4,5,6,7:counter_arr = M7;
			// 8,9,10,11,12,13,14,15,16,17:counter_arr = H1;
			// 18,19,20,21:counter_arr = M7;
			// 22,23,24,25,26,27,28,29:counter_arr = H1;
			// 30,31,32,33,34,35,36,37:counter_arr = H3;
			// 38,39,40,41,42,43,44,45,46,47,48,49:counter_arr = M7;
			// 61,62,63,64:counter_arr = M3;
			// 66,67,68,69:counter_arr = M3;
			// 70,71,72,73,74,75,76,77,78,79:counter_arr = M6;
			// 80,81,82,83:counter_arr = M5;
			// 84,85,86,87,88,89,90,91:counter_arr = M6;
			// 92,93,94,95,96,97,98,99:counter_arr = H1;
			// 100,101,102,103,104,105,106,107,108,109,110,111:counter_arr = M5;
			// 121,124,125,126:counter_arr = M3;
			// 128,129,130,131:counter_arr = M3;
			// 132,133,134,135,136,137,138,139,140,141:counter_arr = M4;
			// 142,143,144,145:counter_arr = M3;
			// 146,147,148,149:counter_arr = M4;
			// 150,151,152,153,154,155,156,157,158,159:counter_arr = H1;
			// 160,161,162,163,164,165,166,167,168,169,170,171:counter_arr = M3;
			// 180,181:counter_arr = H1;
			// 183,184:counter_arr = H1;
			// 186,187:counter_arr = H1;
			// 188,189,190,191,192,193,194,195,196,197:counter_arr = M7;
			// 198,199,200,201:counter_arr = M4;
			// 203,204,205,206,207,208,209:counter_arr = M4;
			// 210,211,212,213,214,215,216:counter_arr = M7;
			// 218,219,220,221,222,223,224,225,226,227,228,229:counter_arr = M7;
			
			// 242,243,244,245:counter_arr = M6;
			// 246,247,248,249:counter_arr = M7;
			// 250,251,252,253,254,255,256,257,258,259:counter_arr = H1;
			// 260,261,262,263:counter_arr = M7;
			// 264,265,266,267,268,269,270,271:counter_arr = H1;
			// 272,273,274,275,276,277,278,279:counter_arr = H3;
			// 280,281,282,283,284,285,286,287,288,289,290,291:counter_arr = M7;
			// 303,304,305,306:counter_arr = M3;
			// 308,309,310,311:counter_arr = M3;
			// 312,313,314,315,316,317,318,319,320,321,322,323:counter_arr = M6;
			// 324,325,326,327:counter_arr = M5;
			// 328,329,330,331,332,333,334,335:counter_arr = M6;
			// 336,337,338,339,340,341,342,343:counter_arr = H1;
			// 344,345,346,347,348,349,350,351,352,353,354,355:counter_arr = M5;
			// 372,373,374,375:counter_arr = M3;
			// 376,377,378,379,380,381,382,383:counter_arr = M4;
			// 384,385,386,387:counter_arr = H1;
			// 388,389,390,391,392,393,394,395,396,397,398,399:counter_arr = M7;
			// 400,401,402,403,404,405,406,407:counter_arr = H1;
			// 408,409:counter_arr = H2;
			// 411,412:counter_arr = H2;
			// 413,414,415:counter_arr = H3;
			// 416,417,418,419,420,421,422,423:counter_arr = H1;
			// 432,433,434,435,436,437:counter_arr = H1;
			// 438,439:counter_arr = M7;
			// 440,441,442,443:counter_arr = M6;
			// 445,446,447,448:counter_arr = M6;
			// 449,450,451,452,453,454,455:counter_arr = M7;
			// 456,457,458,459,460,461,462,463:counter_arr = M5;
			// 464,465,466,467,468,469,470,471,472,473,474,475:counter_arr = M6;
			// 486,487,488,489:counter_arr = H1;
			// 490,491,492,493:counter_arr = H2;
			// 494,495,496,497,498,499,500,501,502,503,504,505:counter_arr = H3;
			// 506,507,508,509:counter_arr = H2;
			// 510,511,512,513,514,515,516,517:counter_arr = H3;
			// 518,519,520,521,522,523,524,525:counter_arr = H5;
			// 526,527,528,529,530,531,532,533,534,535,536,537:counter_arr = H2;
			
			// 551,552,553,554:counter_arr = M5;
			// 556,557,558,559:counter_arr = M5;
			// 560,561,562,563,564,565,566,567,568,569,570,571:counter_arr = H1;
			// 572,573,574,575:counter_arr = M7;
			// 576,577,578,579,580,581,582,583:counter_arr = H1;
			// 584,585,586,587,588,589,590,591:counter_arr = H3;
			// 592,593,594,595,596,597,598,599,600,601,602,603:counter_arr = H3;
			
			// 618,619,620,621:counter_arr = M6;
			// 622,623,624,625:counter_arr = M7;
			// 626,627,628,629,630,631,632,633:counter_arr = H1;
			// 634,635,636,637,638,639,640,641:counter_arr = M7;
			// 642,643,644,645:counter_arr = H2;
			// 647,648,649,650:counter_arr = H2;
			// 651,652,653,654,655,656,657,658,659,660,661:counter_arr = H1;
			// 662,663,664,665,666,667,668,669,670,671,672,673:counter_arr = M5;
			
			// 682,683,684,685,686,687,688,689:counter_arr = H4;
			// 690,691,692,693,694,695,696,697:counter_arr = H3;
			// 698,699,700,701,702,703,704,705:counter_arr = H2;
			// 706,707,708,709,710,711,712,713:counter_arr = H1;
			// 714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,730,731,732,733,734,735,736,737:counter_arr = H3;
			
			// 750,751,752,753,754,755,756,757:counter_arr = H3;
			// 758,759,760,761,762,763,764,765,766,767,768,769:counter_arr = H6;
			// 774,775,776,777,778,779,780,781:counter_arr = H5;
			// 783,784,785,786,787,788,789:counter_arr = H5;
			// 790,791,792,793:counter_arr = H3;
			// 794,795,796,797:counter_arr = H2;
			// 798,799,800,801,802,803,804,805:counter_arr = H1;
			
			// 810,811,812,813:counter_arr = H1;
			// 814,815,816,817,818,819,820,821:counter_arr = H2;
			// 822,823,824,825:counter_arr = H1;
			// 826,827,828,829,830,831,832,833,834,835,836,837:counter_arr = H2;
			// 838,839,840,841,842,843,844,845:counter_arr = H5;
			// 846,847,848,849,850,851,852,853,854,855,856,857:counter_arr = H3;
			
			// 870,871,872,873,874,875,876,877:counter_arr = H3;
			// 878,879,880,881,882,883,884,885,886,887,888,889,902,903,904,905:counter_arr = H6;
			// 906,907,908,909,910,911,912,913,914,915,916,917,918,919,920,921:counter_arr = H5;
			// 922,923,924,925:counter_arr = H3;
			// 926,927,928,929:counter_arr = H2;
			// 930,931,932,933,934,935,936,937:counter_arr = H1;
			
			// 950,951,952,953:counter_arr = H1;
			// 954,955,956,957,958,959,960,961:counter_arr = H2;
			// 962,963,964,965:counter_arr = H1;
			// 966,967,968,969,970,971,972,973,974,975,976,977:counter_arr = H2;
			// 978,979,980,981,982,983,984,985:counter_arr = M7;
			// 986,987,988,989,990,991,992,993,994,995,996,997:counter_arr = M6;
/*********************爱你*******************************/			
			// 1,2,3,5,6,7,8,9,10,11,13,14,15,17,18:counter_arr = H1;
			// 19,20,21,22:counter_arr = M6;
			// 23,24,25:counter_arr = H1;
			// 27,28:counter_arr = H1;
			// 29,30,31,32,34,35,36,37:counter_arr = M5;
			// 36,37,38,39:counter_arr = H2;
			// 40,41:counter_arr = M7;
			// 42,43,44,45:counter_arr = H1;
			// 46,47:counter_arr = M5;

			1,2,3,4,6,7,8,9,10,11,12,13,15,16,17,18,19,20:counter_arr = H1;
			21,22,23,24,25,26:counter_arr = M6;
			27,28,29,30:counter_arr = H1;


			default:counter_arr = 0;
		endcase 
endmodule

/*			爱如火
			1,2:counter_arr = M3;
			3,4:counter_arr = M2;
			5,6,7,8:counter_arr = M3;
			10,11,12,14,15,16:counter_arr = M3;
			17,18,19:counter_arr = M2;
			20,21,22:counter_arr = M5;
			23,24,25,26:counter_arr = M3;

			29,30:counter_arr = M3;
			31,32:counter_arr = M2;
			33,34,35,36:counter_arr = M3;
			38,39,40,42,43,44:counter_arr = M3;
			45,46:counter_arr = M2;
			47,48,49,50:counter_arr = M1;
			50,52,53,54:counter_arr = M2;

			58,59:counter_arr = M3;
			60,61:counter_arr = M2;
			62,63,64,65:counter_arr = M3;
			67,68,69,71,72,73:counter_arr = M3;
			74,75:counter_arr = M2;
			76,77,78:counter_arr = M5;
			79,80,81,82:counter_arr = M3;

			85,86:counter_arr = H1;
			87,88,89,90:counter_arr = M7;
			91,92,93,94:counter_arr = M3;
			96,97:counter_arr = M3;
			98,99,100,101:counter_arr = M5;
			102,103:counter_arr = M3;
			104,105,106,107:counter_arr = M6;
			108,109,110,111:counter_arr = M5;
*/