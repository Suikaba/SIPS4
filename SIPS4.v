module SIPS4 (
	input wire clk_base, // 50MHz input clock
	input wire [3:0]slide,
	input wire [1:0]button,
	output wire [7:0]LED // LED ouput
	);

reg [24:0]cnt=0;
always@(posedge clk_base)cnt=cnt+1;
wire clk,locked;
assign clk=clk_base;

reg [3:0]ram_wdata,ram_waddr,ram_raddr;
wire [3:0]ram_rdata;
//reg clk;
//reg [31:0]cnt;
//initial cnt=0;
//always@(posedge clk_base)begin
//	if(cnt==2500000)begin
//		cnt=0;
//		clk=~clk;
//	end
//	else cnt=cnt+1;
//end
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
ROM rom(.address(PC),.clock(~clk),.q(instruction));

reg [3:0]register[0:7];
reg [3:0]flags;

wire [4:0]opcode;
assign opcode=instruction[15:11];
reg [3:0]src1,src2;
reg [3:0]dst;
wire [3:0]flags_out;
reg taken;

//ALU alu(.op(opcode[3:0]),.a(src1),.b(src2),.result(dst),.flags(flags_out));

wire [3:0]in[1:0];
reg [3:0]out[1:0];
assign in[0]=slide;
assign in[1]={2'b0,~button};
assign LED=slide[0]?{register[slide[3:1]],PC}:{out[1],out[0]};

reg ram_read_state;
integer i;


parameter OP_ADD = 4'b0000,
          OP_SUB = 4'b0001,
          OP_AND = 4'b0010,
          OP_OR = 4'b0011,
          OP_XOR = 4'b0100,
          OP_LSHIFT = 4'b1000,
          OP_RLOGISHIFT = 4'b1001,
          OP_RARISHIFT = 4'b1010;
// negative, zero, ovf, carry
parameter NF = 7, ZF = 6, VF = 5, CF = 4;


function [7:0] operate;
input [3:0] op;
input signed [3:0] a, b; // declared as signed for arithmetic rshift
begin
    if(op == OP_ADD || op == OP_SUB) begin
        operate[4:0] = op == OP_ADD ? {1'b0, a} + b : {1'b0, a} - b;
        operate[VF] = (a[3] ^ operate[3])
                      && (op[0] == 0 && a[3] == b[3] || op[0] == 1 && a[3] != b[3]);
    end
    else if(op == OP_AND) begin
        operate[3:0] = a & b;
        operate[VF:CF] = 0;
    end
    else if(op == OP_OR) begin
        operate[3:0] = a | b;
        operate[VF:CF] = 0;
    end
    else if(op == OP_XOR) begin
        operate[3:0] = a ^ b;
        operate[VF:CF] = 0;
    end
    else if(op == OP_LSHIFT) begin
        operate[3:0] = a << b;
        operate[VF] = a[3] ^ operate[3];
        if(b[3:2])
            operate[CF] = |a;
        else begin
            case(b) // F*ck
                0:       operate[CF] = 0;
                1:       operate[CF] = a[3];
                2:       operate[CF] = |a[3:2];
                3:       operate[CF] = |a[3:1];
                default: operate[CF] = 0; // ???
            endcase
        end
    end
    else if(op == OP_RLOGISHIFT) begin
        operate[3:0] = a >> b;
        operate[VF] = 0;
        if(b[3:2])
            operate[CF] = |a;
        else begin
            case(b)
                0:       operate[CF] = 0;
                1:       operate[CF] = a[0];
                2:       operate[CF] = |a[1:0];
                3:       operate[CF] = |a[2:0];
                default: operate[CF] = 0; // ???
            endcase
        end
    end
    else if(op == OP_RARISHIFT) begin
        operate[3:0] = a >>> b;
        operate[VF] = 0;
        if(b[3:2])
            operate[CF] = |a[2:0]; // exclude sign
        else begin
            case(b)
                0:       operate[CF] = 0;
                1:       operate[CF] = a[0];
                2:       operate[CF] = |a[1:0];
                3:       operate[CF] = |a[2:0];
                default: operate[CF] = 0; // ???
            endcase
        end
    end
    else // invalid op
        operate = 8'bxxxxxxxx;
        
    operate[NF:ZF] = {operate[3] == 1, operate[3:0] == 0};
end
endfunction



initial begin
	PC=4'b0000;
	ram_read_state=0;
	ram_wen=0;
	flags=0;
	out[0]=0;
	out[1]=0;
	for(i=0;i<8;i=i+1)register[i]=0;
	src1=0;
	src2=0;
	taken=0;
	ram_raddr=0;
end

function branch;
	input [3:0]flags;
	input [3:0]cond;
	input neg;
	begin:branch_scope
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
		taken = branch(flags, instruction[10:8], opcode[0]);
	end
	else taken=0;
	//MEM
	ram_wdata=src1;
	ram_wen=opcode==5'b10101;
	ram_raddr=src2;
	ram_waddr=src2;
	ram_read_state= (opcode == 5'b10100) ^ ram_read_state;
	if(opcode==5'b10111)out[src2]=src1;
	//ALU
	if(!opcode[4]){flags,dst}=operate(opcode[3:0],src1,src2);//flags_out;
	casex(opcode)
		5'b0xxxx:register[instruction[3:1]]=dst;//ALU
		5'b10010:register[instruction[3:1]]=PC+1;//JAL
		5'b10100:register[instruction[3:1]]=ram_rdata;
		5'b10110:register[instruction[3:1]]=in[src2];
	endcase
	if(!ram_read_state)PC=taken?src2:PC+1;
end

endmodule
