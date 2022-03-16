`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/01 21:31:21
// Design Name: 
// Module Name: data_collect
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


module data_collect(
    clkd,
    rst_n,
    clka,
    data_a,
    data_a_vld,
    clkb,
    data_b,
    data_b_vld,
    clkc,
    data_c,
    data_c_vld,
    dout,
    dout_vld,
    channel
    );
//参数定义

parameter IDLE = 3'b000;
parameter state1 = 3'b001;
parameter state2 = 3'b010;
parameter state3 = 3'b100;
parameter channel1 = 2'b00;
parameter channel2 = 2'b01;
parameter channel3 = 2'b10;

//端口信号
input rst_n;
input clkd;
input clka;
input clkb;
input clkc;

input[15:0] data_a;
input[15:0] data_b;
input[15:0] data_c;
output reg[15:0] dout;

input data_a_vld;
input data_b_vld;
input data_c_vld;
output reg dout_vld;
output reg[1:0] channel;

//内部信号
wire wr_en1;
wire wr_en2;
wire wr_en3;
reg rd_en1;
reg rd_en2;
reg rd_en3;
wire[15:0] dout1;
wire[15:0] dout2;
wire[15:0] dout3;
wire empty1;
wire empty2;
wire empty3;
reg[2:0] state_c;
reg[2:0] state_n;
wire state1_vld;
wire state2_vld;
wire state3_vld;



//功能代码

always@(posedge clkd or negedge rst_n)
begin
  if(!rst_n)
    state_c <= IDLE;
  else 
    state_c <= state_n;
end


always@(*)
begin
  if(!rst_n)
    state_n = IDLE;
  else 
  begin
    case(state_c)
      IDLE:
        begin
          rd_en1 = 0;
          rd_en2 = 0;
          rd_en3 = 0;
          if(empty1 == 0)
            state_n = state1;
          else if(empty2 == 0)
            state_n = state2;
          else if(empty3 == 0)
            state_n = state3;
          else 
            state_n = state_c;
        end
      state1:
        begin
          rd_en1 = 1;
          rd_en2 = 0;
          rd_en3 = 0;
          if(empty1 == 1 && empty2 == 0)
            state_n = state2;
          else if(empty1 == 1 && empty3 == 0)
            state_n = state3;
          else if(empty1 ==1 && empty2 ==1 && empty3 == 1)
            state_n = IDLE;
          else 
            state_n = state_c;
        end
      state2:
        begin
          rd_en1 = 0;
          rd_en2 = 1;
          rd_en3 = 0;
          if(empty2 == 1 && empty1 == 0)
            state_n = state1;
          else if(empty2 == 1 && empty3 == 0)
            state_n = state3;
          else if(empty1 == 1 && empty2 == 1 && empty3 == 1)
            state_n = IDLE;
          else  
            state_n = state_c;
        end
      state3:
        begin
          rd_en1 = 0;
          rd_en2 = 0;
          rd_en3 = 1;
          if(empty3 == 1 && empty1 == 0)
            state_n = state1;
          else if(empty3 == 1 && empty2 == 0)
            state_n = state2;
          else if(empty3 == 1 && empty1 == 1 && empty2 ==1)
            state_n = IDLE;
          else 
            state_n = state_c;
        end
      default:
        state_n = IDLE;
    endcase
  end
end

always@(posedge clkd or negedge rst_n)
begin
  if(!rst_n)
    dout <= 0;
  else if(state1_vld)  
    dout <= dout1;
  else if(state2_vld)
    dout <= dout2;
  else if(state3_vld)
    dout <= dout3;
  else 
    dout <= 0;
end

assign state1_vld = state_c == state1 && rd_en1 == 1 && empty1 == 0;   //关键条件，如果只写state_c == statex,则实际输出会是clkd的两拍为单位
assign state2_vld = state_c == state2 && rd_en2 == 1 && empty2 == 0;   // 要把rd_en2 == 1 && empty2 == 0也加上，因为empty2不为0时（FIFO空）
assign state3_vld = state_c == state3 && rd_en3 == 1 && empty3 == 0;    //FIFO也在输出数据，first fall through模式，要把这两个条件加上



always@(posedge clkd or negedge rst_n)
begin
  if(!rst_n)
    dout_vld <= 0;
  else if(state1_vld || state2_vld || state3_vld)
    dout_vld <= 1;
  else 
    dout_vld <= 0;
end


always@(posedge clkd or negedge rst_n)
begin
  if(!rst_n)
    channel <= 2'b11;
  else if(state1_vld)
    channel <= channel1;
  else if(state2_vld)
    channel <= channel2;
  else if(state3_vld)
    channel <= channel3;
  else 
    channel <= 2'b11;
end



fifo_generator_0 FIFO1(
  .rst(!rst_n),                  // input wire rst
  .wr_clk(clka),            // input wire wr_clk
  .rd_clk(clkd),            // input wire rd_clk
  .din(data_a),                  // input wire [15 : 0] din
  .wr_en(wr_en1),              // input wire wr_en
  .rd_en(rd_en1),              // input wire rd_en
  .dout(dout1),                // output wire [15 : 0] dout
  .full(),                // output wire full
  .empty(empty1),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

assign wr_en1 = data_a_vld;

fifo_generator_0 FIFO2(
  .rst(!rst_n),                  // input wire rst
  .wr_clk(clkb),            // input wire wr_clk
  .rd_clk(clkd),            // input wire rd_clk
  .din(data_b),                  // input wire [15 : 0] din
  .wr_en(wr_en2),              // input wire wr_en
  .rd_en(rd_en2),              // input wire rd_en
  .dout(dout2),                // output wire [15 : 0] dout
  .full(),                // output wire full
  .empty(empty2),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

assign wr_en2 = data_b_vld;

fifo_generator_0 FIFO3(
  .rst(!rst_n),                  // input wire rst
  .wr_clk(clkc),            // input wire wr_clk
  .rd_clk(clkd),            // input wire rd_clk
  .din(data_c),                  // input wire [15 : 0] din
  .wr_en(wr_en3),              // input wire wr_en
  .rd_en(rd_en3),              // input wire rd_en
  .dout(dout3),                // output wire [15 : 0] dout
  .full(),                // output wire full
  .empty(empty3),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

assign wr_en3 = data_c_vld;

endmodule
