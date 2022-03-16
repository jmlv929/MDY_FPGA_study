module message_identification(
    clk,
    rst_n,
    din,
    dout,
    dout_sop,
    dout_eop,
    dout_vld
);
//参数

parameter HEAD = 5'b00001;
parameter TYPE = 5'b00010;
parameter LEN = 5'b00100;
parameter DATA = 5'b01000;
parameter FCS = 5'b10000;

//端口
input clk;
input rst_n;
input[7:0] din;
output reg[7:0] dout;
output reg dout_sop;
output reg dout_eop;
output reg dout_vld;

//内部信号
reg[4:0] state_c;
reg[4:0] state_n;
wire HEAD2TYPE_start;
wire TYPE2LEN_start;
wire LEN2DATA_start;
wire DATA2FCS_start;
wire TYPE2DATA_start;
wire FCS2HEAD_start;
reg[7:0] din_reg;
reg[15:0] cnt;
wire add_cnt;
wire end_cnt;
reg[15:0] x;
reg [15:0] data_N;
reg flag;  //内部使用，数据报文还是控制报文

//功能代码

//din reg
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        din_reg <= 8'b0;
    else
        din_reg <= din; 
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state_c <= HEAD;
    else  
        state_c <= state_n;
end

always@(*)
begin
    case(state_c)
        HEAD:
            if(HEAD2TYPE_start)
                state_n = TYPE;
            else
                state_n = state_c;
        TYPE:
            if(TYPE2LEN_start)
                state_n = LEN;
            else if(TYPE2DATA_start)
                state_n = DATA;
            else
                state_n = state_c;
        LEN:
            if(LEN2DATA_start)
            begin
                state_n = DATA;
            end
            else
                state_n = state_c; 
        DATA:
            if(DATA2FCS_start)
                state_n = FCS;
            else
                state_n = state_c;
        FCS:
            if(FCS2HEAD_start)
                state_n = HEAD;
            else
                state_n = state_c;
        default:   
            state_n = HEAD;
    endcase
end

assign HEAD2TYPE_start = (state_c == HEAD) && (din == 8'hd5) && (din_reg == 8'h55);
assign TYPE2LEN_start = (state_c == TYPE) && (din != 1'b0);
assign LEN2DATA_start = (state_c == LEN) && (add_cnt) && end_cnt;
assign TYPE2DATA_start = (state_c == TYPE) && (din == 1'b0);
assign DATA2FCS_start = (state_c == DATA) && end_cnt;
assign FCS2HEAD_start = (state_c == FCS) && end_cnt;



//计数器

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

assign add_cnt = (state_c == LEN) || (state_c == DATA) || (state_c == FCS);
assign end_cnt = (add_cnt) && (cnt == x-1);



always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        flag <= 1'b0;
    else if(state_c == LEN)
        flag <= 1'b1;
    else if(state_c == FCS)
        flag <= 1'b0;
end

always@(*)
begin
    if(!rst_n)
        x = 0;
    else if(state_c == LEN)
        x = 16'd2;
    else if(state_c == DATA)
        begin
            if(flag)
                x = data_N;
            else 
                x= 16'd64; 
        end
    else if(state_c == FCS)
        x = 16'd4;
    else 
        x = 0;
end

//采集数据字节的长度

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_N <= 16'd0;
    else if(state_c == LEN)
        begin
            if(add_cnt && cnt == 1'b0)
                data_N[15:8] <= din;
            else 
                data_N[7:0] <= din;
        end
end


//输出逻辑

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout <= 8'b0;
    else if(state_c == TYPE || state_c == LEN || state_c == DATA || state_c == FCS)
        dout <= din;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_sop <= 1'b0;
    else if(state_c == TYPE)
        dout_sop <= 1'b1;
    else 
        dout_sop <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_eop <= 1'b0;
    else if(state_c == FCS && add_cnt && cnt == 3)
        dout_eop <= 1'b1;
    else 
        dout_eop <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        dout_vld <= 1'b0;
    else if(state_c == TYPE || state_c == LEN || state_c == DATA || state_c == FCS )
        dout_vld <= 1'b1;
    else 
        dout_vld <= 1'b0;
end


endmodule