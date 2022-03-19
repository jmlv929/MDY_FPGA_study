    fifo uut1(
	    .clock (clock1),
	    .data  (data1 ),
	    .rdreq (rdreq1),
	    .wrreq (wrreq1),
	    .empty (empty1),
	    .full  (full1 ),
	    .q     (q1    ),
	    .usedw (usedw1)
    );

    fifo uut2(
	    .clock (clock2),
	    .data  (data2 ),
	    .rdreq (rdreq2),
	    .wrreq (wrreq2),
	    .empty (empty2),
	    .full  (full2 ),
	    .q     (q2    ),
	    .usedw (usedw2)
    );


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

    assign add_cnt = din_vld;
    assign end_cnt = add_cnt && din_eop;

    assign wrreq1 = din_vld;
    assign data1  = {din[7:0],din_eop};

    assign wrreq2 = end_cnt;
    assign data2  = cnt + 1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdreq1 <= 1'b0;
        end
        else if(start)begin
            rdreq1 <= 1'b1;
        end
        else if(rdreq2)begin
            rdreq1 <= 1'b0;
        end
    end

    assign start  = rdreq1==0 && empty2==0;
    assign rdreq2 = rdreq1==1 && q1[0] ==1;

   

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 8'b0;
        end
        else if(start)begin
            dout <= q2;                                        //这时候rdreq2，还没拉高，dout只能读到q2的数，q2还是保持原来的数。     
        end                                                    //start 和 rdreq2 不是一个时刻。
        else if(rdreq1)begin
            dout <= q1[8:1];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld <= 1'b0;
        end
        else if(start || rdreq1)begin
            dout_vld <= 1'b1;
        end
        else begin
            dout_vld <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_sop <= 1'b0;
        end
        else if(start)begin
            dout_sop <= 1'b1;
        end
        else begin
            dout_sop <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_eop <= 1'b0;
        end
        else if(rdreq2)begin
            dout_eop <= 1'b1;
        end
        else begin
            dout_eop <= 1'b0;
        end
    end

