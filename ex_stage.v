`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2017 11:13:38 AM
// Design Name: 
// Module Name: ex_stage
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

module ex_stage (
	
    input  wire				   clk,			   
	input  wire				   reset,		   
	
    input  wire				   stall,		   
	input  wire				   flush,		   
	input  wire				   int_detect,	   
	input  wire	[`ISAEXPBUS]   int_type,	   
	
    output wire [`WORDDATABUS] fwd_data,	   
	
    input  wire [`WORDADDRBUS] id_pc,		   
	input  wire				   id_en,		   
	input  wire [`ALUOPBUS]	   id_alu_op,	   
	input  wire [`WORDDATABUS] id_alu_in_0,	   
	input  wire [`WORDDATABUS] id_alu_in_1,	   
	input  wire				   id_br_flag,	   
	input  wire [`MEMOPBUS]	   id_mem_op,	   
	input  wire [`WORDDATABUS] id_mem_wr_data, 
	input  wire [`CTRLOPBUS]   id_ctrl_op,	   
	input  wire [`REGADDRBUS]  id_dst_addr,	   
	input  wire				   id_gpr_we_,	   
	input  wire [`ISAEXPBUS]   id_exp_code,
	input  wire                id_cp2_fs_0,
    input  wire                id_cp2_ts_0,
    input  wire                id_cp2_as_0,
    input  wire [`WORDDATABUS] id_cp2_wr_data,

    output wire [`WORDADDRBUS] ex_pc,		   
	output wire				   ex_en,		   
	output wire				   ex_br_flag,	   
	output wire [`MEMOPBUS]	   ex_mem_op,	   
	output wire [`WORDDATABUS] ex_mem_wr_data, 
	output wire [`CTRLOPBUS]   ex_ctrl_op,	   
	output wire [`REGADDRBUS]  ex_dst_addr,	   
	output wire				   ex_gpr_we_,	   
	output wire [`ISAEXPBUS]   ex_exp_code,	   
	output wire [`WORDDATABUS] ex_out,		   
	output wire                ex_cp2_fs_0,
    output wire                ex_cp2_ts_0,
    output wire                ex_cp2_as_0,
    output wire [`WORDDATABUS] ex_cp2_wr_data,
    output wire                 ex_syscall_detect
);

	wire [`WORDDATABUS]		   alu_out;		   
	wire					   alu_of;		   

	assign fwd_data = alu_out;
    
    assign ex_syscall_detect=(id_exp_code==`ISAEXP_TRAP)?`ENABLE:`DISABLE;

	alu alu (
        .rst            (reset),
		.alu_a			(id_alu_in_0),	  
		.alu_b			(id_alu_in_1),	  
		.alu_op			(id_alu_op),	   
		.alu_out		(alu_out),		  
		.of				(alu_of)		  
	);

	ex_reg ex_reg (
		.clk			(clk),			  
		.reset			(reset),		  
		
        .alu_out		(alu_out),		  
		.alu_of			(alu_of),		  
		
        .stall			(stall),		  
		.flush			(flush),		  
		.int_detect		(int_detect),	  
        .int_type       (int_type),
		
        .id_pc			(id_pc),		  
		.id_en			(id_en),		  
		.id_br_flag		(id_br_flag),	  
		.id_mem_op		(id_mem_op),	  
		.id_mem_wr_data (id_mem_wr_data), 
		.id_ctrl_op		(id_ctrl_op),	  
		.id_dst_addr	(id_dst_addr),	  
		.id_gpr_we_		(id_gpr_we_),	  
		.id_exp_code	(id_exp_code),	  
        .id_cp2_fs_0    (id_cp2_fs_0   ),
        .id_cp2_ts_0    (id_cp2_ts_0   ),
        .id_cp2_as_0    (id_cp2_as_0   ),
        .id_cp2_wr_data (id_cp2_wr_data),

        .ex_pc			(ex_pc),		  
		.ex_en			(ex_en),		  
		.ex_br_flag		(ex_br_flag),	  
		.ex_mem_op		(ex_mem_op),	  
		.ex_mem_wr_data (ex_mem_wr_data), 
		.ex_ctrl_op		(ex_ctrl_op),	  
		.ex_dst_addr	(ex_dst_addr),	  
		.ex_gpr_we_		(ex_gpr_we_),	  
		.ex_exp_code	(ex_exp_code),	  
		.ex_out			(ex_out),	  
        .ex_cp2_fs_0    (ex_cp2_fs_0   ),
        .ex_cp2_ts_0    (ex_cp2_ts_0   ),
        .ex_cp2_as_0    (ex_cp2_as_0   ),
        .ex_cp2_wr_data (ex_cp2_wr_data)
	);

endmodule
