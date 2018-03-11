`timescale 100ps/100ps

module SIPS4_test();
reg        clk;
wire [7:0] LED;
reg  [3:0] slide;
reg  [1:0] button;

parameter STEP = 1000;

SIPS4 cpu(.clk_base(clk),.slide(slide),.button(button),.LED(LED));

always #(STEP/2)clk=~clk;
initial begin
	clk=0;
	slide=0;
	button=2'b11;
end

endmodule
