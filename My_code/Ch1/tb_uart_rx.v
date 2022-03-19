`timescale  1ns / 1ps

module tb_uart_rx;

// uart_rx Parameters
parameter PERIOD = 10               ;
parameter N  = 8;

// uart_rx Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   uart_data                            = 0 ;

// uart_rx Outputs
wire  rx_vld                               ;
wire  [7:0]  rx_data                       ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

uart_rx #(
    .N ( N ))
 u_uart_rx (
    .clk                     ( clk              ),
    .rst_n                   ( rst_n            ),
    .uart_data               ( uart_data        ),

    .rx_vld                  ( rx_vld           ),
    .rx_data                 ( rx_data    [7:0] )
);

initial
begin
    uart_data = 0;
    #(PERIOD*102)

    uart_data = 1;
    #(PERIOD*10);

    uart_data = 0;
    #(PERIOD*8);     //起始位

    uart_data = 1;
    #(PERIOD*8);   //D0

    uart_data = 1;
    #(PERIOD*8);   //D1

    uart_data = 0;
    #(PERIOD*8);   //D2

    uart_data = 1;
    #(PERIOD*8);   //D3

    uart_data = 0;
    #(PERIOD*8);   //D4

    uart_data = 0;
    #(PERIOD*8);   //D5

    uart_data = 1;
    #(PERIOD*8);   //D6

    uart_data = 0;
    #(PERIOD*8);   //D7

    uart_data = 1;
    #(PERIOD*30);  


    $finish;
end

endmodule