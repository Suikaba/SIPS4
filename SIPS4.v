
module SIPS4 (
	input wire clk_base, // 50MHz input clock
	input wire [3:0] slide,
	input wire [1:0] button,
	output wire [7:0] LED // LED ouput
	);
    
wire [3:0] PC;
wire [15:0] instruction;

wire [3:0] ALUControl, ALUFlags/*, ALUResult*/;
wire ALUSrc, PCSrc;
wire RegWrite, MemWrite;
wire PortWrite;

wire [3:0] in [1:0];
wire [3:0] out [1:0]; // LED

assign in[0] = slide;
assign in[1] = {2'b0, ~button};

ROM rom(.address(PC), .clock(~clk_base), .q(instruction));

controller ctrl(.clk(clk_base), .Inst(instruction), .ALUFlags(ALUFlags),
                .ALUControl(ALUControl), .RegWrite(RegWrite), .MemWrite(MemWrite), .PCSrc(PCSrc),
                .ALUSrc(ALUSrc), .PortWrite(PortWrite));

datapath dp(.clk(clk_base), .Inst(instruction), .RegWrite(RegWrite), .MemWrite(MemWrite),
            .ALUSrc(ALUSrc), .PCSrc(PCSrc), .PortWrite(PortWrite), .ALUControl(ALUControl), .PortIn({in[1], in[0]}),
            .ALUFlags(ALUFlags), /*.ALUResult(ALUResult),*/ .PC(PC), .PortData({out[1], out[0]}));


assign LED = slide[0] ? {4'b0000, /*register[slide[3:1]],*/ PC} : {out[1], out[0]};

endmodule
