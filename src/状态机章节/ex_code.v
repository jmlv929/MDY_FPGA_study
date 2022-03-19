always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        state_c <= S0;
    end
    else begin
        state_c <= state_n;
    end
end

always  @(*)begin
    case(state_c)begin
        S00:begin
            if(start_s11)begin
                state_n = S11;
            end
            else begin
                state_n = state_c;
            end
        end
        S11:begin
            if(start_s21)begin
                state_n = S21;
            end
            else begin
                state_n = state_c;
            end
        end
        S21:begin
            if(start_s22)begin
                state_n = S22;
            end
            else beign
                state_n =state_c;
            end
        end
S22:begin
            if(start_s33)begin
                state_n = S33;
            end
            else beign
                state_n =state_c;
            end
        end
S33:begin
            if(start_s00)begin
                state_n = S00;
            end
            else beign
                state_n =state_c;
            end
        end

        default:begin
            state_n = S0;
        end
    endcase
end

assign start_s11 = state_c==S00  && end_cnt;
assign start_s21 = state_c==S11  && end_cnt;
assign start_s22 = state_c==S21  && end_cnt;
assign start_s33 = state_c==S22  && end_cnt;
assign start_s00 = state_c==S33  && end_cnt;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout0 <= 0;
    end
    else if(state_c == S00)begin
        dout0 <= 0;
    end
    else if(state_c == S11 || state_c==S21)begin
        dout0 <= 1;
end
    else if(state_c == S22)begin
        dout0 <= 2;
    end
    else if(state_c == S33)begin
        dout0 <= 3;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout1 <= 0;
    end
    else if(state_c == S00)begin
        dout1 <= 0;
    end
    else if(state_c == S11)begin
        dout1 <= 1;
end
    else if(state_c == S21|| state_c == S22)begin
        dout1 <= 2;
    end
    else if(state_c == S33)begin
        dout1 <= 3;
    end
end

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

assign   add_cnt = en;
assign   end_cnt = add_cnt = cnt==x-1;

always@(*)begin
if(state_c==S00)
    x = 1;
else if(state_c==S11)
    x = 2;
else if(state_c==S21)
    x = 2;
else if(state_c==S22)
    x = 2;
else 
    x = 3; 
end

