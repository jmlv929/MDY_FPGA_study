`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/02 16:38:01
// Design Name: 
// Module Name: tb_data_collect
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


module tb_data_collect(

    );
reg rst_n;
reg clkd;
reg clka;
reg clkb;
reg clkc;

reg[15:0] data_a;
reg[15:0] data_b;
reg[15:0] data_c;
wire[15:0] dout;

reg data_a_vld;
reg data_b_vld;
reg data_c_vld;
wire dout_vld;
wire[1:0] channel;


initial begin
    clka =1;
    clkb =1;
    clkc =1;
    clkd =1;
end

always #12.5 clka = ~clka;
always #25 clkb = ~clkb;
always #50 clkc = ~clkc;
always #6.25 clkd = ~clkd;


initial begin
    rst_n =0;
    data_a =0;
    data_b =0;
    data_c =0;
    data_a_vld =0;
    data_b_vld =0;
    data_c_vld =0;

    #249;
    rst_n =1;

    #706;

    data_b_vld =1;
    data_b =1;
    repeat(20)
    begin
        #50;
        data_b = data_b +1;
    end

    data_a =1;
    data_a_vld =1;
    data_c =3;
    data_c_vld =1;

    #1000;
    $stop;


end


data_collect u_data_collect(
    .clkd(clkd),
    .rst_n(rst_n),
    .clka(clka),
    .data_a(data_a),
    .data_a_vld(data_a_vld),
    .clkb(clkb),
    .data_b(data_b),
    .data_b_vld(data_b_vld),
    .clkc(clkc),
    .data_c(data_c),
    .data_c_vld(data_c_vld),
    .dout(dout),
    .dout_vld(dout_vld),
    .channel(channel)
    );
endmodule
