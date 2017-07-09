`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2017 01:13:05 AM
// Design Name: 
// Module Name: id_stage
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

module id_stage (
	input  wire					 clk,			 
	input  wire					 reset,			 
	
    //general 寄存器堆的访问,读为组合电路，写为时序电路
    input  wire [`WORDDATABUS]	 gpr_rd_data_0,	 
	input  wire [`WORDDATABUS]	 gpr_rd_data_1,	 
	output wire [`REGADDRBUS]	 gpr_rd_addr_0,	 
	output wire [`REGADDRBUS]	 gpr_rd_addr_1,	 

    //与执行阶段的直通判断
    input  wire					 ex_en,			
	input  wire [`WORDDATABUS]	 ex_fwd_data,	 
	input  wire [`REGADDRBUS]	 ex_dst_addr,	 
	input  wire					 ex_gpr_we_,	 
    input   wire [`MEMOPBUS]	 ex_mem_op	,  
    input   wire                        ex_cp2_fs_0,
    input   wire                        ex_cp2_as_0,
	input wire [`CTRLOPBUS]	 ex_ctrl_op,	 
	// 访存阶段的直通判断
    input  wire [`WORDDATABUS]	 mem_fwd_data,	 
	input wire [`CTRLOPBUS]	 mem_ctrl_op,	 
    
    

    input   wire       				    mem_en,			 
	input   wire       				    mem_gpr_we_,	
	input   wire    [`REGADDRBUS]	    mem_dst_addr,	 
    input   wire                        mem_cp2_fs_0,
    input   wire                        mem_cp2_as_0,
    input   wire    [`WORDDATABUS]      cp2_fdata_0,

    input   wire    [`WORDDATABUS]      wb_fwd_data,

    // cp0寄存器的读写控制
    input  wire [`CPUEXEMODEBUS] exe_mode,		 
	input  wire [`WORDDATABUS]	 creg_rd_data,	 
	output wire [`REGADDRBUS]	 creg_rd_addr,	 
	
    input  wire					 stall,			 
	input  wire					 flush,			 
	output wire [`WORDADDRBUS]	 br_addr,		 
	output wire					 br_taken,		 
	output wire					 ld_hazard,		 
	
    //if阶段的输入
    input  wire [`WORDADDRBUS]	 if_pc,			 
	input  wire [`WORDDATABUS]	 if_insn,		 
	input  wire					 if_en,			 
	
    //id流水输出
    output wire [`WORDADDRBUS]	 id_pc,			 
	output wire					 id_en,			 
	output wire [`ALUOPBUS]		 id_alu_op,		 
	output wire [`WORDDATABUS]	 id_alu_in_0,	 
	output wire [`WORDDATABUS]	 id_alu_in_1,	 
	output wire					 id_br_flag,	 
	output wire [`MEMOPBUS]		 id_mem_op,		 
	output wire [`WORDDATABUS]	 id_mem_wr_data, 
	output wire [`CTRLOPBUS]	 id_ctrl_op,	 
	output wire [`REGADDRBUS]	 id_dst_addr,	 
	output wire					 id_gpr_we_,	 
	output wire [`ISAEXPBUS]	 id_exp_code,	 
    output wire                  cp_irenable_0,
    output wire                  id_cp2_fs_0,
    output wire                  id_cp2_ts_0,
    output wire                  id_cp2_as_0,
    output wire [`WORDDATABUS]   id_cp2_wr_data,
    output wire [`WORDDATABUS]   id_insn
);

	wire  [`ALUOPBUS]			 alu_op;		 
	wire  [`WORDDATABUS]		 alu_in_0;		 
	wire  [`WORDDATABUS]		 alu_in_1;		 
	wire						 br_flag;		 
	wire  [`MEMOPBUS]			 mem_op;		 
	wire  [`WORDDATABUS]		 mem_wr_data;	 
	wire  [`CTRLOPBUS]			 ctrl_op;		 
	wire  [`REGADDRBUS]			 dst_addr;		 
	wire						 gpr_we_;		 
	wire  [`ISAEXPBUS]			 exp_code;		 

    wire                         cp2_irenable_s;

    wire                         cp2_fs_s;
    wire                         cp2_ts_s;
    wire                         cp2_as_s;
    wire [`WORDDATABUS]          cp2_wr_data;


	decoder decoder (
		.if_pc			(if_pc),		  
		.if_insn		(if_insn),		  
		.if_en			(if_en),		  
		.gpr_rd_data_0	(gpr_rd_data_0),  
		.gpr_rd_data_1	(gpr_rd_data_1),  
		.gpr_rd_addr_0	(gpr_rd_addr_0),  
		.gpr_rd_addr_1	(gpr_rd_addr_1),  
		.id_en			(id_en),		  
		.id_dst_addr	(id_dst_addr),	  
		.id_gpr_we_		(id_gpr_we_),	  
		.id_mem_op		(id_mem_op),	  
        .id_ctrl_op     (id_ctrl_op),
		.ex_en			(ex_en),		  
		.ex_fwd_data	(ex_fwd_data),	  
		.ex_dst_addr	(ex_dst_addr),	  
		.ex_gpr_we_		(ex_gpr_we_),	  
        .ex_mem_op      (ex_mem_op),
        .ex_cp2_fs_0    (ex_cp2_fs_0),
        .ex_cp2_as_0    (ex_cp2_as_0),


        .mem_en			(mem_en			),		 
        .mem_gpr_we_	(mem_gpr_we_	), 
        .mem_dst_addr	(mem_dst_addr	),
        .mem_cp2_fs_0	(mem_cp2_fs_0	),
        .mem_cp2_as_0	(mem_cp2_as_0	),
        .cp2_fdata_0	(cp2_fdata_0	),
                                     
        .wb_fwd_data	(wb_fwd_data	),
		
        .mem_fwd_data	(mem_fwd_data),	  
		.exe_mode		(exe_mode),		  
		.creg_rd_data	(creg_rd_data),	  
		.creg_rd_addr	(creg_rd_addr),	  
		.alu_op			(alu_op),		  
		.alu_in_0		(alu_in_0),		  
		.alu_in_1		(alu_in_1),		  
		.br_addr		(br_addr),		  
		.br_taken		(br_taken),		  
		.br_flag		(br_flag),		  
		.mem_op			(mem_op),		  
		.mem_wr_data	(mem_wr_data),	  
		.ctrl_op		(ctrl_op),		  
		.dst_addr		(dst_addr),		  
		.gpr_we_		(gpr_we_),		  
		.exp_code		(exp_code),		  
		.ld_hazard		(ld_hazard),
        .cp2_irenable_s (cp2_irenable_s),
        .cp2_fs_s       (cp2_fs_s),
        .cp2_ts_s       (cp2_ts_s),
        .cp2_as_s       (cp2_as_s),
        .id_cp2_fs_0       (id_cp2_fs_0),
        .id_cp2_as_0       (id_cp2_as_0),
        .cp2_wr_data    (cp2_wr_data)
	);

	id_reg id_reg (
		.clk			(clk),			  
		.reset			(reset),		  
		
		.if_insn		(if_insn),		  
        
        .alu_op			(alu_op),		  
		.alu_in_0		(alu_in_0),		  
		.alu_in_1		(alu_in_1),		  
		.br_flag		(br_flag),		  
		.mem_op			(mem_op),		  
		.mem_wr_data	(mem_wr_data),	  
		.ctrl_op		(ctrl_op),		  
		.dst_addr		(dst_addr),		  
		.gpr_we_		(gpr_we_),		  
		.exp_code		(exp_code),		  
		
        .stall			(stall),		  
		.flush			(flush),		  
		
        .if_pc			(if_pc),		  
		.if_en			(if_en),		  
		
        .id_pc			(id_pc),		  
		.id_en			(id_en),		  
		.id_alu_op		(id_alu_op),	  
		.id_alu_in_0	(id_alu_in_0),	  
		.id_alu_in_1	(id_alu_in_1),	  
		.id_br_flag		(id_br_flag),	  
		.id_mem_op		(id_mem_op),	  
		.id_mem_wr_data (id_mem_wr_data), 
		.id_ctrl_op		(id_ctrl_op),	  
		.id_dst_addr	(id_dst_addr),	  
		.id_gpr_we_		(id_gpr_we_),	  
		.id_exp_code	(id_exp_code),
        .id_insn(id_insn),

        .cp2_irenable_s (cp2_irenable_s),
        .cp_irenable_0  (cp_irenable_0),
        .cp2_fs_s       (cp2_fs_s),
        .cp2_ts_s       (cp2_ts_s),
        .cp2_as_s       (cp2_as_s),
        .cp2_wr_data    (cp2_wr_data),
        .id_cp2_fs_0       (id_cp2_fs_0),
        .id_cp2_ts_0       (id_cp2_ts_0),
        .id_cp2_as_0       (id_cp2_as_0),
        .id_cp2_wr_data     (id_cp2_wr_data)
	);

endmodule
