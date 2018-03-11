
module condlogic(input       clk,
                 input [3:0] Cond,
                 input [3:0] ALUFlags,
                 input       FlagsW,
                 input       RegW, MemW,
                 input       PCS,
                 output      PCSrc, RegWrite, MemWrite);

wire CondEx;

reg [3:0] Flags;

assign CondEx = condcheck(Cond, Flags);

assign RegWrite = RegW /*& CondEx*/;
assign MemWrite = MemW /*& CondEx*/;
assign PCSrc = PCS & CondEx;

always @(posedge clk)
    if(FlagsW) Flags <= ALUFlags;

// ==================================================================
function condcheck;
input [3:0] Cond;
input [3:0] Flags;
reg neg, zero, carry, overflow, ge;
begin
    {neg, zero, carry, overflow} = Flags;
    ge = (neg == overflow);
    case(Cond)
        4'b0000: condcheck = zero;
        4'b1000: condcheck = ~zero;
        4'b0001: condcheck = overflow;
        4'b1001: condcheck = ~overflow;
        4'b0010: condcheck = ~zero & ~(neg ^ overflow); // greater (signed)
        4'b1010: condcheck = (zero == 0 || neg != overflow); // less or equal(signed)
        4'b0011: condcheck = ge;
        4'b1011: condcheck = neg != overflow; // less(signed)
        4'b0100: condcheck = ~(carry | zero); // above (unsigned)
        4'b1100: condcheck = carry | zero; // below or equal
        4'b0101: condcheck = ~carry; // AE
        4'b1101: condcheck = carry;
        4'b0110: condcheck = neg;
        4'b1110: condcheck = ~neg;
        default: condcheck = 1;
    endcase
end
endfunction

endmodule
