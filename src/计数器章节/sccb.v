module sccb(
    clk         ,
    rst_n       ,
    addr        ,
    wr_en       ,
    wdata       ,
    rd_en       ,
    rdata       ,
    rdata_vld   ,
    rdy         ,  
    sclk        ,
    sda_out     ,
    sda_out_en  ,
    sda_in        
    );

    //参数定义
    parameter     IDWADD         =  8'h42;
    parameter     IDRADD         =  8'h43;
    parameter     SCLK_TIME      =  400  ;
    parameter     SCLK_HALF_TIME =  SCLK_TIME/2  ;
    parameter     SCLK_W_TIME    =  SCLK_TIME/4  ;
    parameter     SCLK_R_TIME    =  (SCLK_TIME/4)*3 ;

    //输入信号定义
    input               clk      ;
    input               rst_n    ;
    input [7:0]         addr     ;
    input [7:0]         wdata    ;
    input               wr_en    ;
    input               rd_en    ;
    input               sda_in   ;
    output[7:0]         rdata    ;
    output              rdata_vld;
    output              rdy      ;
    output              sda_out  ;
    output              sda_out_en;
    output              sclk     ;
    
    reg   [7:0]         rdata    ;
    reg                 rdata_vld;
    reg                 rdy      ;
    reg                 sda_out  ;
    reg                 sda_out_en;
    reg                 sclk     ;

    reg [8:0]           sclk_cnt  ;
    reg [5:0]           byte_cnt  ;
    reg [1:0]           step_cnt ;
    reg                 work_flag;
    reg [5:0]           byte_num/*synthesis keep*/;
    reg                 rd_flag ;
    reg [7:0]           subadd  ;
    reg [7:0]           wdata_ff0;
    wire                add_sclk;
    wire                end_sclk;
    wire                add_byte;
    wire                end_byte;
    wire                add_step;
    wire                end_step;
    reg [29:0]          wdata_tmp;
    reg [1:0]           step_num;

    wire                wr_state    ; 
    wire                rd_state    ; 
    wire                rd_0_state  ; 
    wire                rd_1_state  ; 
    wire                rd_get_state; 
    wire                en;
    wire                start_area;
    wire                stop_area ;
    wire                sclk_h2l  ;
    wire                sclk_l2h  ;
    wire                sda_send;
    wire                sda_get ;


    assign  add_sclk = work_flag;
    assign  end_sclk = sclk_cnt==SCLK_TIME-1 && work_flag;
    always@(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sclk_cnt <= 0;
        end
        else if(work_flag) begin
            if(end_sclk)
                sclk_cnt <= 0;
            else
                sclk_cnt <= sclk_cnt + 1;
        end
        else begin
            sclk_cnt <= 0;
        end
    end



    assign add_byte     = end_sclk;
    assign end_byte     = add_byte && byte_cnt==byte_num-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            byte_cnt  <= 0;
        end
        else if(add_byte) begin
            if(end_byte) 
                byte_cnt <= 0;
            else 
                byte_cnt <= byte_cnt + 1;
        end
    end


    assign  add_step = end_byte; 
    assign  end_step = add_step && step_cnt==step_num-1;
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            step_cnt <= 0;
        end
        else if(add_step)begin
            if(end_step)
                step_cnt <= 0;
            else 
                step_cnt <= step_cnt + 1;
        end
    end

    assign en = work_flag==1'b0 && (wr_en || rd_en);


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            work_flag <= 1'b0;
        end
        else if(en) begin
            work_flag <= 1'b1;
        end
        else if(end_step)begin
            work_flag <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_flag <= 1'b0;
        end
        else if(rd_en) begin
            rd_flag <= 1'b1;
        end
        else if(wr_en)begin
            rd_flag <= 1'b0;
        end
    end

    




    assign  wr_state     = work_flag && rd_flag==1'b0;
    assign  rd_state     = work_flag && rd_flag;
    assign  rd_0_state   = rd_state && step_cnt==0;
    assign  rd_1_state   = rd_state && step_cnt==1;
    assign  rd_get_state = rd_1_state && byte_cnt >=10 && byte_cnt<18;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            subadd    <=0;
            wdata_ff0 <= 0;
        end
        else if(en) begin
            subadd    <= addr;
            wdata_ff0 <= wdata;
        end
    end


    always  @(*)begin
        if(wr_state)begin
            wdata_tmp = {1'b0,IDWADD,1'b1,subadd,1'b1,wdata_ff0,1'b1,1'b0,1'b1};
            byte_num  = 30;
            step_num  = 1;
        end
        else if(rd_0_state)begin
            wdata_tmp = {1'b0,IDWADD,1'b1,subadd,1'b1,1'b0,1'b1,9'b0};
            byte_num  = 21;
            step_num  = 2;
        end
        else begin 
            wdata_tmp = {1'b0,IDRADD,1'b1,8'b0,  1'b1,1'b0,1'b1,9'b0};
            byte_num  = 21;
            step_num  = 2;
        end
    end



    assign  start_area = add_sclk && byte_cnt==0;
    assign  stop_area  = add_sclk && byte_cnt==byte_num-1;

    assign  sclk_h2l   = add_sclk && sclk_cnt==0 && ((!start_area) && (!stop_area));
    assign  sclk_l2h   = add_sclk && sclk_cnt==SCLK_HALF_TIME-1;


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sclk <= 1'b1;
        end
        else if(sclk_h2l) begin
            sclk <= 1'b0;
        end
        else if(sclk_l2h)begin
            sclk <= 1'b1;
        end
    end



    assign  sda_send = add_sclk && sclk_cnt==SCLK_W_TIME-1 && rd_get_state==1'b0;
    assign  sda_get  = add_sclk && sclk_cnt==SCLK_R_TIME-1 && rd_get_state;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sda_out <= 1'b1;
        end
        else if(sda_send)begin
            sda_out <= wdata_tmp[29-byte_cnt];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sda_out_en <= 1'b0;
        end
        else if(work_flag && rd_get_state==1'b0) begin
            sda_out_en <= 1'b1;
        end
        else begin
            sda_out_en <= 1'b0;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata <= 1'b0;
        end
        else if(rd_get_state && sda_get) begin
            rdata <= {rdata[6:0],sda_in};
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata_vld <= 1'b0;
        end
        else if(end_step && rd_1_state) begin
            rdata_vld <= 1'b1;
        end
        else begin
            rdata_vld <= 1'b0;
        end
    end

    always  @(*)begin
        if(work_flag || rd_en || wr_en)
            rdy = 1'b0;
        else
            rdy = 1'b1;
    end


endmodule

