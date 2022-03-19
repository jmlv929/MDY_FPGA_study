`timescale 1ns/1ps

module tb_pwm();

reg clk;
reg rst_n;
wire pwm_out;
reg en;

pwm #(.N(8))  t_pwm (
    .clk(clk),           //假设输入32.768MHz 时钟
    .rst_n(rst_n),
    .en(en),
    .pwm_out(pwm_out)
);     

initial clk =1'b1;

always #30.5 clk = ~clk;

initial begin
    rst_n = 1'b0;
    en = 1'b0;

    #50;
    rst_n = 1'b1;

    #50;
    en = 1'b1;

    #16000;
    $stop;

end

endmodule