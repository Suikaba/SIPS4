/**
* 4bit ALU

* op(4) : add(0000), sub(0001), and(0010), or(0011), xor(0100)
*         lshift(1000), r logical shift(1001), r arith shift(1010)
* a(4), b(4) : input
* result(4)  : output
* flags(4)   : output, [N, Z, V, C]
*/

module ALU(input [3:0] op,
           input [3:0] a,
           input [3:0] b,
           output [3:0] result,
           output [3:0] flags);

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

assign {flags, result} = operate(op, a, b);

endmodule
