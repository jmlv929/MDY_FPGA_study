module fifo3_top(
    rst_n       ,
    clk_a       ,
    data_a      ,
    data_a_vld  ,
    clk_b       ,
    data_b      ,
    data_b_vld  ,
    clk_c       ,
    data_c      ,
    data_c_vld  ,
    clk_rd      ,
    dout        ,
    channel     ,     
    dout_vld    ,
    err             
    );

    //��������
    parameter      W_DATA =         16;

    //�����źŶ���
    input               rst_n       ;

    input               clk_a       ;
    input[W_DATA-1:0]   data_a      ;
    input               data_a_vld  ; 

    input               clk_b       ;
    input[W_DATA-1:0]   data_b      ;
    input               data_b_vld  ; 

    input               clk_c       ;
    input[W_DATA-1:0]   data_c      ;
    input               data_c_vld  ;

    input               clk_rd      ; 

    //����źŶ���
    output[W_DATA-1:0]  dout        ;
    output              channel     ;     
    output              dout_vld    ;
    output              err         ;

    //����ź�reg����
    reg   [W_DATA-1:0]  dout        ;
    reg   [1:0]         channel     ;     
    reg                 dout_vld    ;
    reg                 err         ;

    //�м��źŶ���
    wire    aclr;
    wire[W_DATA-1:0]    q_a         ;
    wire                rdempty_a   ;
    wire                wrfull_a    ;
    wire[W_DATA-1:0]    q_b         ;
    wire                rdempty_b   ;
    wire                wrfull_b    ;
    wire[W_DATA-1:0]    q_c         ;
    wire                rdempty_c   ;
    wire                wrfull_c    ;
    reg                 rdreq_a     ;
    reg                 rdreq_b     ;
    reg                 rdreq_c     ;


    /*********www.mdy-edu.com ������ƽ� ע�Ϳ�ʼ****************
    ����3��fifo_a/fifo_b/fifo_c
    **********www.mdy-edu.com ������ƽ� ע�ͽ���****************/
    //fifo3_a
    fifo3 fifo3_a(
	    .aclr       (aclr      ),
	    .data       (data_a    ),
	    .rdclk      (clk_rd    ),
	    .rdreq      (rdreq_a   ),
	    .wrclk      (clk_a     ),
	    .wrreq      (data_a_vld),
	    .q          (q_a       ),
	    .rdempty    (rdempty_a ),
        .wrfull     (wrfull_a  )
    );

    //fifo3_b
    fifo3 fifo3_b(
	    .aclr       (aclr      ),
	    .data       (data_b    ),
	    .rdclk      (clk_rd    ),
	    .rdreq      (rdreq_b   ),
	    .wrclk      (clk_b     ),
	    .wrreq      (data_b_vld),
	    .q          (q_b       ),
	    .rdempty    (rdempty_b ),
        .wrfull     (wrfull_b  )
    );

    //fifo3_c
    fifo3 fifo3_c(
	    .aclr       (aclr      ),
	    .data       (data_c    ),
	    .rdclk      (clk_rd    ),
	    .rdreq      (rdreq_c   ),
	    .wrclk      (clk_c     ),
	    .wrreq      (data_c_vld),
	    .q          (q_c       ),
	    .rdempty    (rdempty_c ),
        .wrfull     (wrfull_c  )
    );

    //aclr
    assign aclr = ~rst_n;

    /*********www.mdy-edu.com ������ƽ� ע�Ϳ�ʼ****************
    ��fifo�Ķ��ź�
    **********www.mdy-edu.com ������ƽ� ע�ͽ���****************/
    //rdreq_a
    always  @(*)begin
        if(!rdempty_a)
            rdreq_a = 1;
        else
            rdreq_a = 0;
    end
    
    //rdreq_b
    always  @(*)begin
        if(rdempty_a && !rdempty_b)
            rdreq_b = 1;
        else
            rdreq_b = 0;
    end

    //rdreq_c
    always  @(*)begin
        if(rdempty_a && rdempty_b && !rdempty_c)
            rdreq_c = 1;
        else
            rdreq_c = 0;
    end

    /*********www.mdy-edu.com ������ƽ� ע�Ϳ�ʼ****************
    ���dout/dout_vld/channel
    **********www.mdy-edu.com ������ƽ� ע�ͽ���****************/
    //dout
    always  @(posedge clk_rd or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 0;
        end
        else if(rdreq_a)begin
            dout <= q_a;
        end
        else if(rdreq_b)begin
            dout <= q_b;
        end
        else if(rdreq_c)begin
            dout <= q_c;
        end
        else begin
            dout <= 0;
        end
    end

    //dout_vld
    always  @(posedge clk_rd or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld <= 0;
        end
        else begin
            dout_vld <= rdreq_a || rdreq_b || rdreq_c;
        end
    end

    //channel
    always  @(posedge clk_rd or negedge rst_n)begin
        if(rst_n==1'b0)begin
            channel <= 0;
        end
        else if(rdreq_a)begin
            channel <= 0;
        end
        else if(rdreq_b)begin
            channel <= 1;
        end
        else if(rdreq_c)begin
            channel <= 2;
        end
    end

    //err��fifo�������־���������ǲ�������ģ��˴�ֻΪ��֤��;
    //��˴�δ��ʱ���߼���ԭ�򡪡���Ϊ��fifo��wrfull���첽�źţ������ʱ���߼�����Ҫ���첽����(�������clk_rdͬ����)��������߼��޴����⣻
    always  @(*)begin
        err = wrfull_a || wrfull_b || wrfull_c;
    end




    endmodule

