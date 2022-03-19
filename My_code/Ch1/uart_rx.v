module uart_rx(
    input clk, //50MHz
    input rst_n,
    input uart_data,
    output reg rx_vld,  //一个clk有效
    output reg [7:0] rx_data
);

//波特率9600bps
parameter N = 50_000_000 / 9600;

reg uart_data_r0, uart_data_r1, uart_data_r2, flag;
wire falling_edge;

reg[12:0] cnt1;
reg[3:0] cnt2;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_data_r0 <= 0;
        uart_data_r1 <= 0;
        uart_data_r2 <= 0;
    end 
    else begin
       uart_data_r0 <= uart_data;
       uart_data_r1 <= uart_data_r0;
       uart_data_r2 <= uart_data_r1;  
    end
end

assign falling_edge = uart_data_r1 == 0 && uart_data_r2 == 1'b1;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        flag <= 0;
    else if(falling_edge)
        flag <= 1;
    else if(flag && cnt2 == 9 - 1 && cnt1  == N - 1)                    //清零条件
        flag <= 0;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt1 <= 0;
    else if(flag) begin
        if(cnt1 == N - 1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt2 <= 0;
    else if(flag && cnt1 == N - 1) begin
        if(cnt2 == 9 - 1) 
            cnt2 <= 0;
        else
            cnt2 <= cnt2 + 1'b1;
    end
end

//输出逻辑

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rx_data <= 0;
    else if(flag && cnt1 == (N - 1 )/2 && cnt2 >= 1) 
        rx_data <= {uart_data_r1, rx_data[7:1]};
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rx_vld <= 0;
    else if(flag && cnt2 == 9 - 1 && cnt1 == (N -1) /2 + 1)
        rx_vld <= 1;
    else
        rx_vld <= 0;
end

endmodule