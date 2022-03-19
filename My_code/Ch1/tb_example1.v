`timescale  1ns / 1ps

module tb_example1;

// example1 Parameters
parameter PERIOD  = 10;


// example1 Inputs
reg   clk                                  = 0 ;
reg   en                                   = 0 ;
reg   aresetn                              = 0 ;

// example1 Outputs
wire  dout                                 ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) aresetn  =  1;
end

example1  u_example1 (
    .clk                     ( clk       ),
    .en                      ( en        ),
    .aresetn                 ( aresetn   ),

    .dout                    ( dout      )
);

initial
begin
    en = 0;

    # (PERIOD*8.5);

    en = 1;

    #(PERIOD*10);

    en = 0;

    #(PERIOD*9.4);

    en = 1;

    #(PERIOD*20);

    $finish;
end

endmodule