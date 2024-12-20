//2022_10_27 kerong
//arctan
module arctan(inx,iny,out);
input signed [31:0] inx,iny;

output reg signed [31:0] out;
reg signed [39:0] z;
reg signed [39:0] x_pos,y_pos;
reg signed [39:0] set_x,set_y;

reg signed [39:0] x_cpl,y_cpl;

wire signed [39:0] atan[0:37];
assign atan[0]=40'b00101101_00000000000000000000000000000000;	//arctan(1/2^0)
assign atan[1]=40'b00011010_10010000101001110011000110100110;	//arctan(1/2^1)
assign atan[2]=40'b00001110_00001001010001110100000001111101;	//arctan(1/2^2)
assign atan[3]=40'b00000111_00100000000000010001001001001001;	//arctan(1/2^3)
assign atan[4]=40'b00000011_10010011100010101010011001001100;	//arctan(1/2^4)
assign atan[5]=40'b00000001_11001010001101111001010011100101;	//arctan(1/2^5)
assign atan[6]=40'b00000000_11100101001010100001101010110001;	//arctan(1/2^6)
assign atan[7]=40'b00000000_01110010100101101101011110100001;	//arctan(1/2^7)
assign atan[8]=40'b00000000_00111001010010111010010100011011;	//arctan(1/2^8)
assign atan[9]=40'b00000000_00011100101001011101100110110111;	//arctan(1/2^9)
assign atan[10]=40'b00000000_00001110010100101110110111000000;	//arctan(1/2^10)
assign atan[11]=40'b00000000_00000111001010010111011011111101;	//arctan(1/2^11)
assign atan[12]=40'b00000000_00000011100101001011101110000010;	//arctan(1/2^12)
assign atan[13]=40'b00000000_00000001110010100101110111000001;	//arctan(1/2^13)
assign atan[14]=40'b00000000_00000000111001010010111011100000;	//arctan(1/2^14)
assign atan[15]=40'b00000000_00000000011100101001011101110000;	//arctan(1/2^15)
assign atan[16]=40'b00000000_00000000001110010100101110111000;	//arctan(1/2^16)
assign atan[17]=40'b00000000_00000000000111001010010111011100;	//arctan(1/2^17)
assign atan[18]=40'b00000000_00000000000011100101001011101110;	//arctan(1/2^18)
assign atan[19]=40'b00000000_00000000000001110010100101110111;	//arctan(1/2^19)
assign atan[20]=40'b00000000_00000000000000111001010010111011;	//arctan(1/2^20)
assign atan[21]=40'b00000000_00000000000000011100101001011101;	//arctan(1/2^21)
assign atan[22]=40'b00000000_00000000000000001110010100101110;	//arctan(1/2^22)
assign atan[23]=40'b00000000_00000000000000000111001010010111;	//arctan(1/2^23)
assign atan[24]=40'b00000000_00000000000000000011100101001011;	//arctan(1/2^24)
assign atan[25]=40'b00000000_00000000000000000001110010100101;	//arctan(1/2^25)
assign atan[26]=40'b00000000_00000000000000000000111001010010;	//arctan(1/2^26)
assign atan[27]=40'b00000000_00000000000000000000011100101001;	//arctan(1/2^27)
assign atan[28]=40'b00000000_00000000000000000000001110010100;	//arctan(1/2^28)
assign atan[29]=40'b00000000_00000000000000000000000111001010;	//arctan(1/2^29)
assign atan[30]=40'b00000000_00000000000000000000000011100101;	//arctan(1/2^30)
assign atan[31]=40'b00000000_00000000000000000000000001110010;	//arctan(1/2^31)
assign atan[32]=40'b00000000_00000000000000000000000000111001;	//arctan(1/2^32)
assign atan[33]=40'b00000000_00000000000000000000000000011100;	//arctan(1/2^33)
assign atan[34]=40'b00000000_00000000000000000000000000001110;	//arctan(1/2^34)
assign atan[35]=40'b00000000_00000000000000000000000000000111;	//arctan(1/2^35)
assign atan[36]=40'b00000000_00000000000000000000000000000011;	//arctan(1/2^36)
assign atan[37]=40'b00000000_00000000000000000000000000000001;	//arctan(1/2^37)

integer x;
always @(*)begin
	out  = 32'd0;
	y_pos = iny;
	x_pos = inx;
	z = 40'd0;
	out = 32'd0;
	//==========<fill bits to 40>==========
	if(inx[31]==0)begin
		x_pos = {inx[31],8'd0,inx[30:0]};
	end
	else begin
		x_pos = {inx[31],8'b1111_1111,inx[30:0]};
	end
	if(iny[31]==0)begin
		y_pos = {iny[31],8'd0,iny[30:0]};
	end
	else begin
		y_pos = {iny[31],8'b1111_1111,iny[30:0]};
	end
	//==========<cordic>==================
	for(x=0;x<38;x=x+1)begin
		//=====<tan data>==============
		if(x_pos[39]==0)begin
			set_x = x_pos >> x;
		end
		else begin
			x_cpl = ~x_pos;
			x_cpl = x_cpl >> x;
			set_x = ~x_cpl;
		end
		if(y_pos[39]==0)begin
			set_y = y_pos >> x;
		end
		else begin
			y_cpl = ~y_pos;
			y_cpl = y_cpl >> x;
			set_y = ~y_cpl;
		end 
		//=====<condition>==========
		if(y_pos>=0)begin
			x_pos = x_pos + set_y;
			y_pos = y_pos - set_x;
			z = z + atan[x];
		end
		else begin
			x_pos = x_pos - set_y;
			y_pos = y_pos + set_x;
			z = z - atan[x];
		end
	end
	//=========<out>==========
	out = z[39:8];
end

endmodule
