module fifo_cut(
    clk         ,
    rst_n       ,
    din         ,    
    din_vld     ,
    din_sop     ,
    din_eop     ,
    dout        ,
    dout_vld    ,
    dout_sop    ,
    dout_eop    
);

    //参数定义
    parameter   DATA_W  = 8         ;

    //输入信号定义
    input               clk         ;
    input               rst_n       ;
    input[DATA_W-1:0]   din         ;
    input               din_vld     ;
    input               din_sop     ;
    input               din_eop     ;

    //输出信号定义
    output[DATA_W-1:0]  dout        ;
    output              dout_vld    ;
    output              dout_sop    ;
    output              dout_eop    ;

    //输出信号reg定义
    reg   [DATA_W-1:0]  dout        ;
    reg                 dout_vld    ;
    reg                 dout_sop    ;
    reg                 dout_eop    ;

    //中间信号定义
    wire        data_fifo_wrreq     ;
    wire[11:0]  data_fifo_data      ;
    wire        data_fifo_rdreq     ;
    wire        data_fifo_empty     ;
    wire[11:0]  data_fifo_q         ;
    reg[11:0]   cnt_wr              ;
    wire        add_cnt_wr          ;
    wire        end_cnt_wr          ;
    wire        fir_cnt_wr          ;
    wire        data_fifo_q_eoc     ;
    wire        data_fifo_q_eop     ;
    wire        data_fifo_q_sop     ;
    wire        len_fifo_wrreq      ;
    wire[11:0]  len_fifo_data       ;
    wire        len_fifo_rdreq      ;
    wire        len_fifo_empty      ;
    wire[11:0]  len_fifo_q          ;
    reg         flag                ; 
    reg         flag_zero           ;
    wire        data_fifo_cell_end  ;
    wire        data_fifo_pack_end  ;
    wire        start_cnt_zero      ;
    reg[5:0]    cnt_zero            ;
    wire        add_cnt_zero        ;
    wire        end_cnt_zero        ;

    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    数据FIFO
    **********www.mdy-edu.com 明德扬科教 注释结束****************/
    fifo_12b data_fifo(
    	.clock   (clk            ),
    	.data    (data_fifo_data ),
    	.rdreq   (data_fifo_rdreq),
    	.wrreq   (data_fifo_wrreq),
        .empty   (data_fifo_empty),
    	.q       (data_fifo_q    )    
    );
    
    assign data_fifo_wrreq = din_vld;
    assign data_fifo_data  = {din,din_sop,din_eop,fir_cnt_wr,end_cnt_wr};
    
    assign data_fifo_rdreq = flag && data_fifo_empty==1'b0;
    
    //cnt_wr
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cnt_wr <= 0;
        end
        else if(add_cnt_wr) begin
            if(end_cnt_wr)
                cnt_wr <= 0;
            else
                cnt_wr <= cnt_wr + 1;
        end
    end
    
    assign  add_cnt_wr = din_vld;
    assign  end_cnt_wr = add_cnt_wr && ((cnt_wr==1500-1)|| din_eop);
    assign  fir_cnt_wr = add_cnt_wr && cnt_wr==0;
    assign  data_fifo_q_eoc = data_fifo_rdreq && data_fifo_q[0];
    assign  data_fifo_q_eop = data_fifo_rdreq && data_fifo_q[2];
    assign  data_fifo_q_sop = data_fifo_rdreq && data_fifo_q[3];
    

    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    长度FIFO
    **********www.mdy-edu.com 明德扬科教 注释结束****************/
    fifo_12b len_fifo(
    	.clock   (clk            ),
    	.data    (len_fifo_data  ),
    	.rdreq   (len_fifo_rdreq ),
    	.wrreq   (len_fifo_wrreq ),
        .empty   (len_fifo_empty ),
    	.q       (len_fifo_q     )    
    );
    
    assign len_fifo_wrreq = end_cnt_wr;
    assign len_fifo_data  = cnt_wr + 1;
    assign len_fifo_rdreq = (data_fifo_q_eoc && start_cnt_zero==1'b0) || end_cnt_zero;
    

    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    中间信号
    **********www.mdy-edu.com 明德扬科教 注释结束****************/
    //flag
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag <= 1'b0;
        end
        else if(flag==1'b0 && flag_zero==1'b0 && len_fifo_empty==1'b0) begin
            flag <= 1'b1;
        end
        else if(data_fifo_q_eoc)begin
            flag <= 1'b0;
        end
    end
    
    //flag_zero
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_zero <= 1'b0;
        end
        else if(start_cnt_zero) begin
            flag_zero <= 1'b1;
        end
        else if(end_cnt_zero)begin
            flag_zero <= 1'b0;
        end
    end
    
    assign start_cnt_zero      = data_fifo_q_eoc && len_fifo_q<46;
    
    //cnt_zero
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cnt_zero <= 0;
        end
        else if(add_cnt_zero) begin
            if(end_cnt_zero) 
                cnt_zero <= 0;
            else 
                cnt_zero <= cnt_zero + 1;
        end
    end
    
    assign add_cnt_zero = flag_zero;
    assign end_cnt_zero = add_cnt_zero && cnt_zero ==(46-len_fifo_q-1);
  

    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    输出
    **********www.mdy-edu.com 明德扬科教 注释结束****************/   
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 0;
        end
        else if(data_fifo_rdreq) begin
            dout <= data_fifo_q[11:4];
        end
        else begin
            dout <= 0;
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_sop <= 0;
        end
        else if(data_fifo_q_soc) begin
            dout_sop <= 1'b1;
        end
        else begin
            dout_sop <= 1'b0;
        end
    end
    assign  data_fifo_q_soc = data_fifo_rdreq && data_fifo_q[1];
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld <= 1'b1;
        end
        else if(data_fifo_rdreq || flag_zero) begin
            dout_vld <= 1'b1;
        end
        else begin
            dout_vld <= 1'b0;
        end
    end
    
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_eop <= 1'b0;
        end
        else if(end_cnt_zero || (data_fifo_q_eoc && start_cnt_zero==1'b0)) begin
            dout_eop <= 1'b1;
        end
        else begin
            dout_eop <= 1'b0;
        end
    end


    
    endmodule

