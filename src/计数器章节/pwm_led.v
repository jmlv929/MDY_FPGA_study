parameter  TIME_1S  = 100_000_000   ;
always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        cnt_1s <= 0;
    end
    else if(add_cnt_1s)begin
        if(end_cnt_1s)
            cnt_1s <= 0;
        else
            cnt_1s <= cnt_1s + 1;
    end
end

assign add_cnt_1s = 1'b1;
assign end_cnt_1s = add_cnt_1s && cnt_1s==TIME_1S-1;

always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        cnt_10s <= 0;
    end
    else if(add_cnt_10s)begin
        if(end_cnt_10s)
            cnt_10s <= 0;
        else
            cnt_10s <= cnt_10s + 1;
    end
end

assign add_cnt_10s = end_cnt_1s;
assign end_cnt_10s = add_cnt_10s && cnt_10s==10-1;

always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[0] <= 0;
    end
    else if(led_on)begin
        led[0] <= 0;
    end
    else if(led0_off)begin
        led[0] <= 1;
    end
end

assign led0_off = add_cnt_10s && cnt_10s==1-1;
assign led_on  = add_cnt_10s && cnt_10s==10-1;

always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[1] <= 0;
    end
    else if(led_on)begin
        led[1] <= 0;
    end
    else if(led1_off)begin
        led[1] <= 1;
    end
end

assign led1_off = add_cnt_10s && cnt_10s==2-1;

always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[2] <= 0;
    end
    else if(led_on)begin
        led[2] <= 0;
    end
    else if(led2_off)begin
        led[2] <= 1;
    end
end

assign led2_off = add_cnt_10s && cnt_10s==3-1;

always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[3] <= 0;
    end
    else if(led_on)begin
        led[3] <= 0;
    end
    else if(led3_off)begin
        led[3] <= 1;
    end
end

assign led3_off = add_cnt_10s && cnt_10s==4-1;
always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[4] <= 0;
    end
    else if(led_on)begin
        led[4] <= 0;
    end
    else if(led4_off)begin
        led[4] <= 1;
    end
end

assign led4_off = add_cnt_10s && cnt_10s==5-1;

always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[5] <= 0;
    end
    else if(led_on)begin
        led[5] <= 0;
    end
    else if(led5_off)begin
        led[5] <= 1;
    end
end

assign led5_off = add_cnt_10s && cnt_10s==6-1;
always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[6] <= 0;
    end
    else if(led_on)begin
        led[6] <= 0;
    end
    else if(led6_off)begin
        led[6] <= 1;
    end
end

assign led6_off = add_cnt_10s && cnt_10s==7-1;

always  @(posedgeclk or negedgerst_n)begin
    if(rst_n==1'b0)begin
        led[7] <= 0;
    end
    else if(led_on)begin
        led[7] <= 0;
    end
    else if(led7_off)begin
        led[7] <= 1;
    end
end

assign led7_off = add_cnt_10s && cnt_10s==8-1;

