module sdram_ex5(
    clk    ,        //系统工作时钟100MHz
    rst_n  ,        //系统复位信号，低电平有效 

    wr_req ,        //写请求信号
    waddr  ,        //写地址输入
    wdata  ,        //写数据输入
    //wr_ack ,        //写应答输出

    rd_req ,        //读请求信号
    rw_ack ,        //读写应答信号

    cke    ,        //时钟使能信号
    cs     ,        //与SDRAM管脚相连的CS信号
    ras    ,        //与SDRAM管脚相连的RAS信号
    cas    ,        //与SDRAM管脚相连的CAS信号
    we     ,        //与SDRAM管脚相连的WE信号
    dqm    ,        //与SDRAM管脚相连的DQM信号
    addr   ,        //与SDRAM管脚相连的ADDR信号
    bank   ,        //与SDRAM管脚相连的BANK信号
    dq     ,        //与SDRAM管脚相连的DQ信号

    rdata  ,        //读数据输出
    rd_vld          //读数据有效指示信号
    );


    //参数定义
    parameter      DATA_W =         16  ;
    parameter      ADDR_W =         22  ;

    //*********************状态转移参数****************************
    parameter      S_IDLE      = 4'b0000;//IDLE状态
    parameter      S_NOP       = 4'b0001;//NOP
    parameter      S_PRECHARGE = 4'b0010;//预充电
    parameter      S_AUTOREF   = 4'b0011;//自动刷新
    parameter      S_LOAD      = 4'b0100;//加载模式
    parameter      S_ACTIVE    = 4'b0101;//激活
    parameter      S_READ      = 4'b0110;//读操作
    parameter      S_WRITE     = 4'b0111;//写操作
    
    //***********************命令参数*********************************
    parameter      C_NOP       = 4'b0111;//NOP
    parameter      C_PRECHARGE = 4'b0010;//预充电
    parameter      C_AUTO      = 4'b0001;//自动刷新
    parameter      C_LOAD      = 4'b0000;//加载模式寄存器
    parameter      C_ACTIVE    = 4'b0011;//激活
    parameter      C_READ      = 4'b0101;//读操作
    parameter      C_WRITE     = 4'b0100;//写操作
    
    //***********************时间参数*******************************    
    parameter      T100US      =         10_000            ;
    parameter      TRP         =         2                 ;
    parameter      TRC         =         6                 ;
    parameter      TMRD        =         2                 ;
    parameter      TRCD        =         2                 ;
    parameter      TWRITE      =         256               ;
    parameter      TREAD       =         256               ;
    parameter      TIME_1300   =         1300              ;
    parameter      TIME_1562   =         1562              ;

    parameter      CODE        =         12'b0000_0010_0111;                           //  M9 = 0 burst模式  M6 M5 M4 = 3'b010 输出延时为2个时钟周期
                                                                                       //  M3 = 0 burst类型（连续模式） M2 M1 M0 = 3'b111 全页模式

    //************************端口信号定义*************************
    input                   clk                 ;
    input                   rst_n               ;
    input                   rd_req              ;
    input                   wr_req              ;
    input  [ADDR_W-1:0]     waddr               ;
    input  [DATA_W-1:0]     wdata               ;    

    output                  rw_ack              ;
    //output                  wr_ack              ;
    output                  cke                 ;
    output                  cs                  ;
    output                  ras                 ;
    output                  cas                 ;
    output                  we                  ;
    output  [1:0]           dqm                 ;
    output  [11:0]          addr                ;
    output  [1:0]           bank                ;
    output  [DATA_W-1:0]    rdata               ;
    output                  rd_vld              ;
    
    inout   [DATA_W-1:0]    dq                  ;
    
    //************************信号类型定义**********************
    reg     [DATA_W-1:0]    rdata               ;
    reg                     rd_vld              ;
    reg                     rw_ack              ;
    //reg                     wr_ack              ;
    reg                     cke                 ;
    reg                     cs                  ;
    reg                     ras                 ;
    reg                     cas                 ;
    reg                     we                  ;
    reg      [1 :0]         dqm                 ;
    reg      [11:0]         addr                ;
    reg      [1 :0]         bank                ;
    wire      [DATA_W-1:0]   dq                 ;



    reg      [3:0]          state_c             ;
    reg      [3:0]          state_n             ;
    reg      [13:0]         cnt_sta_time        ;
    wire                    add_cnt_sta_time    ;
    wire                    end_cnt_sta_time    ; 
    reg      [13:0]         x                   ;
    reg      [10:0]         cnt_ref_time        ;
    wire                    add_cnt_ref_time    ;
    wire                    end_cnt_ref_time    ;
    //wire                    wait_ref            ;
    reg      [3:0]          command             ;
    reg      [ADDR_W-1:0]   addr_temp           ;
    reg                     init_flag           ;
    reg                     init_resh_cnt       ;
    reg                     rd_hty              ;
    reg                     rd_flag             ;
    reg                     wdata_en            ;
    reg      [DATA_W-1:0]   wdata_temp0         ;
    reg      [DATA_W-1:0]   wdata_temp1         ;
    reg      [DATA_W-1:0]   wdata_temp2         ;


    wire                    start_pre1          ; 
    wire                    start_aut1          ;
    wire                    start_aut2          ;
    wire                    start_load          ;
    wire                    start_idl2          ;   
    wire                    start_auto          ; 
    wire                    start_acti          ;  
    wire                    start_read          ; 
    wire                    start_write         ;
    wire                    start_pre2          ; 
    wire                    start_pre3          ; 
    wire                    start_idl3          ;
    wire                    start_idl1          ; 

    reg                     resh_flag           ;

    //三段式状态机
    //次态寄存器迁移到现态寄存器
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state_c <= S_NOP;
        end
        else begin
            state_c <= state_n;
        end
    end
    
    //状态转移条件判断
    always@(*)begin
        case(state_c)
            S_NOP:begin
                if(start_pre1)begin
                    state_n = S_PRECHARGE;
                end
                else begin
                    state_n = state_c;
                end
            end
            S_IDLE:begin
                if(start_auto)begin
                    state_n = S_AUTOREF;
                end
                else if(start_acti)begin
                    state_n = S_ACTIVE;
                end
                else begin
                    state_n = state_c;
                end
            end
            S_PRECHARGE:begin
                if(start_aut1)begin
                    state_n = S_AUTOREF;
                end
                else if(start_idl3)begin
                    state_n = S_IDLE;
                end
                else begin
                    state_n = state_c;
                end
            end
            S_AUTOREF:begin
                if(start_aut2)begin
                    state_n = S_AUTOREF;
                end
                else if(start_load)begin
                    state_n = S_LOAD;
                end
                else if(start_idl2)begin
                    state_n = S_IDLE;
                end
                else begin
                   state_n = state_c;
                end
            end
            S_LOAD:begin
                if(start_idl1)begin
                    state_n = S_IDLE;
                end
                else begin
                    state_n = state_c;
                end
            end
            S_ACTIVE:begin
                if(start_read)begin
                    state_n = S_READ;
                end
                else if(start_write)begin
                    state_n =S_WRITE;
                end
                else begin
                    state_n = state_c;
                end
            end
            S_READ:begin
                if(start_pre2)begin
                    state_n = S_PRECHARGE;
                end
                else begin
                    state_n = state_c;
                end
            end
            S_WRITE:begin
                if(start_pre3)begin
                    state_n = S_PRECHARGE;
                end
                else begin
                    state_n = state_c;
                end
            end
            default:begin
                state_n = S_IDLE;
            end
        endcase
    end
    
    assign start_pre1 = state_c==S_NOP       && end_cnt_sta_time                                    ;
    assign start_aut1 = state_c==S_PRECHARGE && end_cnt_sta_time && init_flag==1                    ;
    assign start_aut2 = state_c==S_AUTOREF   && end_cnt_sta_time && init_flag==1 && init_resh_cnt==0;
    assign start_load = state_c==S_AUTOREF   && end_cnt_sta_time && init_flag==1 && init_resh_cnt==1;
    assign start_idl1 = state_c==S_LOAD      && end_cnt_sta_time                                    ;      
    assign start_auto = state_c==S_IDLE      && resh_flag                                           ;   //优先级比读写优先级高，由状态机if else优先保证；
    assign start_idl2 = state_c==S_AUTOREF   && end_cnt_sta_time && init_flag==0                    ;
    assign start_acti = state_c==S_IDLE      && !end_cnt_ref_time && (rd_req || wr_req)             ; 
    assign start_read = state_c==S_ACTIVE    && end_cnt_sta_time && rd_flag==1                      ;
    assign start_write = state_c==S_ACTIVE    && end_cnt_sta_time && rd_flag==0                     ;
    assign start_pre2 = state_c==S_READ      && end_cnt_sta_time                                    ;
    assign start_pre3 = state_c==S_WRITE     && end_cnt_sta_time                                    ;
    assign start_idl3 = state_c==S_PRECHARGE && end_cnt_sta_time && init_flag==0                    ;
    
    //状态计数
    always @(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            cnt_sta_time <= 0;
        end
        else if(add_cnt_sta_time)begin
            if(end_cnt_sta_time)
                cnt_sta_time <= 0;
            else
                cnt_sta_time <= cnt_sta_time + 1;
        end
    end
    assign add_cnt_sta_time = state_c!=S_IDLE;       //加1条件；
    assign end_cnt_sta_time = add_cnt_sta_time && cnt_sta_time==x-1 ;       //结束条件、尾值；
   
    
    always  @(*)begin
        if(state_c==S_PRECHARGE)
            x = TRP;
        else if(state_c==S_AUTOREF)
            x = TRC;
        else if(state_c==S_LOAD)
            x = TMRD;
        else if(state_c==S_ACTIVE)
            x = TRCD;
        else if(state_c==S_READ)
            x = TREAD;
        else if(state_c==S_WRITE)
            x = TWRITE;
        else 
            x = T100US;
    end

    //自动刷新计数
    //always @(posedge clk or negedge rst_n)begin
    //   if (!rst_n)begin
    //       cnt_ref_time <= 0;
    //   end
    //   else if(wait_ref)begin
    //       cnt_ref_time <= cnt_ref_time;
    //   end
    //   else if(add_cnt_ref_time)begin
    //       if(end_cnt_ref_time)
    //           cnt_ref_time <= 0;
    //       else
    //           cnt_ref_time <= cnt_ref_time + 1;
    //   end
    //end

    //assign add_cnt_ref_time = !init_flag;                                           //在非初始化状态下，自动刷新开始计数
    //assign end_cnt_ref_time = add_cnt_ref_time && cnt_ref_time==TIME_1300-1;        //结束条件、尾值；
    //assign wait_ref         = state_c!=S_IDLE && cnt_ref_time==TIME_1300-1;

    //自动刷新计数
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cnt_ref_time <= 0;
        end
        else if(add_cnt_ref_time)begin
            if(end_cnt_ref_time)
                cnt_ref_time <= 0;
            else
                cnt_ref_time <= cnt_ref_time + 1;
        end
    end
    assign add_cnt_ref_time = !init_flag;                                           //在非初始化状态下，自动刷新开始计数
    assign end_cnt_ref_time = add_cnt_ref_time && cnt_ref_time==TIME_1562-1;        //结束条件、尾值；
    
    //resh_flag
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            resh_flag <= 0;
        end
        else if(end_cnt_ref_time) begin
            resh_flag <= 1;
        end
        else if(start_auto)begin
            resh_flag <= 0;
        end
    end
    

    //初始化标志信号init_flag
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            init_flag <= 1;
        end
        else if(start_idl1)begin
            init_flag <= 0;
        end
    end

    //初始化过程自动刷新计数init_resh_cnt
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            init_resh_cnt <= 0;
        end
        else if(start_aut2)begin
            init_resh_cnt <= 1;
        end
        else if(start_load)begin
            init_resh_cnt <= 0;
        end
    end

    //读写状态区分信号rd_flag；rd_flag=1允许进入读状态；rd_flag=0允许进入写状态
    //always  @(posedge clk or negedge rst_n)begin
    //    if(rst_n==1'b0)begin
    //        rd_flag <= 0;
    //    end
    //    else if(start_acti&&rd_req==1)begin
    //        rd_flag <= 1;
    //    end
    //    else if(start_acti&&rd_req==0&&wr_req==1)begin        //这里可以不要rd_req==0，因为if else 已经蕴含优先选择
    //        rd_flag <= 0;
    //    end
    //end

    //rd_hty,保存rd_flag的值，给下次同时来读写信号判断用。
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_hty <= 1'b0;
        end
        else if(state_c==S_PRECHARGE && init_flag==1'b0 && cnt_sta_time==0) begin       //在读写状态下的precharge状态下，将当前的rd_flag给rd_hty，指示当前响应的是读，还是写。
            rd_hty <= rd_flag;
        end
    end
    
    //读写状态区分信号rd_flag；rd_flag=1允许进入读状态；rd_flag=0允许进入写状态
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_flag <= 1'b0;
        end
        else if(start_acti) begin
            if(((rd_hty && wr_req==1'b0) || rd_hty==1'b0) && rd_req)                     //在active状态下——当收到读请求时，若要响应读有效，满足以下两个条件：1、上次响应了读，且此时写无效；2、上次响应了写；
                rd_flag <= 1'b1;
            else if(((rd_hty==1'b0 && rd_req==1'b0) || rd_hty) && wr_req)                //在active状态下——当收到写请求时，若要响应写有效，满足以下两个条件：1、上次响应了写，且此时读无效；2、上次响应了读；
                rd_flag <= 1'b0;
        end
    end
    

    //地址信号暂存寄存器addr_temp
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            addr_temp <= 0;
        end
        else if(wr_req || rd_req)begin
            addr_temp <= waddr;
        end
    end

    //读应答信号rw_ack
    always  @(*)begin
        rw_ack = start_acti;            //读写应答
    end

    //写应答信号wr_ack
    //always  @(*)begin
    //    wr_ack = start_acti;
    //end

    //有效使能信号cke
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cke <= 0;
        end
        else begin
            cke <= 1;
        end
    end

    //发送命令command
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            command <= C_NOP;
        end
        else if(start_pre1||start_pre2||start_pre3)begin
            command <= C_PRECHARGE;
        end
        else if(start_aut1||start_aut2||start_auto)begin
            command <= C_AUTO;
        end
        else if(start_load)begin
            command <= C_LOAD;
        end
        else if(start_acti)begin
            command <= C_ACTIVE;
        end
        else if(start_read)begin
            command <= C_READ;
        end
        else if(start_write)begin
            command <= C_WRITE;
        end
        else begin
            command <= C_NOP;
        end
    end

    //cs,ras,cas,we命令指示信号输出
    always  @(*)begin
         {cs,ras,cas,we} = command;
    end

    //dqm信号
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dqm <= 2'b11;
        end
        else if(init_flag==1)begin
            dqm <= 2'b11;
        end
        else begin
            dqm <= 2'b00;
        end
    end

    //bank选通信号
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            bank <= 2'b0;
        end
        else if(start_acti)begin
            bank <= waddr[21:20];
        end
      end

    //地址选通信号
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            addr <= 12'b0;
        end
        else if(start_pre1 || start_pre2 || start_pre3)begin
            addr <= (12'b1 << 10);
        end
        else if(start_load)begin
            addr <= CODE;
        end
        else if(start_acti)begin
            addr <= waddr[19:8];
        end
        else if(start_read||start_write)begin
            addr <= {4'b0,addr_temp[7:0]};
        end      
    end

    //写数据wdata延时三个时钟周期
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wdata_temp0 <= 0;
            wdata_temp1 <= 0;
            wdata_temp2 <= 0;
        end
        else begin
            wdata_temp0 <= wdata;
            wdata_temp1 <= wdata_temp0;
            wdata_temp2 <= wdata_temp1;
        end
    end

    //写数据使能
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wdata_en <= 0;
        end
        else if(start_write)begin
            wdata_en <= 1;
        end
        else if(state_c==S_WRITE && end_cnt_sta_time)begin
            wdata_en <= 0;
        end
    end
    
    assign dq = wdata_en ? wdata_temp2 : 16'hzzzz;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata <= 0;
        end
        else begin
            rdata <= dq;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_vld <= 0;
        end
        else if(state_c==S_READ && cnt_sta_time==2-1)begin
            rd_vld <= 1;
        end
        else if(state_c==S_PRECHARGE && cnt_sta_time==2-1)begin
            rd_vld <= 0;
        end
    end



    endmodule

