module spi(
    clk,           //输入时钟100MHz
    rst_n,
    start,
    mode,
    addr,
    wdata,
    rdy,
    rdata,
    rdata_vld,
    cs,
    sk,
    miso,
    mosi
);

//参数信号
parameter IDLE = 2'b00;
parameter WR_RD = 2'b01;
parameter TCS = 2'b10;
parameter DO = 2'b11;
parameter END_CNT = 100;  //输入100MHz，确保计数100个，生成1MHz的spi的时钟

parameter EWEN = 2'b00;
parameter WRITE = 2'b01;
parameter READ = 2'b10;

parameter EWEN_CONSTANT = 10'b00000_11001;


//端口信号
input clk;
input rst_n;
input start;
input[1:0] mode;
input[6:0] addr;
input[7:0] wdata;
output reg rdy;
output reg[7:0] rdata;
output reg rdata_vld;
output reg cs;
output reg sk;
output reg mosi;
input  miso;


//内部信号
reg[1:0] state_c;
reg[1:0] state_n;
wire IDLE2WRRD_start;
wire WRRD2TCS_start;
wire TCS2DO_start;
wire DO2IDLE_start;
wire TCS2IDLE_start;
reg[6:0] cnt;
wire add_cnt;
wire end_cnt;
reg[4:0] cnt1;
wire add_cnt1;
wire end_cnt1;
reg[4:0] x;
reg[17:0] data_reg;       //存储数据和地址 还有读写控制信号
reg[7:0] rdata_reg;       //miso数据
reg[1:0] mode_reg;

//功能代码

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state_c <= IDLE;
    else 
        state_c <= state_n; 
end

always@(*)
begin
    case(state_c)
        IDLE:
            if(IDLE2WRRD_start)
                state_n <= WR_RD;
            else    
                state_n <= state_c;
        WR_RD:
            if(WRRD2TCS_start)
                state_n <= TCS;
            else    
                state_n <= state_c;
        TCS:
        begin
            if(TCS2IDLE_start)
                state_n <= IDLE;
            else if(TCS2DO_start)
                state_n <= DO;
            else    
                state_n <= state_c;
        end
        DO:
            if(DO2IDLE_start)
                state_n <= IDLE;
            else    
                state_n <= state_c;
        default: 
                state_n <= IDLE;

    endcase
end

assign IDLE2WRRD_start = state_c == IDLE && start == 1'b1;
assign WRRD2TCS_start = state_c == WR_RD && end_cnt1;
assign TCS2DO_start = state_c == TCS && mode_reg == WRITE && end_cnt1;
assign DO2IDLE_start = state_c == DO && miso == 1'b1;
assign TCS2IDLE_start = state_c == TCS && end_cnt1 && mode_reg == READ;

always@(posedge clk or negedge rst_n)          //计数1MHz
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

assign add_cnt = (state_c == WR_RD) || (state_c == TCS);
assign end_cnt = add_cnt && (cnt == END_CNT-1);

always@(posedge clk or negedge rst_n)         //计数cs高电平期间 sk持续多少个周期
begin
    if(!rst_n)
        cnt1 <= 0;
    else if(add_cnt1)
        begin
            if(end_cnt1)
                cnt1 <= 0;
            else 
                cnt1 <= cnt1 +1'b1; 
        end 
end

assign add_cnt1 = end_cnt;
assign end_cnt1 = add_cnt1 && (cnt1 == x-1);  //x为read或者write、EWEN状态sk持续的周期个数

always@(*)
begin
    if(!rst_n)
        x = 0;
    else if(state_c == WR_RD &&(mode == EWEN)) 
        x = 10;
    else if(state_c == WR_RD && (mode == WRITE || mode == READ))
        x = 18;
    else if(state_c == TCS)
        x = 1;
    else 
        x = x;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rdy <= 1'b1;
    else if(start == 1'b1)
        rdy <= 1'b0;
    else if(DO2IDLE_start || TCS2IDLE_start)
        rdy <= 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cs <= 1'b0;
    else if(state_c == WR_RD || state_c == DO)
        cs <= 1'b1;
    else
        cs <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        sk <= 1'b0;
    else if(state_c == WR_RD)
        begin
            if(add_cnt && cnt == 50-1)
                sk <= 1'b1;
            else if(end_cnt)
                sk <= 1'b0;
        end
    else
        sk <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            data_reg <= 18'b0;
        end
    else if(start && mode_reg == WRITE && rdy == 1'b1)
        begin
            data_reg <= {3'b101,addr,wdata};
        end
    else if(start && mode_reg == READ)
        begin
            data_reg <= {3'b110,addr,8'b0};
        end
    else 
        data_reg <= data_reg;
end

always@(*)
begin
    if(!rst_n)
        mode_reg = 2'b0;
    else if(start == 1'b1 && rdy == 1'b1)
        mode_reg =mode;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        mosi <= 1'b0;
        rdata_reg <= 0;
    end
    else if(state_c == WR_RD)
    begin
        case(mode_reg)
            EWEN:
                begin
                    mosi <= EWEN_CONSTANT[cnt1];
                end
            WRITE:
                mosi <= data_reg[17-cnt1];
            READ:
                begin
                    if(add_cnt1 && cnt1 < 10 && cnt == 0)
                        mosi <= data_reg[17-cnt1];
                    else if(add_cnt && cnt == 0)
                        rdata_reg[17-cnt1] <= miso;
                end
            default:
                mosi <= data_reg[17-cnt1];
    endcase
    end 
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rdata <= 0;
        rdata_vld <= 1'b0;
    end
    else if(TCS2IDLE_start)
    begin
        rdata <= rdata_reg;
        rdata_vld <= 1'b1;        
    end
    else
        begin
            rdata <= 0;
            rdata_vld <= 1'b0;
        end
end


endmodule