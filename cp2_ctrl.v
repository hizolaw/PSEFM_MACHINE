`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2017 10:43:34 PM
// Design Name: 
// Module Name: cp2_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include"bus.vh"
`include"signal.vh"
`include"cp2.vh"


module cp2_ctrl(
    input   wire                    clk,
    input   wire                    rst,
    input   wire                    cp2_irenable_0,
    input   wire                    cp2_ts_0,
    input   wire                    cp2_fs_0,
    input   wire                    cp2_as_0,
    input   wire [`WORDDATABUS]     cp2_ir_0,
    //input   wire [`WORDDATABUS]     cp2_order_0,
    //output  wire                    cp2_tbusy_0,
    //output  wire                    cp2_fbusy_0,
    //output  wire                    cp2_abusy_0,
    input   wire                    cp2_tds_0,
    output  wire                    cp2_fds_0,
    input   wire [`WORDDATABUS]     cp2_tdata_0,
    output  reg  [`WORDDATABUS]     cp2_fdata_0,
    output  wire                    cp2_execs_0,
    output  wire                    cp2_exc_0,
    output  wire [`CP2EXCCODEBUS]   cp2_exccode_0,
    output  reg [`WORDDATABUS]  wr_data,

    output  wire [`WORDDATABUS]      g_time_h,
    output  wire [`WORDDATABUS]      g_time_l,
    
    /******mfc读的tr_寄存器的输出*******************/
    input   wire [`WORDDATABUS]      tr_regs_dout,
    /*****编号(number)和sel共同选择寄存器*****/
    output  reg  [`NumAddrBus]       tr_number,
    output  reg  [`NumAddrBus]       tr_r_number,
    output  reg                      tr_sel,
    output  reg                      tr_r_sel,
    output  reg                      tr_wea,
    output  reg                      tr_rea,
    output  reg  [`WORDDATABUS]      tr_regs_din,
    
    output  reg  [`TasksNumAddrBus]  task_sel,
    output  reg  [`TasksNumAddrBus]  task_sel_r,
    output  reg                      task_chs_ena,
    output  reg                      task_new_status,
    output  reg  [1:0]               task_aord_op,
    output  reg                      task_chcy_ena,
    output  reg                      task_chph_ena,
    output  reg                      task_chdeadline_ena,
    output  reg                      task_chcyen_ena,
    output  reg                      task_cyen_op,
    output  reg  [`WORDDATABUS]      task_write_data_input,
    output  reg                      task_trigger_op_ena,
    output  reg                      task_trigger_op,
    output  reg  [2:0]               task_info_sel,
    input   wire [`WORDADDRBUS]      task_info,
    input   wire  [`TasksNumAddrBusAddOne]  tt_top_pri_task, 
    input   wire  [`TasksNumAddrBusAddOne]  et_top_pri_task  //top privity task's privity 

);
    reg [`WORDDATABUS]  cp2_instruction_buf_1;
    reg [`WORDDATABUS]  cp2_instruction_buf_2;
    reg [`WORDDATABUS]  cp2_instruction_buf_3;
    
    reg decode_en;

    reg [`WORDADDRBUS]  reg_addr_1;
    reg tr_wr_en_1;
    reg io_wr_en_1;
    reg time_service_wr_en_1;
    reg tr_task_wr_1;
    reg [2:0] data_read_type_1;

    reg [`WORDADDRBUS]  reg_addr_2;
    reg tr_wr_en_2;
    reg io_wr_en_2;
    reg time_service_wr_en_2;
    reg tr_task_wr_2;
    reg [2:0] data_read_type_2;
    
    reg read_top_prioty_task;
    reg read_ttoret_task;

	wire [`REGADDRBUS]  fmt   = cp2_instruction_buf_1[`ISARDLOC]; 
	wire [12:0]  imm   = cp2_instruction_buf_1[15:3]; 
	wire [2:0]   sel   = cp2_instruction_buf_1[2:0]; 
    
    reg  [63:0]  g_time;
    assign  g_time_h=g_time[63:32];
    assign  g_time_l=g_time[31:0];



    //时间服务
    always @(negedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            g_time <= 64'b0;
        end else begin
            g_time <= g_time+1;
        end
    end



    // 取指令阶段
    always @(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            decode_en<=`DISABLE;
            cp2_instruction_buf_1<=`WORDDATAW'b0;
        end else begin
            if(cp2_irenable_0)begin
                cp2_instruction_buf_1<=cp2_ir_0;
                decode_en <=`ENABLE;
            end else begin
                decode_en<=`DISABLE;
                cp2_instruction_buf_1<=`WORDDATAW'b0;
            end
        end
    end

    // 译码阶段阶段
    always @(*)begin
        if(rst==`RESET_ENABLE)begin
            reg_addr_1=32'b0;
            tr_wr_en_1=`DISABLE;
            io_wr_en_1=`DISABLE;
            time_service_wr_en_1=`DISABLE;
            data_read_type_1=`CP2_NOSEL;
            tr_rea=`DISABLE;
            task_info_sel=`TASKNOSEL;
            task_sel_r=6'b0;
            read_top_prioty_task=`DISABLE;
            read_ttoret_task=0;
        end else begin
            reg_addr_1=32'b0;
            tr_wr_en_1=`DISABLE;
            io_wr_en_1=`DISABLE;
            time_service_wr_en_1=`DISABLE;
            data_read_type_1=`CP2_NOSEL;
            read_top_prioty_task=`DISABLE;
            read_ttoret_task=0;
            case(fmt)
                `MFC2_FMT       :begin
                    data_read_type_1=sel;
                    case(sel)
                        `CP2_TIMESEL:begin
                            reg_addr_1={31'b0,imm[0:0]};
                        end
                        `CP2_IOSEL  :begin// 读i/o,sel 为0
                            tr_r_number={1'b0,imm[3:0]};
                            tr_r_sel=0;
                            tr_rea=`ENABLE;
                            //if(imm[3:0]<4'd11)begin
                            //    reg_addr={28'b00,imm[3:0]};
                            //end
                        end
                        `CP2_TRSEL  :begin
                            tr_r_sel=1;
                            tr_r_number=imm[4:0];
                            tr_rea=`ENABLE;
                        end
                        `CP2_TASKSEL:begin
                            task_sel_r=imm[8:3];
                            task_info_sel=imm[2:0];
                        end
                        `CP2_GETTOPTASK:begin
                            
                        end
                        default:begin
                        end
                    endcase
                end
                `MTC2_FMT       :begin 
                    case(sel)
                        `CP2_TIMESEL:begin
                          reg_addr_1={31'b0,imm[0:0]};
                          time_service_wr_en_1=`ENABLE;
                        end
                        `CP2_IOSEL  :begin
                            if(imm[3:0]<4'd11)begin// i/o寄存器有11个，因此必须检查数量
                                reg_addr    ={28'b00,imm[3:0]};
                                io_wr_en_1  =`ENABLE;
                            end
                        end
                        `CP2_TRSEL  :begin
                            reg_addr_1={27'b0,imm[4:0]};
                            tr_wr_en_1=`ENABLE;
                        end
                        `CP2_TASKSEL:begin
                            reg_addr_1={20'b0,imm};
                            tr_task_wr_1=`ENABLE;
                        end
                        default:begin
                        end
                    endcase
                end
                `MTC2TC_FMT     :begin
                            reg_addr_1={27'b0,2'b01,imm[2:0]};//tr_readb_addr_base是8,所以高2位为2'b01
                            tr_wr_en_1=`ENABLE;
                end
                `TINIT_FMT      :begin
                end
                `TDEL_FMT       :begin
                end
                `TTTASK_FMT     :begin
                end
                `DISTTTASK_FMT  :begin
                end
                `CHTS           :begin
                end
                `SCHSTART       :begin//只需要传送指令
                end
                default         :begin
                end
            endcase
        end
    end
    
    always @(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            reg_addr_2<=`DISABLE;
            tr_wr_en_2<=`DISABLE;
            io_wr_en_2<=`DISABLE;
            time_service_wr_en_2<=`DISABLE;
            tr_task_wr_2<=`DISABLE;
            data_read_type_2<=`CP2_NOSEL;
        end else begin
            reg_addr_2<=reg_addr_1;
            if(cp2_fs_0)begin
                data_read_type_2<=data_read_type_1;
            end else begin
                data_read_type_2<=`CP2_NOSEL;
            end

            if(cp2_ts_0)begin
                tr_wr_en_2          <=tr_wr_en_1          ;
                io_wr_en_2          <=io_wr_en_1          ;
                time_service_wr_en_2<=time_service_wr_en_1;
                tr_task_wr_2        <=tr_task_wr_1        ;
            end else begin
                tr_wr_en_2<=`DISABLE;
                io_wr_en_2<=`DISABLE;
                time_service_wr_en_2<=`DISABLE;
                tr_task_wr_2<=`DISABLE;
            end

        end
    end

    // 写回阶段
    always @(negedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            cp2_fdata_0<=`WORD_DATA_W'b0;
        end else begin
            case(data_read_type_2)
                `CP2_TIMESEL:begin
                    cp2_fdata_0<=(reg_addr_1[0:0])?g_time_h:g_time_l;
                end
                `CP2_IOSEL  :begin
                    //cp2_fdata_0<=
                end
                `CP2_TRSEL  :begin
                end
                `CP2_TASKSEL:begin
                end
                default:begin
                end
            endcase
        end
    end

    always @(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
        end else begin
        end
    end


endmodule
