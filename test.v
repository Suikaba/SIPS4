`timescale 100ps/100ps
module test();
parameter STEP = 1000;
reg clk;
wire [7:0]LED;
reg [3:0]slide;
reg [1:0]button;
SIPS4 cpu(.clk(clk),.slide(slide),.button(button),.LED(LED));
always #(STEP/2)clk=~clk;
initial begin
	clk=0;
	slide=0;
	button=0;
end
endmodule
