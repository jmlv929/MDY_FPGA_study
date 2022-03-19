always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1) begin
            cnt1 <= 0;
        end 
        else begin
            cnt 1<= cnt1+1;
        end
    end
end

assign add_cnt1 = flag==1;
assign end_cnt1 = add_cnt1&&cnt1==5208-1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt2 <= 0;
    end
    else if(add_cnt2)begin
        if(end_cnt2) begin
            cnt2 <= 0;
        end 
        else begin
            cnt 2<= cnt2+1;
        end
    end
end

assign add_cnt2 = end_cnt1;
assign end_cnt2 = add_cnt2 && cnt2==10-1;

always @(posedge clk or negedge rst_n)begin
if(rst_n==1'b0)begin
        flag <= 0;
    end
    else if(tx_start)begin
        flag <= 1;
    end
    else if(end_cnt2)begin
        flag <= 0;
    end
end
assign  tx_start = tx_vld && rdy;

always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_data_tmp <= 0;
    end
    else if(tx_start)begin
        tx_data_tmp <= {1'b1,tx_data,1'b0};
    end
end
    
always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        uart_tx <= 0;
    end
    else if(add_cnt1 && cnt1==0)begin
        uart_tx <= tx_data_tmp[cnt2];
    end
end

always  @(*)begin
    if(flag || tx_vld)
        tx_rdy = 0;
    else
        tx_rdy = 1;
end
