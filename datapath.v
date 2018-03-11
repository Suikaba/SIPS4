
module datapath(input clk,
                input [15:0] Inst,
                input        RegWrite, MemWrite, // todo: separete Mem from data path
                input        ALUSrc,
                input        PCSrc,
                input        PortWrite, // for OUT
                input  [3:0] ALUControl,
                input  [7:0] PortIn,
                output [3:0] ALUFlags,
                //output [3:0] ALUResult,
                //output [3:0] WriteData,
                output reg [3:0] PC,
                output [7:0] PortData); // 
                
wire [3:0] Src1, Src2;
wire [3:0] WriteData;
wire [3:0] WriteDataReg;
wire [3:0] RAMReadData;
wire [3:0] ALUResult;

reg RAMReadState;
reg [3:0] Port [1:0]; // LED Port. todo: separete from data path

initial begin
    PC = 0;
    RAMReadState = 0;
    Port[0] = 0;
    Port[1] = 0;
end

assign PortData = {Port[1], Port[0]};

regfile rf(.clk(clk), .we(RegWrite), .ra1(Inst[10:8]), .ra2(Inst[6:4]),
           .wa(Inst[3:1]), .wd(WriteDataReg),
           .rd1(Src1), .rd2(WriteData));

assign Src2 = ALUSrc ? Inst[7:4] : WriteData; // ALUSrc == 1 => Immediate

assign WriteDataReg = wr_data_reg(Inst[15:11], ALUResult, PC, RAMReadData, Src2, PortIn);

ALU alu(.op(ALUControl), .a(Src1), .b(Src2), .result(ALUResult), .flags(ALUFlags));

RAM ram(.clock(clk), .data(Src1), .rdaddress(Src2), .wraddress(Src2), .wren(MemWrite),
	    .q(RAMReadData));

always @(posedge clk) begin
    if(PortWrite) Port[Src2] = Src1;
    
    RAMReadState = (Inst[15:11] == 5'b10100) ^ RAMReadState;
    if(!RAMReadState) PC = PCSrc ? Src2 : PC + 4'h1;
end

// calc WriteDataReg
function [3:0] wr_data_reg;
input [4:0] Op;
input [3:0] ALURes, PC, RAMReadData;
input Src2;
input [7:0] PortIn;
casex(Inst[15:11])
    5'b0xxxx: wr_data_reg = ALUResult;
    5'b10010: wr_data_reg = PC + 4'h1;
    5'b10100: wr_data_reg = RAMReadData;
    5'b10110: wr_data_reg = Src2 ? PortIn[7:4] : PortIn[3:0];
    default:  wr_data_reg = 4'bxxxx;
endcase
endfunction


endmodule
