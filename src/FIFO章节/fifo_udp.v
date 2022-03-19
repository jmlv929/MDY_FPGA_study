module fifo_udp(
    clk         ,
    rst_n       ,
    dest_port   ,
    sour_port   ,
    dest_ip     ,
    sour_ip     ,
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
    parameter   DATA_W          = 16            ;
    parameter   PORT_W          = 16            ;
    parameter   IP_W            = 32            ;
    parameter   HEAD_LEN_1B     = 8             ;
    parameter   HEAD_LEN_2B     = HEAD_LEN_1B/2 ;

    //输入信号定义
    input               clk                     ;
    input               rst_n                   ;

    input[PORT_W-1:0]   dest_port               ;
    input[PORT_W-1:0]   sour_port               ;
    input[IP_W-1:0]     dest_ip                 ;
    input[IP_W-1:0]     sour_ip                 ;

    input[DATA_W-1:0]   din                     ;
    input               din_vld                 ;
    input               din_sop                 ;
    input               din_eop                 ;

    //输出信号定义
    output[DATA_W-1:0]  dout                    ;
    output              dout_vld                ;
    output              dout_sop                ;
    output              dout_eop                ;

    //输出信号reg定义
    reg   [DATA_W-1:0]  dout                    ;
    reg                 dout_vld                ;
    reg                 dout_sop                ;
    reg                 dout_eop                ;

    //中间信号定义
    wire[DATA_W+1-1:0]  data_fifo_data          ;
    wire                data_fifo_rdreq         ;
    wire                data_fifo_wrreq         ;
    wire[DATA_W+1-1:0]  data_fifo_q             ;
    wire                data_fifo_q_eop         ;

    wire[31:0]          mes_fifo_data           ;  
    wire                mes_fifo_rdreq          ;
    reg                 mes_fifo_wrreq          ;  
    wire                mes_fifo_empty          ;  
    wire[31:0]          mes_fifo_q              ;

    reg[7:0]            cnt_wr                  ;
    wire                add_cnt_wr              ;
    wire                end_cnt_wr              ;

    reg[15:0]           data_len                ;
    reg[16:0]           data_check_sum_tmp      ;
    reg[15:0]           data_check_sum          ;
    reg                 flag_rd                 ;
    reg                 flag_data               ;
    reg[3:0]            cnt_head                ;
    wire                add_cnt_head            ;
    wire                end_cnt_head            ;
    reg                 end_cnt_head_ff0        ;
    wire[15:0]          udp_len                 ;      
    wire[15:0]          udp_check_sum           ;
    wire[PORT_W+PORT_W+16+16-1:0]                   head            ;         
    wire[IP_W+IP_W+16+17+PORT_W+PORT_W+17+17-1:0]   pse_head        ;     
    
    reg [16:0]          udp_check_sum0_0_tmp    ; 
    reg [16:0]          udp_check_sum0_1_tmp    ; 
    reg [16:0]          udp_check_sum0_2_tmp    ; 
    reg [16:0]          udp_check_sum0_3_tmp    ; 
    reg [16:0]          udp_check_sum0_4_tmp    ; 
    reg [16:0]          udp_check_sum0_0        ; 
    reg [16:0]          udp_check_sum0_1        ; 
    reg [16:0]          udp_check_sum0_2        ; 
    reg [16:0]          udp_check_sum0_3        ; 
    reg [16:0]          udp_check_sum0_4        ; 

    reg [16:0]          udp_check_sum1_0_tmp    ; 
    reg [16:0]          udp_check_sum1_1_tmp    ; 
    reg [16:0]          udp_check_sum1_2_tmp    ; 
    reg [16:0]          udp_check_sum1_0        ; 
    reg [16:0]          udp_check_sum1_1        ; 
    reg [16:0]          udp_check_sum1_2        ; 
    
    reg [16:0]          udp_check_sum2_0_tmp    ; 
    reg [16:0]          udp_check_sum2_1_tmp    ; 
    reg [16:0]          udp_check_sum2_0        ; 
    reg [16:0]          udp_check_sum2_1        ; 

    reg [16:0]          udp_check_sum3_0_tmp    ; 
    reg [15:0]          udp_check_sum3_0        ; 

    reg   [DATA_W-1:0]  dout_temp               ;
    reg                 dout_vld_temp           ;
    reg                 dout_sop_temp           ;
    reg                 dout_eop_temp           ;

    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    存数据的FIFO，首先将所有数据存到FIFO中
    **********www.mdy-edu.com 明德扬科教 注释结束****************/
    fifo_17b data_fifo(
	        .clock      (clk            ),
	        .data       (data_fifo_data ),
	        .rdreq      (data_fifo_rdreq),
	        .wrreq      (data_fifo_wrreq),
	        .empty      (data_fifo_empty),
	        .q          (data_fifo_q    )
    );
   
    assign data_fifo_wrreq = din_vld;
    //加上EOP，是为了读侧能够知道一个包文的结束
    assign data_fifo_data  = {din,din_eop};
    assign data_fifo_rdreq = flag_data && data_fifo_empty==1'b0;
    assign data_fifo_q_eop = data_fifo_rdreq && data_fifo_q[0];
    

    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    FIFO2
    //包文的信息就存储到信息FIFO
    //信息包括包文长度和数据部分的校验和,因为包文需要这两个信息
    **********www.mdy-edu.com 明德扬科教 注释结束****************/
    fifo_32b mes_fifo(
	        .clock      (clk           ),
	        .data       (mes_fifo_data ),
	        .rdreq      (mes_fifo_rdreq),
	        .wrreq      (mes_fifo_wrreq),
	        .empty      (mes_fifo_empty),
	        .q          (mes_fifo_q    )
    );

    assign mes_fifo_data  = {data_check_sum,data_len};      //高16位是UDP数据的校验和
    assign mes_fifo_rdreq = data_fifo_q_eop;                //当整个包文发送完的同时，读走信息FIFO一个数据。
    
    
    //信息FIFO的写使能，注意此时用了时序逻辑
    //数据校验和要晚一拍，为了对齐所以用时序逻辑
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            mes_fifo_wrreq <= 1'b0;
        end
        else begin
            mes_fifo_wrreq <= end_cnt_wr;
        end
    end
    
    //统计一个包文的长度，因为UDP包文头有一个长度信息
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
    assign  end_cnt_wr = add_cnt_wr && din_eop;
    
    
    
    //为了和校验和对齐，所以打一拍
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            data_len <= 0;
        end
        else if(end_cnt_wr) begin
            data_len <= {cnt_wr+1,1'b0};                //进来的数据一拍是2字节的，所以长度是要乘以2；
        end
    end
    
    
    //统计数据部分的校验和，UDP头有这部分内容
    always  @(*)begin
        if(din_vld && din_sop)
            data_check_sum_tmp = din;
        else
            data_check_sum_tmp = data_check_sum + din;
    end
    
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            data_check_sum <= 0;
        end
        else if(din_vld) begin
            data_check_sum <= data_check_sum_tmp[16] + data_check_sum_tmp[15:0];
        end
    end
    
    //flag_rd=1开始发送数据
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_rd <= 1'b0;
        end
        else if(flag_rd==1'b0 && mes_fifo_empty==1'b0) begin
            flag_rd <= 1'b1;
        end
        else if(data_fifo_q_eop)begin
            flag_rd <= 1'b0;
        end
    end
    
    //flag_data=1表示发送的是数据
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_data <= 1'b0;
        end
        else if(end_cnt_head) begin
            flag_data <= 1'b1;
        end
        else if(data_fifo_q_eop)begin
            flag_data <= 1'b0;
        end
    end
    
    
    //对发送的UDP首部进行计数
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cnt_head <= 0;
        end
        else if(add_cnt_head) begin
            if(end_cnt_head)
                cnt_head <= 0;
            else
                cnt_head <= cnt_head + 1;
        end
    end
    assign  add_cnt_head = flag_rd && flag_data==1'b0;
    assign  end_cnt_head = add_cnt_head && cnt_head==HEAD_LEN_2B-1;
    
    
    //组合成UDP首部和UDP伪首部，方便后面dout的产生

    assign  udp_len       = mes_fifo_q[15:0] + 8;                           //数据长度+8字节UDP首部
    assign  udp_check_sum = ~udp_check_sum3_0;
    assign  head          = {sour_port,dest_port,udp_len,udp_check_sum};    //8字节
    assign  pse_head      = {sour_ip,dest_ip,16'd17,udp_len,head};          //12+8字节
    
    //产生校验和：伪首部和数据总的校验和
    //此处用了3拍的流水，目的是寄存器之间最大只有1个16位的加法器
    //如果多个，就跑不了高速了

    
    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    流水线处理
    udp_check_sum3_0 <= mes_fifo_q[31:16] + pse_head[16*2-1 -:16] +
                        pse_head[16*3-1 -:16] + pse_head[16*4-1 -:16] +
                        pse_head[16*5-1 -:16] + pse_head[16*6-1 -:16] +
                        pse_head[16*7-1 -:16] + pse_head[16*8-1 -:16] +
                        pse_head[16*9-1 -:16] + pse_head[16*10-1 -:16]
                       
    以上等式，未考虑进位，若不用流水线处理，需考虑进位问题。
    **********www.mdy-edu.com 明德扬科教 注释结束****************/
    always  @(*)begin
        udp_check_sum0_0_tmp = mes_fifo_q[31:16]     + pse_head[16*2-1 -:16];
        udp_check_sum0_1_tmp = pse_head[16*3-1 -:16] + pse_head[16*4-1 -:16];
        udp_check_sum0_2_tmp = pse_head[16*5-1 -:16] + pse_head[16*6-1 -:16];
        udp_check_sum0_3_tmp = pse_head[16*7-1 -:16] + pse_head[16*8-1 -:16];
        udp_check_sum0_4_tmp = pse_head[16*9-1 -:16] + pse_head[16*10-1 -:16];
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            udp_check_sum0_0 <= 0;
            udp_check_sum0_1 <= 0;
            udp_check_sum0_2 <= 0;
            udp_check_sum0_3 <= 0;
            udp_check_sum0_4 <= 0;
        end
        else if(add_cnt_head && cnt_head==0) begin
            udp_check_sum0_0 <= udp_check_sum0_0_tmp[16]  + udp_check_sum0_0_tmp[15:0];
            udp_check_sum0_1 <= udp_check_sum0_1_tmp[16]  + udp_check_sum0_1_tmp[15:0];
            udp_check_sum0_2 <= udp_check_sum0_2_tmp[16]  + udp_check_sum0_2_tmp[15:0];
            udp_check_sum0_3 <= udp_check_sum0_3_tmp[16]  + udp_check_sum0_3_tmp[15:0];
            udp_check_sum0_4 <= udp_check_sum0_4_tmp[16]  + udp_check_sum0_4_tmp[15:0];
        end
    end
    
    
    always  @(*)begin
        udp_check_sum1_0_tmp = udp_check_sum0_0 + udp_check_sum0_1;
        udp_check_sum1_1_tmp = udp_check_sum0_2 + udp_check_sum0_3;
        udp_check_sum1_2_tmp = udp_check_sum0_4                   ;
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            udp_check_sum1_0 <= 0;
            udp_check_sum1_1 <= 0;
            udp_check_sum1_2 <= 0;
        end
        else if(add_cnt_head && cnt_head==1) begin
            udp_check_sum1_0 <= udp_check_sum1_0_tmp[16]  + udp_check_sum1_0_tmp[15:0];
            udp_check_sum1_1 <= udp_check_sum1_1_tmp[16]  + udp_check_sum1_1_tmp[15:0];
            udp_check_sum1_2 <= udp_check_sum1_2_tmp[16]  + udp_check_sum1_2_tmp[15:0];
        end
    end
    
    always  @(*)begin
        udp_check_sum2_0_tmp = udp_check_sum1_0 + udp_check_sum1_1;
        udp_check_sum2_1_tmp = udp_check_sum1_2                   ;
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            udp_check_sum2_0 <= 0;
            udp_check_sum2_1 <= 0;
        end
        else if(add_cnt_head && cnt_head==2) begin
            udp_check_sum2_0 <= udp_check_sum2_0_tmp[16]  + udp_check_sum2_0_tmp[15:0];
            udp_check_sum2_1 <= udp_check_sum2_1_tmp[16]  + udp_check_sum2_1_tmp[15:0];
        end
    end
    
    
    always  @(*)begin
        udp_check_sum3_0_tmp = udp_check_sum2_0 + udp_check_sum2_1;
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            udp_check_sum3_0 <= 17'hffff;                                               //初值要为17'hffff，取反后udp_check_sum为0；
        end
        else if(add_cnt_head && cnt_head==3) begin
            udp_check_sum3_0 <= udp_check_sum3_0_tmp[16]  + udp_check_sum3_0_tmp[15:0];
        end
    end

    /*********www.mdy-edu.com 明德扬科教 注释开始****************
    输出dout/dout_vld/dout_sop/dout_eop
    **********www.mdy-edu.com 明德扬科教 注释结束****************/ 
    //dout来自于首部和FIFO的数据
    //head = {sour_port,dest_port,udp_len,udp_check_sum};
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_temp <= 0;
        end
        else if(flag_rd) begin
            if(flag_data)
                dout_temp <= data_fifo_q[16:1];
            else
                dout_temp <= head[(HEAD_LEN_2B-cnt_head)*16-1 -:16];
        end
        else begin
            dout_temp <= 0;
        end
    end

    //dout
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 0;
        end
        else if(end_cnt_head_ff0)begin      
            dout <= udp_check_sum;
        end
        else begin
            dout <= dout_temp; 
        end
    end

    //end_cnt_head_ff0
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            end_cnt_head_ff0 <= 0;
        end
        else begin
            end_cnt_head_ff0 <= end_cnt_head;
        end
    end

    
    //首部第1个数据自然是SOP
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_sop_temp <= 0;
        end
        else if(add_cnt_head && cnt_head==0) begin
            dout_sop_temp <= 1'b1;
        end
        else begin
            dout_sop_temp <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_sop <= 0;
        end
        else begin
            dout_sop <= dout_sop_temp;
        end
    end
    
    //输出数据有效指示
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld_temp <= 1'b1;
        end
        else begin
            dout_vld_temp <= flag_rd;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld <= 1'b1;
        end
        else begin
            dout_vld <= dout_vld_temp;
        end
    end
    
    //输出包文的最后一个数据
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_eop_temp <= 1'b0;
        end
        else begin
            dout_eop_temp <= data_fifo_q_eop;
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_eop <= 1'b0;
        end
        else begin
            dout_eop <= dout_eop_temp;
        end
    end    
    
        
    
    endmodule
    
