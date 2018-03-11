
module regfile(input clk,
               input we,                 // write enable
               input [2:0] ra1, ra2, wa, // read/write addr
               input [3:0] wd,           // write data
               output [3:0] rd1, rd2);         // read data
               
reg [3:0] register [7:0];
integer i;
    
initial begin
    for(i = 0; i < 8; i = i + 1) register[i] = 0;
end

always @(posedge clk)
    if(we) register[wa] <= wd;
    
assign rd1 = register[ra1];
assign rd2 = register[ra2];

endmodule
