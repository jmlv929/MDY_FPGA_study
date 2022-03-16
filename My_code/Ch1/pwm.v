module pwm(
    clk,           //假设输入32.768MHz 时钟
    rst_n,
    en,
    pwm_out
);                     //输出30%占空比的脉冲

input clk;
input rst_n;
output reg pwm_out;
input en;
reg [3:0] cnt_10ms;
wire add_cnt_10ms;
wire end_cnt_10ms;
reg flag;

reg [15:0] cnt_1ms;
wire add_cnt_1ms;
wire end_cnt_1ms;


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        flag <= 1'b0;
    else if(en)
        flag <= 1'b1;
    else if(end_cnt_1ms)
        flag <= 1'b0;
end


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_1ms <= 16'd0;
    else if(add_cnt_1ms)
        begin
            if(end_cnt_1ms)
                cnt_1ms <= 16'd0;
            else
                cnt_1ms <= cnt_1ms +1'b1; 
        end    
end

assign add_cnt_1ms = flag == 1'b1;
assign end_cnt_1ms = add_cnt_1ms && (cnt_1ms == 16'd32768 - 1'b1);


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_10ms <= 4'd0;
    else if(add_cnt_10ms)
        begin
            if(end_cnt_10ms)
                cnt_10ms <= 4'd0;
            else
                cnt_10ms <= cnt_10ms +1'b1; 
        end    
end

assign add_cnt_10ms = add_cnt_1ms && (16'd32768 - 1'b1);
assign end_cnt_10ms = add_cnt_10ms && (cnt_10ms == 4'd10 - 1'b1);

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        pwm_out <= 1'b0;
    else if(add_cnt_10ms && (cnt_10ms < 3) )
        pwm_out <= 1'b1;
    else 
        pwm_out <= 1'b0;
end

endmodule