`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/03 10:27:08
// Design Name: 
// Module Name: cut_package
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


module cut_package(
    clk,
    rst_n,
    din,
    din_vld,
    din_sop,
    din_eop,
    dout,
    dout_vld,
    dout_sop,
    dout_eop
    );

//参数定义
parameter IDLE = 3'b001;
parameter state_data = 3'b010;
parameter state_0 = 3'b100;


//端口信号

input clk;
input rst_n;
input[7:0] din;
input din_vld;
input din_sop;
input din_eop;
output reg[7:0] dout;
output reg dout_vld;
output reg dout_sop;
output reg dout_eop;


//内部信号
wire wr_en1;
wire wr_en2;
wire rd_en1;
wire rd_en2;
wire empty1;
wire empty2;
wire[11:0] dout1;
wire[10:0] dout2;
reg [2:0] state_n;
reg [2:0] state_c;
wire add_cnt;
wire end_cnt;
reg[10:0] cnt;
wire dout_start; //切取之后开始信号
wire dout_stop;   //切取之后结束信号
reg[5:0] cnt_0;  //输出多少个0
wire add_cnt_0;
wire end_cnt_0;
wire[11:0] din1;
wire[10:0] din2;


//功能代码

always@(posedge clk or negedge rst_n)  
begin
    if(!rst_n)
        state_c <= IDLE;
    else 
        state_c <= state_n;
end


always@(*)                         //状态机以及状态转移
begin
    if(!rst_n)
        state_n = IDLE;
    else
    begin
        case(state_c)
        IDLE:
        begin
            if(empty2 == 0 && empty1 == 0)
                state_n = state_data;
            else 
                state_n = state_c;
        end
        state_data:
        begin
            if(dout2 < 46 && empty1 == 1)
                state_n = state_0;
            else if(empty2 == 1)
                state_n = IDLE;
            else 
                state_n = state_c;
        end
        state_0:
            if(end_cnt_0)
                state_n = IDLE;
            else 
                state_n = state_c;
        default:
            state_n= IDLE;
        endcase
    end 
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_0 <= 0;
    else if(add_cnt_0)
    begin
        if(end_cnt_0)
            cnt_0 <= 0;
        else 
            cnt_0 <= cnt_0 +1; 
    end
end

assign add_cnt_0 = state_c == state_0;
assign end_cnt_0 = add_cnt_0 && cnt_0 == 46 -dout2 -2;


always@(posedge clk or negedge rst_n)       //统计输入报文个数
begin
    if(!rst_n)
        cnt <= 0;
    else if(add_cnt)
    begin
        if(end_cnt)
            cnt <= 0;
        else 
            cnt <= cnt +1;
    end 
end

assign add_cnt = din_vld;
assign end_cnt = add_cnt && (din_eop == 1 || (add_cnt && cnt == 1500 -1));  //当收到eop 或者 计数达到1500字节就结束计数

assign dout_start = (add_cnt && cnt == 0);
assign dout_stop = end_cnt;


//输出逻辑

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout <= 0;
    else if(state_c == state_data && rd_en1 == 1)
        dout <= dout1[11:4];
    else if(state_c == state_0)
        dout <= 0;
    else 
        dout <= 0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_vld <= 0;
    else if(rd_en1 == 1 || (state_c == state_0) )
        dout_vld <= 1;
    else 
        dout_vld <= 0;
end


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_sop <= 0;
    else if((rd_en1 == 1 && dout1[3] == 1) || ((dout1[1] == 1) && dout2 == 1499))
        dout_sop <= 1;
    else 
        dout_sop <= 0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_eop <= 0;
    else if((state_c == state_data && dout1[2] == 1 && dout2 >= 45) || (state_c == state_0 && end_cnt_0))
        dout_eop <= 1;
    else 
        dout_eop <= 0;
end

//例化FIFO

fifo_generator_0 data_fifo(
  .clk(clk),                  // input wire clk
  .srst(!rst_n),                // input wire srst
  .din(din1),                  // input wire [11 : 0] din
  .wr_en(wr_en1),              // input wire wr_en
  .rd_en(rd_en1),              // input wire rd_en
  .dout(dout1),                // output wire [11 : 0] dout
  .full(),                // output wire full
  .empty(empty1),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

assign wr_en1 = din_vld;
assign din1 = {din,din_sop,din_eop,dout_start,dout_stop};
assign rd_en1 = state_c == state_data && empty1 == 0 && empty2 == 0;

fifo_generator_1 message_fifo(
  .clk(clk),                  // input wire clk
  .srst(!rst_n),                // input wire srst
  .din(din2),                  // input wire [10 : 0] din
  .wr_en(wr_en2),              // input wire wr_en
  .rd_en(rd_en2),              // input wire rd_en
  .dout(dout2),                // output wire [10 : 0] dout
  .full(),                // output wire full
  .empty(empty2),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

assign din2 = cnt;            //另写入信息FIFO的值为输出数据个数，MFIFO写入的值最小为46
assign wr_en2 = end_cnt;      //计数结束把值写入信息FIFO
assign rd_en2 = (state_c == state_data && dout1[0] == 1 && empty2 == 0 && dout2 >= 45) || (state_c == state_0 && end_cnt_0 && empty2 == 0);

endmodule
