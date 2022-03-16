`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/03 14:14:29
// Design Name: 
// Module Name: tb_cut_package
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


module tb_cut_package(

    );
reg clk;  //50MHz 时钟
reg rst_n;
reg[7:0] din;
reg din_vld;
reg din_sop;
reg din_eop;
wire[7:0] dout;
wire dout_vld;
wire dout_sop;
wire dout_eop;


initial clk = 1;

always #10 clk = ~clk;

initial begin
    rst_n = 0;
    din = 1;
    din_vld = 0;
    din_sop = 0;
    din_eop = 0;
    #304;
    rst_n =1;

    #502;


    din_vld = 1;  //数据小于46
    din_sop = 1;
    repeat(30)
    begin
        #20;
        din_sop = 0;
        din = din + 1;

    end
    din_eop = 1;
    #20;
    din_vld = 0;
    din_eop = 0;

    #806;

    din_vld = 1;  //数据大于46 小于1500
    din_sop = 1;
    repeat(80)
    begin
        #20;
        din_sop = 0;
        din = din + 1;

    end
    din_eop = 1;
    #20;
    din_vld = 0;
    din_eop = 0;



    #806;

    din_vld = 1;  //数据大于1500小于1546
    din_sop = 1;
    repeat(1520)
    begin
        #20;
        din_sop = 0;
        din = din + 1;

    end
    din_eop = 1;
    #20;
    din_vld = 0;
    din_eop = 0;

    #50000;
    $stop;
    
end


cut_package u_cut_package(
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .din_vld(din_vld),
    .din_sop(din_sop),
    .din_eop(din_eop),
    .dout(dout),
    .dout_vld(dout_vld),
    .dout_sop(dout_sop),
    .dout_eop(dout_eop)
    );

endmodule
