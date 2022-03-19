always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt <= 0;
    end
    else if(add_cnt) begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end
assign  add_cnt = flag==1'b1;
assign  end_cnt = add_cnt &&cnt==x+y-1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_c<= 0;
    end
    else if(add_cnt_c) begin
        if(end_cnt_c)
             cnt_c<= 0;
        else
             cnt_c<= cnt_c + 1;
    end
end

assign  add_cnt_c = end_cnt;
assign end_cnt_c = add_cnt_c&& cnt_c==4-1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
       dout<=0;
   end
    else if(add_cnt&&cnt==x-1)begin
        dout<=1;
    end
    else if(end_cnt)begin
        dout<=0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag<=0;
    end
    else if(en)begin
        flag<=1;
    end
    else if(end_cnt_c)begin
        flag<=0;
    end
end

always  @(*)begin
    if(cnt1==0)begin
        x = 1;
        y = 1;
    end
    else if(cnt1==1)begin
        x = 1;
        y = 2;
    end
    else if(cnt1==2)begin
        x = 1;
        y = 3;
    end
    else if(cnt1==3)begin
        x = 1;
        y = 4;
    end
    else begin
        x = 0;
        y = 0;
    end
end
