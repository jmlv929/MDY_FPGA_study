module uart_tx(
    clk,
    rst_n,
    tx_valid,
    tx_ready,
    tx_data,
    uart_data
);

parameter CLK = 50_000_000;
parameter BAUD = 9600;
parameter ONEBIT = CLK/BAUD; 

//端口信号
input clk;   //输入时钟50MHz
input rst_n;
input tx_valid;
output reg tx_ready;
input [7:0] tx_data;
output reg uart_data;


//内部信号
reg [19:0] cnt_onebit;
wire add_cnt_onebit;
wire end_cnt_onebit;
reg flag;
reg [3:0] cnt;
wire add_cnt;
wire end_cnt;
reg [9:0] data_reg;    //内部数据暂存寄存器
//功能逻辑


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        flag <= 1'b0;
    else if(tx_valid)                 //此处条件为 tx_valid && (!flag) 更为合适
        flag <= 1'b1;
    else if(end_cnt)
        flag <= 1'b0;
end

always@(*)
begin
    if(!rst_n)
        tx_ready = 1'b1;
    else if(tx_valid || flag)               //此处条件为 tx_valid || flag 更为合适
        tx_ready = 1'b0;
    else if(end_cnt)
        tx_ready = 1'b1;
    else
        tx_ready = 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
         cnt_onebit <= 0;
    else if(add_cnt_onebit)
        begin
            if(end_cnt_onebit)
                cnt_onebit <= 0;
            else
                cnt_onebit <= cnt_onebit +1'b1; 
        end
end

assign add_cnt_onebit = flag == 1'b1;
assign end_cnt_onebit = (add_cnt_onebit) && (cnt_onebit == ONEBIT -1'b1);


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
         cnt <= 0;
    else if(add_cnt)
        begin
            if(end_cnt)
                cnt <= 0;
            else
                cnt <= cnt +1'b1; 
        end
end

assign add_cnt = (add_cnt_onebit) && (cnt_onebit == ONEBIT -1'b1);
assign end_cnt = (add_cnt) && (cnt == 4'd10 -1'b1);


//输出逻辑

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_reg <= {1'b1,8'b0,1'b0};
    else if(tx_valid)
        data_reg[8:1] <= tx_data;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        uart_data <= 1'b1;
    else if((add_cnt_onebit) && (cnt_onebit == 1'b0))   //这步是关键
        uart_data <= data_reg[cnt];
end


endmodule