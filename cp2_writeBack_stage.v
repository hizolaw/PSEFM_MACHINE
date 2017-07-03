`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2017 07:12:59 PM
// Design Name: 
// Module Name: cp2_writeBack_stage
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

module cp2_writeBack_stage(
    input wire                      clk,
    input wire                      rst,
    input wire                      decode_ts,
    input wire                      cp2_tds_0,
    input wire [`WORDDATABUS]       cp2_tdata_0,
    input wire [`TasksNumAddrBus]   decode_task_sel 			,	
    input wire [1:0]                decode_task_aord_op			,	
    input wire                      decode_g_time_write_en		,    
    input wire                      decode_g_time_write_sel		,	
    input wire                      decode_ttr_w_sel			,	
    input wire [`NumAddrBus]        decode_ttr_w_number			,	
    input wire                      decode_ttr_wea				,    
    input wire                      decode_chcy_ena				,    
    input wire                      decode_chph_ena				,    
    input wire                      decode_chdeadline_ena		,	
    input wire                      decode_task_chs_ena         ,
    input wire                      decode_task_new_status      ,    
    input wire                      decode_task_trigger_op_ena  ,
    input wire                      decode_task_trigger_op      ,

    output reg [`TasksNumAddrBus]   task_sel 			,	
    output reg [1:0]                task_aord_op			,	
    output reg                      g_time_write_en		,    
    output reg                      g_time_write_sel		,	
    output reg                      ttr_w_sel			,	
    output reg [`NumAddrBus]        ttr_w_number			,	
    output reg                      ttr_wea				,    
    output reg                      chcy_ena				,    
    output reg                      chph_ena				,    
    output reg                      chdeadline_ena		,	
    output reg                      task_chs_ena         ,
    output reg                      task_new_status      ,    
    output reg                      task_trigger_op_ena  ,
    output reg                      task_trigger_op      ,
 
    output reg [`WORDDATABUS]       writeBack_data
    );
    always @(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            task_sel<=6'b0;
            task_aord_op<=2'b0;
            g_time_write_en<=`DISABLE;
            g_time_write_sel<=1'b0;
            ttr_w_sel<=0;
            ttr_w_number<=0;
            ttr_wea<=`DISABLE; 
            chcy_ena<=`DISABLE;
            chph_ena<=`DISABLE;
            chdeadline_ena<=`DISABLE; 
            task_chs_ena<=`DISABLE;
            task_new_status<=0;
            task_trigger_op_ena<=`DISABLE;
            task_trigger_op<=`DISABLE;
            writeBack_data <=`WORD_DATA_W'b0;               
        end else begin
            task_sel				<=decode_task_sel		      ;  	
            task_aord_op			<=decode_task_aord_op	;	
            g_time_write_sel		<=decode_g_time_write_sel;	
            ttr_w_sel				<=decode_ttr_w_sel		  ;  
            ttr_w_number			<=decode_ttr_w_number	  ;  
            chdeadline_ena			<=decode_chdeadline_ena	  ;   
            task_chs_ena			<=decode_task_chs_ena		  ;
            task_new_status			<=decode_task_new_status	  ;  
            task_trigger_op_ena		<=decode_task_trigger_op_ena ;  
            task_trigger_op			<=decode_task_trigger_op	  ;  
            writeBack_data          <=cp2_tdata_0;               
            if(cp2_tds_0&&decode_ts)begin
                g_time_write_en			<=decode_g_time_write_en	  ;  
                chph_ena				<=decode_chph_ena		      ;	
                chcy_ena				<=decode_chcy_ena	          ;	
                ttr_wea			    	<=decode_ttr_wea			  ;   
            end else begin
                g_time_write_en			<=`DISABLE	  ;  
                chph_ena				<=`DISABLE    ;	
                chcy_ena				<=`DISABLE    ;	
                ttr_wea			    	<=`DISABLE	  ;   
                //chdeadline_ena			<=decode_chdeadline_ena	  ;   
                //task_chs_ena			<=decode_task_chs_ena		  ;
            end
        end
    end

endmodule
