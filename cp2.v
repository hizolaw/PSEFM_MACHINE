`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2017 04:31:15 PM
// Design Name: 
// Module Name: cp2
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
module cp2(
    input   wire                    clk,
    input   wire                    rst,
    input   wire                    cp2_irenable_0,
    input   wire                    cp2_ts_0,
    input   wire                    cp2_fs_0,
    input   wire                    cp2_as_0,
    input   wire [`WORDDATABUS]     cp2_ir_0,
    //input   wire [`WORDDATABUS]   cp2_order_0,
    output  reg                    cp2_tbusy_0,
    output  reg                    cp2_fbusy_0,
    output  reg                    cp2_abusy_0,
    input   wire                    cp2_tds_0,
    output  wire                    cp2_fds_0,
    input   wire [`WORDDATABUS]     cp2_tdata_0,
    output  wire [`WORDDATABUS]     cp2_fdata_0,
    output  reg                    cp2_excs_0,
    output  reg                    cp2_exc_0,
    output  reg [`CP2EXCCODEBUS]   cp2_exccode_0,
    inout   wire [`WORDDATABUS]     io_pin
    );
    assign clk_ = ~clk;
    
    reg [63:0] g_time;
    wire [`WORDDATABUS] g_time_l;
    wire [`WORDDATABUS] g_time_h;
    //wire [`WORDDATABUS] g_time_write_data;
    wire time_info_sel;
    wire [`WORDDATABUS]  time_dout;

    wire [`WORDDATABUS]   fetch_instruction;
    wire                  decode_en;
    wire [`WORDDATABUS]   decode_fdata;

    wire [2:0]            task_info_sel;
    wire [`WORDDATABUS]   task_info;
    wire [`DoubleWordDataBus] task_exist_list;

    //wire [`WORDDATABUS]g_time;
    wire [`NumAddrBus]ttr_r_number;
    wire [`NumAddrBus]ttr_w_number;
    wire  ttr_r_sel;
    wire  ttr_w_sel;
    wire  ttr_wea;
    wire  ttr_rea;
    wire [`WORDDATABUS]ttr_din;
    wire [`WORDDATABUS]ttr_dout;
    wire  [`TasksNumAddrBusAddOne] tt_top_pri_task;  //top privity task's privity 
    wire  [`TasksNumAddrBusAddOne] et_top_pri_task;  //top privity task's privity 
    reg   [`TasksNumAddrBusAddOne] pre_tt_top_pri_task;  //top privity task's privity 
    
    wire [`TasksNumAddrBus]  decode_task_sel 		;	
    wire [1:0]               decode_task_aord_op	;	
    wire                     decode_g_time_write_en	;    
    wire                     decode_g_time_write_sel;	
    wire                     decode_ttr_w_sel		;	
    wire [`NumAddrBus]       decode_ttr_w_number	;	
    wire                     decode_ttr_wea			;    
    wire                     decode_chcy_ena		;    
    wire                     decode_chph_ena		;    
    wire                     decode_chdeadline_ena	;
    wire                     decode_task_chs_ena    ;
    wire                     decode_task_new_status ;   
    wire                     decode_task_trigger_op_ena;
    wire                     decode_task_trigger_op ; 

    wire [`TasksNumAddrBus]   task_sel 			;	
    wire [`TasksNumAddrBus]   task_sel_r 			;	
    wire [1:0]                task_aord_op			;	
    wire                      g_time_write_en		;    
    wire                      g_time_write_sel		;	
    wire                      chcy_ena				;    
    wire                      chph_ena				;    
    wire                      chdeadline_ena		;	
    wire                      task_chs_ena         ;
    wire                      task_new_status      ;    
    wire                      task_trigger_op_ena  ;
    wire                      task_trigger_op      ;
 
    wire [`WORDDATABUS]       writeBack_data        ;

    wire [`DoubleWordDataBus]   deadline_warn;


    assign g_time_l=g_time[31:0];
    assign g_time_h=g_time[63:32];
    assign time_dout=time_info_sel?g_time[63:32]:g_time[31:0];

    //assign g_time_write_en=decode_g_time_write_en;
    //assign g_time_write_sel=decode_g_time_write_sel;
    
    
    // time trigger task queue status transfer to not empty from empty.
    always @(negedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            pre_tt_top_pri_task<=64;
            cp2_excs_0<=`ENABLE;
            cp2_exc_0<=`DISABLE;
            cp2_exccode_0<=`CP2EXECCODE_TTTASK;
            cp2_tbusy_0<=`DISABLE;
            cp2_fbusy_0<=`DISABLE;
            cp2_abusy_0<=`DISABLE;
        end else begin
            pre_tt_top_pri_task<=tt_top_pri_task;
            if(pre_tt_top_pri_task==64&&tt_top_pri_task!=64)begin
                cp2_exc_0<=`ENABLE;
            end else begin
            //    cp2_execs_0<=`DISABLE;
                cp2_exc_0<=`DISABLE;
            end
        end
    end


    always @(negedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            g_time<=`DOUBLEWORD_DATA_W'b0;
        end else begin
            if(g_time_write_en)begin
                if(g_time_write_sel)
                    g_time[63:32]<=writeBack_data;
                else
                    g_time[31:0]<=writeBack_data;
            end else begin
                g_time<=g_time+1;
            end
        end
    end
    
    time_trigger_regs time_trigger_regs(
        .rst(rst),
        .clk(clk_),
        .g_time(g_time_l),
        .r_number(ttr_r_number),
        .w_number(ttr_w_number),
        .r_sel(ttr_r_sel),
        .w_sel(ttr_w_sel),
        .wea(ttr_wea),
        .rea(ttr_rea),
        .din(writeBack_data),
        .dout(ttr_dout),
        .data(io_pin)
    );
    time_trigger_tasks time_trigger_tasks(
        .clk			        (clk_			),
        .rst			        (rst			),                  // reset
        .task_sel			    (task_sel),       //要求修改或输出的当前的任务
        .task_sel_r			    (task_sel_r		),       //要求修改或输出的当前的任务
        .g_time			        (g_time_l			),//全局时间
        .chs_ena			    (task_chs_ena		),          //任务状态修改enable
        .new_status			    (decode_task_new_status		),      //新的任务的状态：挂起或就绪
        .task_aord_op			(task_aord_op	), //添加/删除任务，高位使能要求操作，低位1为添加，0为删除
        .chcy_ena			    (chcy_ena		),   //改变周期掩码使能
        .chph_ena			    (chph_ena		),   //change the phase enable
        .chdeadline_ena			(chdeadline_ena	),   //change the deadline enable
        .chcyen_ena			    (task_trigger_op_ena		), //改变是否周期使能  目前，只要是时间触发，都是周期使能
        .cyen_op			    (task_trigger_op		),
        .task_write_data_input	(writeBack_data),//new phase
        .trigger_op_ena			(task_trigger_op_ena	),  //time trigger enable edit enable
        .trigger_op			    (task_trigger_op		),  // new time tirgger status
        //.running_task			(task_running_task	),
        .info_sel			    (task_info_sel		),//0:周期信息，1：相位信息，2：死线信息，3：任务是否周期，4：任务时间触发，5：任务状态，6：任务是否存在,7：返回0
        .task_info			    (task_info		),
        .tt_top_pri_task		(tt_top_pri_task),  //top privity task's privity 
        .et_top_pri_task		(et_top_pri_task),  //top privity task's privity 
        .deadline_warn          (deadline_warn),// when it's high			(),at least one task arrive deadline
        .task_exist_list_output (task_exist_list)
    );

    cp2_fetch_ins_stage cp2_fetch_ins_stage(
       .clk		            (clk),
       .rst		            (rst),
       .irenable		    (cp2_irenable_0),
       .ir		            (cp2_ir_0),
       .fetch_instruction	(fetch_instruction),
       .decode_en           (decode_en)
    );

    cp2_decode_stage  cp2_decode_stage(
        .clk                (clk),
        .rst                (rst),
        .decode_en          (decode_en),
        .fetch_instruction  (fetch_instruction),
        
        .time_info_sel		(time_info_sel	),
        .time_dout          (time_dout      ),
        
        .task_info_sel		(task_info_sel	),
        .task_info		    (task_info		),
        .task_sel_r		    (task_sel_r		),
        .task_exist_list    (task_exist_list),
        .tt_top_pri_task    (tt_top_pri_task),
        .et_top_pri_task    (et_top_pri_task),
        
        .ttr_r_sel		    (ttr_r_sel	    ),
        .ttr_r_number		(ttr_r_number	),
        .ttr_rea		    (ttr_rea),
        .ttr_dout            (ttr_dout),
        
        .cp2_ts_0	(cp2_ts_0),
        .cp2_fs_0	(cp2_fs_0),
        .cp2_as_0	(cp2_as_0),
                                         
        .decode_fdata                	(decode_fdata),
        .decode_as       				(decode_as   ),	
        .decode_fs       				(decode_fs   ),	
        .decode_ts       				(decode_ts   ),	
        .decode_task_sel 				(decode_task_sel),	
        .decode_task_aord_op			(decode_task_aord_op	),	
        .decode_g_time_write_en			(decode_g_time_write_en	),    
        .decode_g_time_write_sel		(decode_g_time_write_sel),	
        .decode_ttr_w_sel				(decode_ttr_w_sel		),	
        .decode_ttr_w_number			(decode_ttr_w_number	),	
        .decode_ttr_wea					(decode_ttr_wea			),    
        .decode_chcy_ena				(decode_chcy_ena		),    
        .decode_chph_ena				(decode_chph_ena		),    
        .decode_chdeadline_ena			(decode_chdeadline_ena	),
        .decode_task_chs_ena            (decode_task_chs_ena),
        .decode_task_new_status         (decode_task_new_status),
        .decode_task_trigger_op_ena     (decode_task_trigger_op_ena),
        .decode_task_trigger_op         (decode_task_trigger_op)

    );
    

    cp2_fdata_output cp2_fdata_output(
        .clk_(clk_),
        .rst(rst),
        .decode_as(decode_as),
        .decode_fs(decode_fs),
        .decode_fdata(decode_fdata),
        .cp2_fds_0(cp2_fds_0),
        .cp2_fdata_0(cp2_fdata_0)
    );

    cp2_writeBack_stage cp2_writeBack_stage(
        .clk	                	(clk	                 ),
        .rst	                	(rst	                 ),
        .decode_ts		        (decode_ts		     ),
        .cp2_tds_0		            (cp2_tds_0		         ),
        .cp2_tdata_0	        	(cp2_tdata_0	         ),
        .decode_task_sel 			(decode_task_sel 		 ),
        .decode_task_aord_op		(decode_task_aord_op	 ),
        .decode_g_time_write_en		(decode_g_time_write_en	 ),
        .decode_g_time_write_sel	(decode_g_time_write_sel ),
        .decode_ttr_w_sel			(decode_ttr_w_sel		 ),
        .decode_ttr_w_number		(decode_ttr_w_number	 ),
        .decode_ttr_wea				(decode_ttr_wea			 ),
        .decode_chcy_ena			(decode_chcy_ena		 ),
        .decode_chph_ena			(decode_chph_ena		 ),
        .decode_chdeadline_ena		(decode_chdeadline_ena	 ),
        .decode_task_chs_ena       	(decode_task_chs_ena     ),
        .decode_task_new_status    	(decode_task_new_status  ),
        .decode_task_trigger_op_ena	(decode_task_trigger_op_ena),
        .decode_task_trigger_op    	(decode_task_trigger_op  ),
                                                             
        .task_sel 					(task_sel 				 ),	
        .task_aord_op				(task_aord_op			 ),	
        .g_time_write_en			(g_time_write_en		 ),    
        .g_time_write_sel			(g_time_write_sel		 ),	
        .ttr_w_sel					(ttr_w_sel				 ),	
        .ttr_w_number				(ttr_w_number			 ),	
        .ttr_wea					(ttr_wea				 ),    
        .chcy_ena					(chcy_ena				 ),    
        .chph_ena					(chph_ena				 ),    
        .chdeadline_ena				(chdeadline_ena			 ),	
        .task_chs_ena         		(task_chs_ena         	 ),
        .task_new_status      		(task_new_status      	 ),    
        .task_trigger_op_ena  		(task_trigger_op_ena  	 ),
        .task_trigger_op      		(task_trigger_op      	 ),
                                                             
        .writeBack_data             (writeBack_data          )

    );

    //cp2_ctrl cp2_ctrl(
    //  .clk(clk),
    //  .rst(rst),
    //  .cp2_irenable_0(cp2_irenable_0),
    //  .cp2_ts_0(cp2_ts_0),
    //  .cp2_fs_0(cp2_fs_0),
    //  .cp2_as_0(cp2_as_0),
    //  .cp2_ir_0(cp2_ir_0),
    //  .cp2_tds_0(cp2_tds_0),
    //  .cp2_fds_0(cp2_fds_0),
    //  .cp2_tdata_0(cp2_tdata_0),
    //  .cp2_fdata_0(cp2_fdata_0),
    //  .cp2_execs_0(cp2_execs_0),
    //  .cp2_exc_0(cp2_exc_0),
    //  .cp2_exccode_0(cp2_exccode_0),
    //  .wr_data(wr_data),
    //  .g_time_h(g_time_h),
    //  .g_time_l			    (g_time_l			    ),
    //                                              
    //  .tr_regs_dout			(tr_regs_dout			),
    //                                              
    //  .tr_number			(tr_number			),
    //  .tr_r_number			(tr_r_number			),
    //  .tr_sel			    (tr_sel			    ),
    //  .tr_r_sel			    (tr_r_sel			    ),
    //  .tr_wea			    (tr_wea			    ),
    //  .tr_rea			    (tr_rea			    ),
    //  .tr_regs_din			(tr_regs_din			),
    //                                              
    //  .task_sel			    (task_sel			    ),
    //  .task_sel_r			(task_sel_r			),
    //  .task_chs_ena			(task_chs_ena			),
    //  .task_new_status		(task_new_status		),
    //  .task_aord_op			(task_aord_op			),
    //  .task_chcy_ena		(task_chcy_ena		),
    //  .task_chph_ena		(task_chph_ena		),
    //  .task_chdeadline_ena	(task_chdeadline_ena	),
    //  .task_chcyen_ena		(task_chcyen_ena		),
    //  .task_cyen_op			(task_cyen_op			),
    //  .task_write_data_input(task_write_data_input),
    //  .task_trigger_op_ena	(task_trigger_op_ena	),
    //  .task_trigger_op		(task_trigger_op		),
    //  .task_info_sel		(task_info_sel		),
    //  .task_info			(task_info			),
    //  .tt_top_pri_task		(tt_top_pri_task		),
    //  .et_top_pri_task		(et_top_pri_task		)

    //);



endmodule
