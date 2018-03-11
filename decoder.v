
module decoder(input [4:0]  Op,
               input Funct,
               input [3:0]  Flags,
               output       FlagsW,
               output       MemW, RegW,
               //output       MemtoReg,
               output [3:0] ALUControl,
               output       ALUSrc, PCS,
               output       PortWrite);
               
wire Branch, ALUOp;

assign Branch = (Op[4:2] == 3'b100);
assign ALUOp = !Op[4];
assign MemW = Op == 5'b10101;
assign RegW = Op[4] == 0         // ALU
              || Op == 5'b10010  // JAL
              || Op == 5'b10100  // LD
              || Op == 5'b10110; // IN
assign PortWrite = (Op == 5'b10111);
assign FlagsW = !Op[4]; // same as ALUOp
// assign MemtoReg = ;    

// Funct == Inst[0]
assign ALUSrc = Funct;

assign ALUControl = ALUOp ? Op[3:0] : 4'b1111; // nonop
    
assign PCS = Branch;

endmodule
