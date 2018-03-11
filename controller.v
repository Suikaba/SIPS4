
module controller(input clk,
                  input [15:0] Inst,
                  input [3:0]  ALUFlags,
                  output       ALUSrc,
                  output [3:0] ALUControl,
                  output       RegWrite, MemWrite, /*MemtoReg,*/
                  output       PCSrc,
                  output       PortWrite);

wire PCS, RegW, MemW;
wire FlagsW;

wire [4:0] opcode;
assign opcode = Inst[15:11];

// Inst[0] == src2_mode
decoder dec(.Op(opcode), .Funct(Inst[0]), .Flags(ALUFlags), .FlagsW(FlagsW), .MemW(MemW), .RegW(RegW),
            .ALUControl(ALUControl), .PortWrite(PortWrite), .ALUSrc(ALUSrc), .PCS(PCS));
            

// Cond = {LSB of op, Src1}
condlogic cl(.clk(clk), .Cond({opcode[0], Inst[10:8]}), .ALUFlags(ALUFlags),
             .FlagsW(FlagsW), .RegW(RegW), .MemW(MemW), .PCS(PCS),
             .PCSrc(PCSrc), .RegWrite(RegWrite), .MemWrite(MemWrite));

endmodule
