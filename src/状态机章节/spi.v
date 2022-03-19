always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        state_c <= IDLE;
    end
    else begin
        state_c <=state_n; 
    end
end

always  @(*)begin
    case(state)
        IDLE:begin
            if(wr_rd_start)begin
                state_n = WR_RD;
            end
            else begin
                state_n = state_c;
            end
        end
        WR_RD:begin
            if(tcs_start)begin
                state_n = TCS;
            end
            else begin
                state_n = state_c;
            end
        end
        TCS:begin
            if(do_start)begin
                state_n = DO;
            end
            else if(idle_start1)begin
                state_n = IDLE
            end
            else begin
                state_n = state_c;
            end
        end
        DO:begin
            if(idle_start2)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        default:begin
            state_n = IDLE;
        end
    endcase
end

assign wr_rd_start = state_c == IDLE  && start == 1;
assign tcs_start   = state_c == WR_RD && end_cnt1  ;
assign idle_start1 = state_c == TCS   && mode_reg == (EWEN || READ) && end_cnt;
assign do_start    = state_c == TCS   && mode_reg == WRITE && end_cnt;
assign idle_start2 = state_c == DO    && mode_reg == WRITE && do == 1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end
end

assign add_cnt = state_c == WR_RD || state_c == TCS;
assign end_cnt = add_cnt && cnt == 100-1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt1 <= 1'b0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)begin
            cnt1 <= 1'b0;
        end
        else begin
            cnt1 <= cnt1 +1'b1;
        end
    end
end

assign add_cnt1 = end_cnt;
assign end_cnt1 = add_cnt1 && cnt1 == x-1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cs <= 0;
    end
    else if(cs_high)begin
        cs <= 1;
    end
    else if(cs_low)begin
        cs <= 0;
    end
end

assign cs_high = wr_rd_start || do_start   ;
assign cs_low  = tcs_start   || idle_start2;

always  @(*)begin
    if(rdy_low)begin
        rdy = 0;
    end
    else begin
        rdy = 1;
    end
end

assign rdy_low = start || state_c != IDLE;  

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sk <= 0;
    end
    else if(sk_high)begin
        sk <= 1;
    end
    else if(sk_low)begin
        sk <= 0;
    end
end
assign sk_high = state_c == WR_RD && add_cnt && cnt == 50-1;
assign sk_low  = state_c == WR_RD && end_cnt;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(start && mode==0)begin
        dout <= {3'b100,addr,8'b0};
    end
    else if(start && mode==1)begin
        dout <= {3'b101,addr,wdata};
    end
    else if(start && mode==2)begin
        dout <= {3'b110,addr,8'b0};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        di <= 0;
    end
    else if(di_en)begin
        di <= dout[17-cnt1];
    end
end

assign di_en = state_c == WR_RD && end_cnt;//end_cnt?

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata <= 0;
    end
    else if(rdata_en)begin
        rdata <=  {rdata[6:0],do};
    end
end

assign rdata_en = mode_reg == READ && state_c == WR_RD && end_cnt && cnt1 >= 10 && cnt1 < 18;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata_vld <= 0;
    end
    else if(rdata_vld_en)begin
        rdata_vld <= 1;
    end
    else begin
        rdata_vld <= 0;     
    end
end

assign rdata_vld_en = mode_reg == READ && tcs_start;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        mode_reg <= 0;
    end
    else if(start && mode==0)begin
        mode_reg <= EWEN;
    end
    else if(start && mode==1)begin
        mode_reg <= WRITE;
    end
    else if(start && mode==2)begin
        mode_reg <= READ;
    end
end

always  @(*)begin
    if(mode_reg == EWEN)begin
        x = 10;
    end
    else if(mode_reg == WRITE)begin
        x = 18;
    end
    else if(mode_reg == READ)begin
        x = 18;
    end
    else begin
        x = 0;
    end
end
