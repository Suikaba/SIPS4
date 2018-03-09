module SIPS4 (
	input wire clk // 50MHz input clock
);
reg [3:0]ram_wdata,ram_waddr,ram_raddr;
wire [3:0]ram_rdata;
reg ram_wen;
RAM ram(
	.clock(clk),
	.data(ram_wdata),
	.rdaddress(ram_raddr),
	.wraddress(ram_waddr),
	.wren(ram_wen),
	.q(ram_rdata));
reg [3:0]PC;
wire [15:0]instruction;
ROM rom(.address(PC),.clock(clk),.q(instruction));

reg [3:0]register[0:7];
reg [4:0]flags;

wire [4:0]opcode;
assign opcode=instruction[15:11];
reg [3:0]src1,src2,dst;
reg taken;

wire [3:0]in[1:0];
reg [3:0]out[1:0];

reg ram_read_state;

initial begin
	ram_read_state=0;
	flags=0;
end

function branch;
	input [3:0]flags;
	input [3:0]cond;
	input neg;
	begin
		reg n,z,v,c;
		reg taken;
		{n,z,v,c}=flags;
		casex(cond)
			0:taken=z;
			1:taken=v;
			2:taken=~z&~(n^v);//Grater(signed)
			3:taken=~n^v;//GE
			4:taken=~(c|z);//Above(unsigned)
			5:taken=~c;//AE
			6:taken=n;
			default:taken=1;
		endcase
		branch=neg^taken;
	end
endfunction

always @(posedge clk)begin
	src1=register[instruction[10:8]];
	src2=instruction[0]?instruction[7:4]:register[instruction[6:4]];
	//JMP
	if(opcode[4:2]==3'b100)begin
		taken=opcode[0]^branch(flags,instruction[10:8],opcode[0]);
	end
	else taken=0;
	//MEM
	ram_wdata=src2;
	ram_wen=opcode==5'b10101;
	ram_raddr=src2;
	ram_waddr=src2;
	ram_read_state=opcode==5'b10100^ram_read_state;
	//ALU
	dst=0;
	casex(opcode)
		5'b0xxxx:register[instruction[3:1]]=dst;//ALU
		5'b10010:register[instruction[3:1]]=PC+1;//JAL
		5'b10100:register[instruction[3:1]]=ram_rdata;
		5'b10110:register[instruction[3:1]]=in[src2];
	endcase
	if(!ram_read_state)PC=taken?src2:PC+1;
end
endmodule
