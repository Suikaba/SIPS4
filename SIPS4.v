module SIPS4 (
	input wire clk // 50MHz input clock
);
reg [3:0]ram_wdata;
reg [3:0]ram_waddr;
reg [3:0]ram_raddr;
wire [3:0]ram_rdata;
reg ram_wen;
RAM ram(
	.clock(clk),
	.data(ram_wdata),
	.rdaddress(ram_raddr),
	.wraddress(ram_waddr),
	.wren(ram_wen),
	.q(ram_rdata));
reg [3:0]PC;
wire [15:0]instruction;
ROM rom(.address(PC),.clock(clk),.q(instruction));

always @(posedge clk)begin

end
endmodule
