`timescale 1ns/1ps

module tb_ztj();
reg clk;
reg rst_n;
reg en;
wire[1:0] dout0;
wire[1:0] dout1;

initial clk = 1;
always #5 clk = ~clk;

initial begin
rst_n = 1'b0;
en = 1'b0;

#200;
rst_n = 1'b1;

#200;

en=1'b1;

#300;
$stop;



end


ztj t_ztj(
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .dout0(dout0),
    .dout1(dout1)
);
endmodule