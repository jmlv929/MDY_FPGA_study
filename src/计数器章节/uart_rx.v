always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1) begin
            cnt 1<= 0;
        end 
        else begin
            cnt1 <= cnt1+1;
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
        if(end_cnt2)begin
            cnt2 <= 0;
        end 
        else begin
            cnt2 <= cnt2+1;
        end 
    end
end

assign add_cnt2 = end_cnt1;
assign end_cnt2 = add_cnt2&&cnt2==10-1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        uart_rx_ff0 <= 1;
        uart_rx_ff1 <= 1;
        uart_rx_ff2 <= 1;
    end
    else begin
        uart_rx_ff0 <= uart_rx;
        uart_rx_ff1 <= uart_rx_ff0;
        uart_rx_ff2 <= uart_rx_ff1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)
        rx_data <= 0;
    else if(cnt2>=1&&cnt2<9&&add_cnt1&&cnt1==2604-1)begin
        rx_data[cnt2-1] <= uart_rx_ff2;
    end 
end 

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)
        rx_vld <= 0;
    else if(cnt2=8&&add_cnt1&&cnt1==2604-1)begin
        rx_vld <= 1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag <= 0;
    end
    else if(uart_rx_ff2==1&&uart_rx_ff1==0)begin
        flag <= 1;
    end
    else if(end_cnt2)begin
        flag <= 0;
    end 
end
