module example1(
    input clk,
    input en,
    input aresetn,
    output dout
);

reg flag;
reg[3:0] cnt;

always@(posedge clk or negedge aresetn) begin
    if(!aresetn)
        flag <= 0;
    else if(en)
        flag <= 1; 
    else if(flag && cnt == 14 - 1)  //flag信号指示计数器增加条件  当已经计数14时候 把flag信号拉低
        flag <= 0;
    else 
        flag <= flag;
end

always@(posedge clk or negedge aresetn) begin
    if(!aresetn)
        cnt <= 0;
    else if(flag) begin
        if(cnt == 14 - 1)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

assign dout = flag && cnt != 0 && cnt != 2 && cnt != 5 && cnt != 9;

endmodule