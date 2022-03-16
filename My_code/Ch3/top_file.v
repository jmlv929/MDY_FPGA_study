`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/01 15:05:43
// Design Name: 
// Module Name: top_file
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


module top_file(
    clk,
    rst_n,
    din,
    dout,
    dout_sop,
    dout_eop,
    dout_vld
    );

input clk;
input rst_n;
input[7:0] din;
output [7:0] dout;
output  dout_sop;
output  dout_eop;
output  dout_vld;

wire[7:0] dout1;
wire dout_sop1;
wire dout_eop1;
wire dout_vld1;


message_statistics u_message_statistics(
    .clk(clk),
    .rst_n(rst_n),
    .din(dout1),
    .din_sop(dout_sop1),
    .din_eop(dout_eop1),
    .din_vld(dout_vld1),
    .dout(dout),
    .dout_sop(dout_sop),
    .dout_eop(dout_eop),
    .dout_vld(dout_vld)
    );

message_identification u_message_identification(
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .dout(dout1),
    .dout_sop(dout_sop1),
    .dout_eop(dout_eop1),
    .dout_vld(dout_vld1)
);
endmodule
