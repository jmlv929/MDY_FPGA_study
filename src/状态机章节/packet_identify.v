always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    state_c <= HEAD;
    end
    else begin
        state_c <= state_n;
    end
end

always@(*)begin
    case(state_c)
        HEAD:begin
            if(hea2typ_start)begin
                state_n = TYPE;
            end
            else begin
                state_n = state_c;
            end
        end
        TYPE:begin
            if(typ2len_start)begin
                state_n = LEN;
            end
            else if(typ2dat_start)begin
                state_n = DATA;
            end
            else begin
                state_n = state_c;
            end
        end
        LEN:begin
            if(len2dat_start)begin
                state_n = DATA;
            end
            else begin
                state_n = state_c;
            end
        end
        DATA:begin
            if(dat2fcs_start)begin
                state_n = FCS;
            end
            else begin
                state_n = state_c;
            end
        end
        FCS:begin
            if(fcs2hea_start)begin
                state_n = HEAD;
            end
            else begin
                state_n = state_c;
            end
        end
        default:begin
            state_n = HEAD;
        end
    endcase
end

assign hea2typ_start = state_c==HEAD && end_cnt;
assign typ2len_start = state_c==TYPE && din!=0;
assign len2dat_start = state_c==LEN && end_cnt;
assign tpy2dat_start = state_c==TYPE && din==0;
assign dat2fcs_start = state_c==DATA && end_cnt;
assign fcs2hea_start = state_c==FCS  && end_cnt;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

assign add_cnt=(state_c==LEN)||(state_c==DATA)|| (state_c==FCS);
assign end_len_cnt = add_cnt && cnt==y-1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        x <= 0;
    end
    else if(typ2dat_start)begin
        length <= 64;
    end
    else if(state_c==LEN)begin
        length <= {length[7:0],din};  
    end
end

always  @(*)begin
    if(state_c==LEN)
    y = 2;
    else if(state_c==DATA)
    y = x;
    else
    y = 4;
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 0;
    end
    else if(state_c==TYPE)begin
        dout_sop <= 1;
    end
    else begin
        dout_sop <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 0;
    end
    else if(state_c==FCS && end_fcs_cnt)begin
        dout_eop <= 1;
    end
    else begin
        dout_eop <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 0;
    end
    else if(state_c!=HEAD)begin
        dout_vld <= 1;
    end
    else begin
        dout_vld <= 0;
    end
end

