`define g3 SW[15:12]
`define g2 SW[11:8]
`define g1 SW[7:4]
`define g0 SW[3:0]
`define A3 answer[15:12]
`define A2 answer[11:8]
`define A1 answer[7:4]
`define A0 answer[3:0]

module guess(clk, rst, SW, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, KEY, LEDR, state, pass_guess, A_cnt, guess_cnt,B_cnt);
	input clk;									
	input rst;
	input [17:0]SW;
	input [3:0] KEY;
	output reg [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [17:0] LEDR;	
	reg [15:0] answer;	
	
	output reg [1:0] state;
	reg [1:0] nextstate;
	parameter [1:0] SET   = 2'd0;
	parameter [1:0] WAIT  = 2'd1;
	parameter [1:0] GUESS = 2'd2;
	parameter [1:0] END 	 = 2'd3;
	
	//output KEY_3;
	output pass_guess;
	output reg [17:0] guess_cnt;
	reg [6:0] seg7_run_cycle;
	output reg [3:0] A_cnt;
	output reg [3:0] B_cnt;
	assign pass_guess = (A_cnt == 4'd4);
	wire clk18;
	//assign clk18 = clk;
	counterDivider #(22, 50000000/18) cntD(clk, rst, clk18);
	KEY_Debounce d2(clk18, rst, KEY[3], KEY_3);
   
	
	
//	//========<測試>========
//	assign LEDR[0] = KEY[3];
//	assign LEDR[1] = clk18;
//	//=====================
	
	always @(posedge clk18, negedge rst)begin
		if(!rst)begin
			state <= SET;
		end
		else begin
			state <= nextstate;
		end
	end
	integer x;
	always @(*)begin
		case(state)
			SET:begin
				A_cnt = 4'd0;
				B_cnt = 4'd0;
				if(KEY[3] &&(`g3 !=`g2 && `g3 != `g1 && `g3 != `g0 && `g2 !=`g1 && `g2 != `g0 && `g1 != `g0))begin
					`A3 = `g3;
					`A2 = `g2;
					`A1 = `g1;
					`A0 = `g0;
					nextstate = WAIT;
				end
				else begin
					`A3 = 4'd0;
					`A2 = 4'd0;
					`A1 = 4'd0;
					`A0 = 4'd0;
					nextstate = SET;
				end
			end
			WAIT:begin
				A_cnt = 4'd0;
				B_cnt = 4'd0;
				if(KEY[3])begin
					if(|SW[15:0])begin
						`A3 = `A3;
						`A2 = `A2;
						`A1 = `A1;
						`A0 = `A0;
						nextstate = WAIT;
					end
					else begin
						`A3 = `A3;
						`A2 = `A2;
						`A1 = `A1;
						`A0 = `A0;
						nextstate = GUESS;
					end
				end
				else begin
					`A3 = `A3;
					`A2 = `A2;
					`A1 = `A1;
					`A0 = `A0;
					nextstate = WAIT;
				end
			end
			GUESS:begin
				if(guess_cnt <= 18'b01_1111_1111_1111_1111)begin
					if(KEY[3] && (`g3 !=`g2 && `g3 != `g1 && `g3 != `g0 && `g2 !=`g1 && `g2 != `g0 && `g1 != `g0))begin
						`A3 = `A3;
						`A2 = `A2;
						`A1 = `A1;
						`A0 = `A0;
						A_cnt = 4'd0;
						B_cnt = 4'd0;
						A_cnt = A_cnt + (`A3 == `g3) + (`A2 == `g2) + (`A1 == `g1) + (`A0 == `g0);	
						if(`g3 == `A2 || `g3 == `A1 || `g3 ==`A0)begin
							B_cnt = B_cnt + + 1;
						end
						if(`g2 == `A3 || `g2 == `A1 || `g2 ==`A0)begin
							B_cnt = B_cnt + + 1;
						end
						if(`g1 == `A3 || `g1 == `A2 || `g1 ==`A0)begin
							B_cnt = B_cnt + + 1;
						end
						if(`g0 == `A3 || `g0 == `A2 || `g0 ==`A1)begin
							B_cnt = B_cnt + + 1;
						end
						if(A_cnt == 4'd4)begin
							nextstate = END;
						end
						else begin
							nextstate = GUESS;
						end
					end
					else begin
						`A3 = `A3;
						`A2 = `A2;
						`A1 = `A1;
						`A0 = `A0;
						A_cnt = A_cnt;
						B_cnt = B_cnt;
						nextstate = GUESS;
					end
				end
				else begin
					`A3 = `A3;
					`A2 = `A2;
					`A1 = `A1;
					`A0 = `A0;
					A_cnt = A_cnt;
					B_cnt = B_cnt;
					nextstate = END;
				end
			end
			END:begin
				`A3 = 4'd0;
				`A2 = 4'd0;
				`A1 = 4'd0;
				`A0 = 4'd0;
				A_cnt = A_cnt;
				B_cnt = B_cnt;
				if(KEY[3] &&(|SW[15:0])==0)begin
					nextstate = SET;
				end
				else begin
					nextstate = END;
				end
			end
			default:begin
				A_cnt = 4'd0;
				B_cnt = 4'd0;
				`A3 = 4'd0;
				`A2 = 4'd0;
				`A1 = 4'd0;
				`A0 = 4'd0;
				nextstate = SET;
			end
		endcase
	end
	
	always @(posedge clk18, negedge rst)begin
		if(!rst)begin
			guess_cnt <= 18'd0;
		end
		else begin
			if(state == GUESS)begin
				if(guess_cnt <= 18'b01_1111_1111_1111_1111)begin
					if(`g3 !=`g2 && `g3 != `g1 && `g3 != `g0 && `g2 !=`g1 && `g2 != `g0 && `g1 != `g0)begin
						guess_cnt <= {guess_cnt[16:0],{1'b1}};
					end
					else begin
						guess_cnt <= guess_cnt;
					end
				end
				else begin
					guess_cnt <= guess_cnt;
				end
			end
			else begin
				guess_cnt <= 18'd0;
			end
		end
	end
	always @(posedge clk18, negedge rst)begin
		if(!rst)begin
			{HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b111_1111;
			{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= 7'b111_1111;
			{HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b111_1111;
			{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= 7'b111_1111;
			{HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b111_1111;
			{HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b111_1111;
			{HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b111_1111;
			{HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b111_1111;
		end
		else begin
			case(state)
				SET:begin
					{HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b111_1111;
					{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= 7'b111_1111;
					{HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b111_1111;
					{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= 7'b111_1111;
					case(SW[15:12])
						4'h0 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0000001;
						4'h1 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1001111;
						4'h2 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0010010;
						4'h3 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0000110;
						4'h4 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1001100;
						4'h5 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0100100;
						4'h6 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1100000;
						4'h7 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0001111;
						4'h8 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0000000;
						4'h9 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0001100;
						4'ha : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0001000;
						4'hb : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1100000;
						4'hc : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0110001;
						4'hd : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1000010;
						4'he : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0110000;
						4'hf : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0111000;
					endcase
					case(SW[11:8])
						4'h0 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0000001;
						4'h1 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1001111;
						4'h2 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0010010;
						4'h3 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0000110;
						4'h4 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1001100;
						4'h5 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0100100;
						4'h6 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1100000;
						4'h7 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0001111;
						4'h8 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0000000;
						4'h9 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0001100;
						4'ha : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0001000;
						4'hb : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1100000;
						4'hc : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0110001;
						4'hd : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1000010;
						4'he : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0110000;
						4'hf : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0111000;
					endcase
					case(SW[7:4])
						4'h0 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0000001;
						4'h1 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1001111;
						4'h2 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0010010;
						4'h3 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0000110;
						4'h4 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1001100;
						4'h5 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0100100;
						4'h6 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1100000;
						4'h7 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0001111;
						4'h8 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0000000;
						4'h9 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0001100;
						4'ha : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0001000;
						4'hb : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1100000;
						4'hc : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0110001;
						4'hd : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1000010;
						4'he : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0110000;
						4'hf : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0111000;
					endcase
					case(SW[3:0])
						4'h0 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0000001;
						4'h1 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1001111;
						4'h2 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0010010;
						4'h3 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0000110;
						4'h4 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1001100;
						4'h5 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0100100;
						4'h6 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1100000;
						4'h7 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0001111;
						4'h8 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0000000;
						4'h9 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0001100;
						4'ha : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0001000;
						4'hb : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1100000;
						4'hc : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0110001;
						4'hd : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1000010;
						4'he : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0110000;
						4'hf : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0111000;
					endcase
				end
				WAIT:begin
					{HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b111_1111;
					{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= 7'b111_1111;
					{HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b111_1111;
					{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= 7'b111_1111;
					{HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= seg7_run_cycle ;
					{HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= seg7_run_cycle ;
					{HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= seg7_run_cycle ;
					{HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= seg7_run_cycle ;
				end
				GUESS:begin
					case(SW[15:12])
						4'h0 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0000001;
						4'h1 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1001111;
						4'h2 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0010010;
						4'h3 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0000110;
						4'h4 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1001100;
						4'h5 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0100100;
						4'h6 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1100000;
						4'h7 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0001111;
						4'h8 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0000000;
						4'h9 : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0001100;
						4'ha : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0001000;
						4'hb : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1100000;
						4'hc : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0110001;
						4'hd : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1000010;
						4'he : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0110000;
						4'hf : {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0111000;
					endcase
					case(SW[11:8])
						4'h0 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0000001;
						4'h1 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1001111;
						4'h2 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0010010;
						4'h3 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0000110;
						4'h4 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1001100;
						4'h5 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0100100;
						4'h6 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1100000;
						4'h7 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0001111;
						4'h8 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0000000;
						4'h9 : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0001100;
						4'ha : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0001000;
						4'hb : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1100000;
						4'hc : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0110001;
						4'hd : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b1000010;
						4'he : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0110000;
						4'hf : {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0111000;
					endcase
					case(SW[7:4])
						4'h0 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0000001;
						4'h1 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1001111;
						4'h2 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0010010;
						4'h3 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0000110;
						4'h4 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1001100;
						4'h5 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0100100;
						4'h6 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1100000;
						4'h7 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0001111;
						4'h8 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0000000;
						4'h9 : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0001100;
						4'ha : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0001000;
						4'hb : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1100000;
						4'hc : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0110001;
						4'hd : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b1000010;
						4'he : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0110000;
						4'hf : {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0111000;
					endcase
					case(SW[3:0])
						4'h0 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0000001;
						4'h1 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1001111;
						4'h2 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0010010;
						4'h3 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0000110;
						4'h4 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1001100;
						4'h5 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0100100;
						4'h6 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1100000;
						4'h7 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0001111;
						4'h8 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0000000;
						4'h9 : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0001100;
						4'ha : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0001000;
						4'hb : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1100000;
						4'hc : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0110001;
						4'hd : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b1000010;
						4'he : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0110000;
						4'hf : {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0111000;
					endcase
					if(KEY[3])begin
						if(`g3 !=`g2 && `g3 != `g1 && `g3 != `g0 && `g2 !=`g1 && `g2 != `g0 && `g1 != `g0)begin
							case(A_cnt[3:0])
								4'h0 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0000001;
								4'h1 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b1001111;
								4'h2 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0010010;
								4'h3 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0000110;
								4'h4 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b1001100;
								4'h5 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0100100;
								4'h6 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b1100000;
								4'h7 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0001111;
								4'h8 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0000000;
								4'h9 : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0001100;
								4'ha : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0001000;
								4'hb : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b1100000;
								4'hc : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0110001;
								4'hd : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b1000010;
								4'he : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0110000;
								4'hf : {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= 7'b0111000;
							endcase
							{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= 7'b0001000;
							case(B_cnt[3:0])
								4'h0 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0000001;
								4'h1 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b1001111;
								4'h2 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0010010;
								4'h3 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0000110;
								4'h4 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b1001100;
								4'h5 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0100100;
								4'h6 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b1100000;
								4'h7 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0001111;
								4'h8 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0000000;
								4'h9 : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0001100;
								4'ha : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0001000;
								4'hb : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b1100000;
								4'hc : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0110001;
								4'hd : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b1000010;
								4'he : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0110000;
								4'hf : {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= 7'b0111000;
							endcase
							{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= 7'b1100000;
						end
						else begin
							{HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]};
							{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= {HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]};
							{HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]};
							{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= {HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]};
						end
					end
					else begin
						{HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]};
						{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= {HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]};
						{HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]};
						{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= {HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]};
					end
				end
				END:begin
					{HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= seg7_run_cycle;
					{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= seg7_run_cycle;
					{HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= seg7_run_cycle;
					{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= seg7_run_cycle;
					if(pass_guess)begin
						{HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b0011000;
						{HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0001000;
						{HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0100100;
						{HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0100100;
					end
					else begin
						{HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= 7'b1110001;
						{HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= 7'b0000001;
						{HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= 7'b0100100;
						{HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= 7'b0100100;
					end
				end
				default:begin
					{HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]} <= {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]};
					{HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]} <= {HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]};
					{HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]} <= {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]};
					{HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]} <= {HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]};
					{HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} <= {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]};
					{HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} <= {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]};
					{HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} <= {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]};
					{HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} <= {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]};
				end
			endcase
		end
	end
	
	always @(posedge clk18, negedge rst)begin
		if(!rst)begin
			seg7_run_cycle <= 7'b0111111;
		end
		else begin
			if(state == WAIT)begin
				if(seg7_run_cycle == 7'b1111101)begin
					seg7_run_cycle <= 7'b0111111;
				end
				else begin
					seg7_run_cycle <= {1'b1,seg7_run_cycle[6:1]};
				end
			end
			else if(state == END)begin
				if(seg7_run_cycle == 7'b1111101)begin
					seg7_run_cycle <= 7'b0111111;
				end
				else begin
					seg7_run_cycle <= {1'b1,seg7_run_cycle[6:1]};
				end
			end
			else begin
				seg7_run_cycle <= 7'b0111111;
			end
		end
	end
endmodule 
//==============<防彈跳>==================
module KEY_Debounce(CLK, RST, KEY_In, KEY_Out); 
	parameter DeB_Num = 4; 		// 取樣次數
	parameter DeB_SET = 4'b0000; // 設置
	parameter DeB_RST = 4'b1111; // 重置 

	input CLK, RST;
	input KEY_In;
	output KEY_Out; 
	reg rKEY_Out = 1'b1;
	reg [DeB_Num-1:0] Bounce = 4'b1111; // 初始化 
	integer i;
	always @(posedge CLK or negedge RST) begin // 一次約200Hz 5ms
		if(!RST)begin
			Bounce <= DeB_RST; // Bounce重置
		end
		else begin // 取樣4次
			Bounce[0] <= KEY_In;
			for(i=0;i<DeB_Num-1;i=i+1)begin
				Bounce[i+1] <= Bounce[i];
			end
		end
		case(Bounce)
			DeB_SET: rKEY_Out = 1'b0;
			default: rKEY_Out = 1'b1;
		endcase
	end 
	
	assign KEY_Out = rKEY_Out; 
	
endmodule 

//===============<除頻器>=====================
module counterDivider(CLK, RST, CLK_Out); 

    // 除頻設定 1kHz 1ms
	parameter size = 16;
	parameter countDivider = 16'd1_000;
	localparam countDivider_D2  = countDivider / 2;

	input CLK, RST;
	output reg CLK_Out;

	reg [size-1:0] Cnt = 0;

	always @(posedge CLK or negedge RST) begin
		if(!RST) begin
			Cnt <= 0;
			CLK_Out <= 0;
		end 
		else if(Cnt == countDivider_D2) begin
			Cnt <= 0;
			CLK_Out <= ~CLK_Out;
		end 
		else begin
			Cnt <= Cnt + 1'b1;
		end
	end
	
endmodule 