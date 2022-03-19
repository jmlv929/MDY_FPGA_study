always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hs_cnt <= 0;
    end
    else if(add_ hs_cnt)begin
        if(end_ hs_cnt) begin
            hs_cnt <= 0;
        end 
        else begin
            hs_cnt <= hs_cnt+1;
        end
    end
end

assign add_ hs_cnt = 1;
assign end_ hs_cnt = add_ hs_cnt&& hs_cnt==800-1;

always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        vs_cnt <= 0;
    end
    else if(add_ vs_cnt)begin
        if(end_ vs_cnt) begin
            vs_cnt <= 0;
        end 
        else begin
            vs_cnt <= vs_cnt+1;
        end
    end
end

assign add_ vs_cnt = end_hs_cnt;
assign end_ vs_cnt = add_ vs_cnt&&vs_cnt==525-1;

assign hs_rise = add_hs_cnt && hs_cnt == 10'd95;
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hys <= 1;
    end
    else if(hs_rise)begin
        hys <= 1;
    end
    else if(end_hs_cnt)begin
        hys <= 0;
    end
end

assign vs_rise = add_vs_cnt && vs_cnt == 1'd1;
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        vys <= 1;
    end
    else if(vs_rise)begin
        vys <= 1;
    end
    else if(end_vs_cnt)begin
        vys <= 0;
    end
end

parameter    X0      = 141;
parameter    X1      = 787;
parameter    Y0      = 32 ;
parameter    Y1      = 516;  
parameter    X_CENT  = 464;
parameter    Y_CENT  = 274;
parameter    GREEN   = 8'b000_111_00;
parameter    BLACK   = 8'b000_000_00;

assign valid_area = add_hs_cnt && hs_cnt>=X0 && hs_cnt<X1 && vs_cnt>=Y0 && vs_cnt<Y1;
assign green_area = valid_area && (hs_cnt>=X_CENT-100  && hs_cnt<X_CENT+100 && vs_cnt>=Y_CENT-100  &&vs_cnt<Y_CENT+100);
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rgb_data <= 8'h00;
    end
    else if(valid_area)begin
        if(green_area)begin
            rgb_data <= GREEN;
        end
        else begin
            rgb_data <= BLACK;
        end
    end
    else begin
        rgb_data <= 8'h00;
    end
end

