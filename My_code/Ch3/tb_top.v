`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/01 15:13:24
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module tb_top();
reg clk;
reg rst_n;
reg[7:0] din;
wire[7:0] dout;
wire dout_sop;
wire dout_eop;
wire dout_vld;

initial clk = 1;
always #5 clk = ~clk;

initial begin
    rst_n = 0;
    din = 8'b0;

    #104;
    rst_n = 1;
    #100;
    din = 8'h0;
    #10;
    din = 8'h45;
    #10;
    din = 8'h33;
    #10;
    din = 8'h67;
    #10;
    din = 8'h24;
    #10;
    din = 8'h86;
    #10;            //控制报文
    din = 8'h55;
    #10;
    din = 8'hd5;
    #10;
    din = 8'h0;     // 0 表示控制报文
    #10;
    repeat(20)
    begin
        din = 8'h11;
        #10;
    end    
    repeat(44)
    begin
        din = 8'h22;
        #10;
    end                //64字节的data
    repeat(4)
    begin
        din = 8'hCC;
        #10;
    end           //4字节的FCS

    repeat(20)
    begin
        din = 8'h33;
        #10;
    end
    din = 8'h55;    //数据报文
    #10;
    din = 8'hd5;
    #10;
    din = 8'hd5;
    #10;

    din = 8'h00;   //长度10个字节
    #10;
    din = 8'h0A;
    #10;


    repeat(5)
    begin
        din = 8'hDD;
        #10;
    end
    repeat(5)
    begin
        din = 8'hEE;
        #10;
    end
    repeat(4)
    begin
        din = 8'hCC;
        #10;
    end           //4字节的FCS
    repeat(50)
    begin
        din = 8'h00;
        #10;
    end  


    #1000;
    $stop;


end

top_file u_top_file(
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .dout(dout),
    .dout_sop(dout_sop),
    .dout_eop(dout_eop),
    .dout_vld(dout_vld)
    );

endmodule
