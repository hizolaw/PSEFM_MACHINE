`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2017 07:11:38 PM
// Design Name: 
// Module Name: cp2_decode_stage
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
`include "bus.vh"
`include "cp2.vh"
`include "signal.vh"


module cp2_decode_stage(
    input wire                      clk,
    input wire                      rst,
    input wire                      decode_en,
    input wire [`WORDDATABUS]       fetch_instruction,

    output reg                      time_info_sel,
    input wire [`WORDDATABUS]       time_dout,
 
    input wire [`WORDDATABUS]       write_back_fwd,

    output reg [2:0]                task_info_sel,
    output reg [`TasksNumAddrBus]   task_sel_r,
    input wire [`WORDDATABUS]       task_info,
    input wire [`DoubleWordDataBus] task_exist_list,
    input wire [`TasksNumAddrBusAddOne] tt_top_pri_task,  //top privity task's privity 
    input wire [`TasksNumAddrBusAddOne] et_top_pri_task,  //top privity task's privity 
    output reg                      ttr_r_sel,
    output reg [`NumAddrBus]        ttr_r_number,
    output reg                      ttr_rea,
    input wire [`WORDDATABUS]       ttr_dout,
    
    input   wire                    cp2_ts_0,
    input   wire                    cp2_fs_0,
    input   wire                    cp2_as_0,
    
    output  reg [`WORDDATABUS]      decode_fdata                ,
    output  reg                     decode_as       			,	
    output  reg                     decode_fs       			,	
    output  reg                     decode_ts       			,	
    output  reg [`TasksNumAddrBus]  decode_task_sel 			,	
    output  reg [1:0]               decode_task_aord_op			,	
    output  reg                     decode_g_time_write_en		,    
    output  reg                     decode_g_time_write_sel		,	
    output  reg                     decode_ttr_w_sel			,	
    output  reg [`NumAddrBus]       decode_ttr_w_number			,	
    output  reg                     decode_ttr_wea				,    
    output  reg                     decode_chcy_ena				,    
    output  reg                     decode_chph_ena				,    
    output  reg                     decode_chdeadline_ena		,	
    output  reg                     decode_task_chs_ena         ,
    output  reg                     decode_task_new_status      ,    
    output  reg                     decode_task_trigger_op_ena  ,
    output  reg                     decode_task_trigger_op      
    );
    wire [4:0]                      fmt;   
    wire [4:0]                      rt;   
    wire [12:0]                     imm;
    wire [2:0]                      sel;
    wire [`TasksNumAddrBusAddOne]   top_prioty;
    wire [`WORDDATABUS]             as_type_result;
    wire [`WORDDATABUS]             data_output;
    wire [`WORDDATABUS]             read_data_output;
    reg [1:0] read_data_src;
    reg  type_as;
    reg  type_ts;
    reg  type_fs;
    reg [5:0]  task_sel_buf;
    reg [1:0]  task_aord_op_buf;
    reg  task_trigger_op_ena_buf;
    reg  task_trigger_op_buf;
    reg  ttr_w_sel_buf1;
    reg [`NumAddrBus] ttr_w_number_buf1;
    reg ttr_wea_buf1;

    
    reg chs_ena_buf;
    reg new_status_buf;

    reg chcyen_ena_buf;
    reg chcy_op_buf;

    reg g_time_write_en_buf1;
    reg g_time_write_sel_buf1;

    reg  as_result_choose;

    reg  chcy_ena_buf1;
    reg  chph_ena_buf1;
    reg  chdeadline_ena_buf1;
                            

    reg [`WORDDATABUS]       fetch_instruction_bac;


    assign imm=fetch_instruction[15:3];
    assign sel=fetch_instruction[2:0];
    assign fmt=fetch_instruction[25:21];
    assign rt=fetch_instruction[20:16];
    assign top_prioty = imm[0:0] ?et_top_pri_task:tt_top_pri_task;

    two_port_mux as_output_mux(
        .choose(as_result_choose),
        .input1(32'b0),
        .input2(32'b1),
        .data_output(as_type_result)
    );
    four_port_mux read_data_mux(
        .choose(read_data_src),
        .input1(time_dout),
        .input2(ttr_dout),
        .input3(task_info),
        .input4({25'b0,top_prioty}),
        .data_output(read_data_output)
    );
    two_port_mux as_or_fs_data(
        .choose(type_as),
        .input1(read_data_output),
        .input2(as_type_result),
        .data_output(data_output)
    );
    always @(*)begin
        if(rst==`RESET_ENABLE)begin
            read_data_src=`READ_DATA_SRC_TIME;
            time_info_sel=0;
            ttr_r_sel=0;
            ttr_r_number=0;
            ttr_rea=`DISABLE;
            task_info_sel=0;
            task_sel_r=0;
            type_as=`DISABLE;
            type_ts=`DISABLE;
            type_fs=`DISABLE;
            task_sel_buf=6'b0;
            task_aord_op_buf=2'b00;
            as_result_choose=0;
            task_trigger_op_ena_buf=`DISABLE;
            task_trigger_op_buf=`DISABLE;
            chs_ena_buf=`DISABLE;
            new_status_buf=`DISABLE;
            g_time_write_en_buf1=`DISABLE;
            g_time_write_sel_buf1=0;
            ttr_w_sel_buf1=0;
            ttr_w_number_buf1=0;
            ttr_wea_buf1=`DISABLE;
            chcyen_ena_buf=`DISABLE;
            chcy_op_buf=0;
            chcy_ena_buf1=`DISABLE;
            chph_ena_buf1=`DISABLE;
            chdeadline_ena_buf1=`DISABLE;
        end else begin
            read_data_src=`READ_DATA_SRC_TIME;
            time_info_sel=0;
            ttr_r_sel=0;
            ttr_r_number=0;
            ttr_rea=`DISABLE;
            task_info_sel=0;
            task_sel_r=0;
            type_as=`DISABLE;
            type_ts=`DISABLE;
            type_fs=`DISABLE;
            task_sel_buf=6'b0;
            task_aord_op_buf=2'b00;
            as_result_choose=0;
            task_trigger_op_ena_buf=`DISABLE;
            task_trigger_op_buf=`DISABLE;
            chs_ena_buf=`DISABLE;
            new_status_buf=`DISABLE;
            g_time_write_en_buf1=`DISABLE;
            g_time_write_sel_buf1=0;
            ttr_w_sel_buf1=0;
            ttr_w_number_buf1=0;
            ttr_wea_buf1=`DISABLE;
            chcyen_ena_buf=`DISABLE;
            chcy_op_buf=0;
            chcy_ena_buf1=`DISABLE;
            chph_ena_buf1=`DISABLE;
            chdeadline_ena_buf1=`DISABLE;
            
            case(fmt)
                `MFC2_FMT       :begin
                    type_fs=`ENABLE;
                    case(sel)
                        `CP2_TIMESEL:begin
                            read_data_src=`READ_DATA_SRC_TIME;
                            time_info_sel=imm[0:0];
                        end
                        `CP2_IOSEL  ,// 读i/o,sel 为0
                        `CP2_TRSEL  :begin
                            read_data_src=`READ_DATA_SRC_TTR;
                            ttr_r_sel=sel[1:1];
                            ttr_r_number=imm[`NumAddrBus];
                            ttr_rea=`ENABLE;
                        end
                        `CP2_TASKSEL:begin
                            read_data_src=`READ_DATA_SRC_TASK;
                            task_info_sel=imm[8:6];
                            task_sel_r=imm[5:0];
                        end
                        `CP2_GETTOPTASK:begin
                            read_data_src=`READ_DATA_SRC_TOP_TASK;
                        end
                        default:begin
                        end
                    endcase
                end
                `MTC2_FMT       :begin 
                    type_ts=`ENABLE;
                    case(sel)
                        `CP2_TIMESEL:begin
                            g_time_write_en_buf1=`ENABLE;
                            g_time_write_sel_buf1=imm[0:0];
                        end
                        `CP2_IOSEL , 
                        `CP2_TRSEL  :begin
                            ttr_w_sel_buf1=sel[1:1];
                            ttr_w_number_buf1=imm[`NumAddrBus];
                            ttr_wea_buf1=`ENABLE;
                        end
                        `CP2_TASKSEL:begin
                            task_sel_buf=imm[5:0];
                            case(imm[8:6])
                                `TASKCYSEL:begin
                                    chcy_ena_buf1=`ENABLE;
                                end
                                `TASKPHSEL:begin
                                    chph_ena_buf1=`ENABLE;
                                end
                                `TASKDEADLINESEL:begin
                                    chdeadline_ena_buf1=`ENABLE;
                                end
                                default:begin
                                end
                            endcase
                        end
                        default:begin
                        end
                    endcase
                end
                `MTC2TC_FMT     :begin
                    type_ts=`ENABLE;
                    ttr_w_sel_buf1=1;
                    ttr_w_number_buf1={2'b01,imm[2:0]};
                    ttr_wea_buf1=`ENABLE;
                end
                `TINIT_FMT      :begin
                    type_as=`ENABLE;
                    task_sel_buf=fetch_instruction[5:0];
                    task_aord_op_buf=2'b11;
                end
                `TDEL_FMT       :begin
                    type_as=`ENABLE;
                    task_sel_buf=fetch_instruction[5:0];
                    task_aord_op_buf=2'b10;
                end
                `TTTASK_FMT     :begin
                    type_as=`ENABLE;
                    if(task_exist_list&(1<<fetch_instruction[5:0]))begin
                        task_sel_buf=fetch_instruction[5:0];
                        task_trigger_op_ena_buf=`ENABLE;
                        task_trigger_op_buf=`ENABLE;
                        as_result_choose=1;
                    end
                end
                `DISTTTASK_FMT  :begin
                    type_as=`ENABLE;
                    if(task_exist_list&(1<<fetch_instruction[5:0]))begin
                        task_sel_buf=fetch_instruction[5:0];
                        task_trigger_op_ena_buf=`ENABLE;
                        task_trigger_op_buf=`DISABLE;
                        as_result_choose=1;
                    end
                end
                `CHTS           :begin
                    type_as=`ENABLE;
                    if(task_exist_list&(1<<fetch_instruction[5:0]))begin
                        task_sel_buf=fetch_instruction[5:0];
                        chs_ena_buf=`ENABLE;
                        new_status_buf=fetch_instruction[0:0];
                    end
                end
                `CYTASK         :begin
                    type_as=`ENABLE;
                    if(task_exist_list&(1<<fetch_instruction[5:0]))begin
                        task_sel_buf=fetch_instruction[5:0];
                        chcyen_ena_buf=`ENABLE;
                        chcy_op_buf=fetch_instruction[0:0];
                    end
                end
                //`SCHSTART       :begin//只需要传送指令
                //    type_as=`ENABLE;
                //end
                default         :begin
                end
            endcase
        end
    end

    always @(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            decode_fdata<=`WORD_DATA_W'b0;
            decode_as<=`DISABLE;
            decode_fs<=`DISABLE;
            decode_ts<=`DISABLE;
            decode_task_sel<=6'b0;
            decode_task_aord_op<=2'b0;
            decode_g_time_write_en<=`DISABLE;
            decode_g_time_write_sel<=1'b0;
            decode_ttr_w_sel<=0;
            decode_ttr_w_number<=0;
            decode_ttr_wea<=`DISABLE; 
            decode_chcy_ena<=`DISABLE;
            decode_chph_ena<=`DISABLE;
            decode_chdeadline_ena<=`DISABLE; 
            decode_task_chs_ena<=`DISABLE;
            decode_task_new_status<=0;
            decode_task_trigger_op_ena<=`DISABLE;
            decode_task_trigger_op<=`DISABLE;
            fetch_instruction_bac<=`WORDDATAW'b0;
        end else begin
            fetch_instruction_bac<=fetch_instruction;
            if(decode_en)begin
                if(type_as&&cp2_as_0)begin
                    decode_as<=`ENABLE;
                    decode_ts<=`DISABLE;
                    decode_fs<=`DISABLE;
                    decode_fdata<=data_output;
                    decode_task_sel<=task_sel_buf;
                    decode_task_aord_op<=task_aord_op_buf;
                    decode_task_chs_ena<=chs_ena_buf;
                    decode_task_new_status<=new_status_buf;
                    decode_task_trigger_op_ena<=task_trigger_op_ena_buf;
                    decode_task_trigger_op<=task_trigger_op_buf;
                end else if(type_fs&&cp2_fs_0)begin
                    decode_fs<=`ENABLE;
                    decode_ts<=`DISABLE;
                    decode_as<=`DISABLE;
                    if(fetch_instruction_bac[25:21]==`MTC2_FMT&&fetch_instruction[15:0]==fetch_instruction_bac[15:0] &&decode_ts==`ENABLE)begin
                        decode_fdata<=write_back_fwd;//write back 的数据直通
                    end else begin
                        decode_fdata<=data_output;
                    end
                end else if(type_ts&&cp2_ts_0)begin
                    decode_ts<=`ENABLE;
                    decode_fs<=`DISABLE;
                    decode_as<=`DISABLE;
                    decode_g_time_write_en<=g_time_write_en_buf1;
                    decode_g_time_write_sel<=g_time_write_sel_buf1;
                    decode_ttr_w_sel<=ttr_w_sel_buf1;
                    decode_ttr_w_number<=ttr_w_number_buf1;
                    decode_ttr_wea<=ttr_wea_buf1; 
                    decode_task_sel<=task_sel_buf;
                    decode_chcy_ena<=chcy_ena_buf1;
                    decode_chph_ena<=chph_ena_buf1;
                    decode_chdeadline_ena<=chdeadline_ena_buf1; 
                end else begin//无操作
                    decode_as<=`DISABLE;
                    decode_fs<=`DISABLE;
                    decode_ts<=`DISABLE;
                    decode_fdata<=`WORD_DATA_W'b0;
                    decode_task_sel<=6'b0;
                    decode_task_aord_op<=2'b0;
                    decode_g_time_write_en<=`DISABLE;
                    decode_g_time_write_sel<=1'b0;
                    decode_ttr_w_sel<=0;
                    decode_ttr_w_number<=0;
                    decode_ttr_wea<=`DISABLE; 
                    decode_chcy_ena<=`DISABLE;
                    decode_chph_ena<=`DISABLE;
                    decode_chdeadline_ena<=`DISABLE; 
                    decode_task_chs_ena<=`DISABLE;
                    decode_task_trigger_op_ena<=`DISABLE;
                end
            end else begin//无操作
                decode_as<=`DISABLE;
                decode_fs<=`DISABLE;
                decode_ts<=`DISABLE;
                decode_fdata<=`WORD_DATA_W'b0;
                decode_task_sel<=6'b0;
                decode_task_aord_op<=2'b0;
                decode_g_time_write_en<=`DISABLE;
                decode_g_time_write_sel<=1'b0;
                decode_ttr_w_sel<=0;
                decode_ttr_w_number<=0;
                decode_ttr_wea<=`DISABLE; 
                decode_chcy_ena<=`DISABLE;
                decode_chph_ena<=`DISABLE;
                decode_chdeadline_ena<=`DISABLE; 
                decode_task_chs_ena<=`DISABLE;
                decode_task_trigger_op_ena<=`DISABLE;
            end
        end
    end


endmodule


module two_port_mux(
    input wire             choose,
    input wire [`WORDDATABUS]   input1,
    input wire [`WORDDATABUS]   input2,
    output wire [`WORDDATABUS]  data_output
);
    assign data_output=choose?input2:input1;
endmodule

module four_port_mux(
    input wire [1:0]            choose,
    input wire [`WORDDATABUS]   input1,
    input wire [`WORDDATABUS]   input2,
    input wire [`WORDDATABUS]   input3,
    input wire [`WORDDATABUS]   input4,
    output wire [`WORDDATABUS]  data_output
);
    assign data_output=(choose[0:0])?
                        (choose[1:1]?input4:input2):
                        (choose[1:1]?input3:input1);
endmodule
