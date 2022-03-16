
module ztj(
    clk,
    rst_n,
    en,
    dout0,
    dout1
);

parameter S00 = 5'b00001;
parameter S11 = 5'b00010;
parameter S21 = 5'b00100;
parameter S22 = 5'b01000;
parameter S33 = 5'b10000;


//端口信号
input clk;
input rst_n;
input en;
output reg[1:0] dout0;
output reg[1:0] dout1;

//内部信号
reg[4:0] state_c;
reg[4:0] state_n;
reg[2:0] cnt;
wire add_cnt;
wire end_cnt;
reg[2:0] x;
wire S002S11_start;
wire S112S21_start;
wire S212S22_start;
wire S222S33_start;
wire S332S00_start;
//功能代码

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt <= 3'b0;
    else if(add_cnt)
        begin
            if(end_cnt)
                cnt <= 0;
            else 
                cnt <= cnt +1'b1; 
        end 
end

assign add_cnt = (en == 1'b1);
assign end_cnt = add_cnt && (cnt == x-1);

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state_c <= S00;
    else 
        state_c <= state_n;
end

always@(*)
begin
    case(state_c)
        S00:
            if(S002S11_start)
                state_n = S11;
            else  
                state_n = state_c;
        S11:
            if(S112S21_start)
                state_n = S21;
            else  
                state_n = state_c;
        S21:
            if(S212S22_start)
                state_n = S22;
            else  
                state_n = state_c;
        S22:
            if(S222S33_start)
                state_n = S33;
            else  
                state_n = state_c;
        S33:
            if(S332S00_start)
                state_n = S00;
            else  
                state_n = state_c;

        default:
            state_n = S00;

    endcase  
end



assign S002S11_start = state_c == S00 && end_cnt;
assign S112S21_start = state_c == S11 && end_cnt;
assign S212S22_start = state_c == S21 && end_cnt;
assign S222S33_start = state_c == S22 && end_cnt;
assign S332S00_start = state_c == S33 && end_cnt;

always@(*)
begin
    if(!rst_n)
        x = 3'b0;
    else if(state_c == S00)
        x =  3'b1;
    else if(state_c == S11)
        x =  3'd2;
    else if(state_c == S21)
        x =  3'd2;
    else if(state_c == S22)
        x =  3'd2;
    else if(state_c == S33)
        x =  3'd3;
end



//输出逻辑

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout0 <= 2'd0;
    if(state_c == S00)
        dout0 <= 2'd0;
    if(state_c == S11)
        dout0 <= 2'd1;
    if(state_c == S21)
        dout0 <= 2'd1;
    if(state_c == S22)
        dout0 <= 2'd2;
    if(state_c == S33)
        dout0 <= 2'd3;
end


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout1 <= 2'd0;
    if(state_c == S00)
        dout1 <= 2'd0;
    if(state_c == S11)
        dout1 <= 2'd1;
    if(state_c == S21)
        dout1 <= 2'd2;
    if(state_c == S22)
        dout1 <= 2'd2;
    if(state_c == S33)
        dout1 <= 2'd3;
end



endmodule