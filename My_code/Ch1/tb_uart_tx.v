`timescale 1ns/1ps

module tb_uart_tx();

reg clk;   
reg rst_n;
reg tx_valid;
wire tx_ready;
reg [7:0] tx_data;
wire uart_data;

initial clk = 1'b1;

always #10 clk = ~clk;

initial begin
rst_n = 1'b0;
tx_valid = 1'b0;
tx_data = 8'b11001101;

#1000;
rst_n = 1'b1;
#2000;
tx_valid = 1'b1;
#20;
tx_valid = 1'b0;

#1800000;
$stop;
end


uart_tx t_uart_tx(
    .clk(clk),
    .rst_n(rst_n),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready),
    .tx_data(tx_data),
    .uart_data(uart_data)
);


endmodule