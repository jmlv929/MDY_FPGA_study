`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/01 13:59:49
// Design Name: 
// Module Name: message_statistics
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


module message_statistics(
    clk,
    rst_n,
    din,
    din_sop,
    din_eop,
    din_vld,
    dout,
    dout_sop,
    dout_eop,
    dout_vld
    );
//参数定义


//端口定义
input clk;
input rst_n;
input[7:0] din;
input din_sop;
input din_eop;
input din_vld;
output reg[7:0] dout;
output reg dout_sop;
output reg dout_eop;
output reg dout_vld;

//内部信号
wire[8:0] din1;
reg rd_flag;
wire wr_en2;
wire[7:0] din2;
wire rd_en2;
wire end_cnt;
reg [7:0] cnt;
wire[8:0] dout1;
wire start;
wire add_cnt;
wire[7:0] dout2;



//功能代码

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt <= 0;
    else if(add_cnt)
        begin
            if(end_cnt)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end 
end

assign add_cnt = din_vld;
assign end_cnt = add_cnt && din_eop;



always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_flag <= 1'b0;
    else if(start)
        rd_flag <= 1'b1;
    else if(rd_en2)
        rd_flag <= 1'b0;
end

assign start = empty2 == 0 && rd_en1 == 0;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout <= 8'b0;
    else if(start)
        dout <= dout2;
    else if(rd_en1)
        dout <= dout1[8:1];
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_sop <= 1'b0;
    else if(start)
        dout_sop <= 1'b1;
    else 
        dout_sop <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_eop <= 1'b0;
    else if(rd_en2)
        dout_eop <= 1'b1;
    else  
        dout_eop <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_vld <= 1'b0;
    else if(start || rd_en1)
        dout_vld <= 1'b1;
    else  
        dout_vld <= 1'b0;
end

fifo_generator_0 data_fifo (
  .clk(clk),                  // input wire clk
  .srst(!rst_n),                // input wire srst
  .din(din1),                 // input wire [8 : 0] din
  .wr_en(wr_en1),              // input wire wr_en
  .rd_en(rd_en1),              // input wire rd_en
  .dout(dout1),                // output wire [8 : 0] dout
  .full(),                // output wire full
  .empty(empty1),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

assign wr_en1 = din_vld;
assign din1 = {din,din_eop};
assign rd_en1 = rd_flag;

fifo_generator_1 message_fifo (
  .clk(clk),                  // input wire clk
  .srst(!rst_n),                // input wire srst
  .din(din2),                  // input wire [7 : 0] din
  .wr_en(wr_en2),              // input wire wr_en
  .rd_en(rd_en2),              // input wire rd_en
  .dout(dout2),                // output wire [7 : 0] dout
  .full(),                // output wire full
  .empty(empty2),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

assign wr_en2 = end_cnt;
assign din2 = cnt + 1;
assign rd_en2 = dout1[0] == 1'b1 && rd_en1 == 1'b1;

endmodule
