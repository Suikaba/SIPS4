
/**
* ALU Test Bench
*/

module ALU_test;
reg [3:0] a, b, op;
wire [3:0] result, flags;

parameter STEP = 1000;

ALU alu(.op(op), .a(a), .b(b), .result(result), .flags(flags));

integer i, j;
always begin
    // add test
    op <= 4'b0000;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    // sub test
    op <= 4'b0001;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    // and test
    op <= 4'b0010;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    // or test
    op <= 4'b0011;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    // xor test
    op <= 4'b0100;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    // lshift
    op <= 4'b1000;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    // logical rshift
    op <= 4'b1001;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    // arithmetic rshift
    op <= 4'b1010;
    for(i = 0; i < 256; i = i + 1)
        #STEP {a, b} <= i;
    
    $finish;
end

initial begin
    a <= 4'h0;
    b <= 4'h0;
    op <= 4'h0;
    i <= 0;
    j <= 0;
end

endmodule
