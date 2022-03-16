`timescale 1ns/1ps

module tb_spi();
reg clk;
reg rst_n;
reg start;
reg[1:0] mode;
reg[6:0] addr;
reg[7:0] wdata;
wire rdy;
wire[7:0] rdata;
wire rdata_vld;
wire cs;
wire sk;
wire mosi;
reg miso;


initial clk = 1;
always #5 clk = ~clk;

initial begin
    rst_n = 1'b0;
    start = 0;
    mode = 0;
    addr = 0;
    wdata = 0;
    miso = 0;

    #203;
    rst_n = 1'b1;

    #200;              //write

    mode = 2'b01;
    addr = 7'h16;
    wdata = 8'h55;

    #300;

    start = 1;

    #10;
    start = 0;

    #(1000*30);
    miso = 1'b1;

    #300;

    #200;              //read

    mode = 2'b10;
    addr = 7'h16;
    wdata = 8'h55;
    miso = 1'b1;

    #1800;

    start = 1;

    #10;
    start = 0;

    #(1000*30);


    mode = 2'b00;   //EWEN
    addr = 7'h16;
    wdata = 8'h55;
    miso = 1'b1;

    #1800;

    start = 1;

    #10;
    start = 0;

    #(1000*30);

$stop; 

end


spi u_spi(
    .clk(clk),          
    .rst_n(rst_n),
    .start(start),
    .mode(mode),
    .addr(addr),
    .wdata(wdata),
    .rdy(rdy),
    .rdata(rdata),
    .rdata_vld(rdata_vld),
    .cs(cs),
    .sk(sk),
    .miso(miso),
    .mosi(mosi)
);

endmodule