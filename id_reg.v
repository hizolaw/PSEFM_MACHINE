`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2017 01:13:45 AM
// Design Name: 
// Module Name: id_reg
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
`include"alu.vh"

module id_reg(
	input  wire				    clk,			   
	input  wire				    reset,		   
	
    input  wire  [`WORDDATABUS] if_insn,

    input  wire  [`ALUOPBUS]    alu_op,		   
	input  wire  [`WORDDATABUS] alu_in_0,	   
	input  wire  [`WORDDATABUS] alu_in_1,	   
	input  wire	   			    br_flag,		   
	input  wire  [`MEMOPBUS]    mem_op,		   
	input  wire  [`WORDDATABUS] mem_wr_data,	   
	input  wire  [`CTRLOPBUS]   ctrl_op,		   
	input  wire  [`REGADDRBUS]  dst_addr,	   
	input  wire	   			    gpr_we_,		   
	input  wire  [`ISAEXPBUS]   exp_code,	   
	
    input  wire				   stall,		   
	input  wire				   flush,		   
	
    input  wire [`WORDADDRBUS] if_pc,		   
	input  wire				   if_en,		   
	
    output reg  [`WORDADDRBUS] id_pc,		   
	output reg  			   id_en,		   
	output reg  [`ALUOPBUS]	   id_alu_op,	   
	output reg  [`WORDDATABUS] id_alu_in_0,	   
	output reg  [`WORDDATABUS] id_alu_in_1,	   
	output reg  			   id_br_flag,	   
	output reg  [`MEMOPBUS]	   id_mem_op,	   
	output reg  [`WORDDATABUS] id_mem_wr_data, 
	output reg  [`CTRLOPBUS]   id_ctrl_op,	   
	output reg  [`REGADDRBUS]  id_dst_addr,	   
	output reg  			   id_gpr_we_,	   
	output reg  [`ISAEXPBUS]   id_exp_code,	 
	
    input  wire                cp2_irenable_s,
    output reg                 cp_irenable_0,
    input  wire                cp2_fs_s,
    input  wire                cp2_ts_s,
    input  wire                cp2_as_s,
    input  wire [`WORDDATABUS] cp2_wr_data,
    output reg                 id_cp2_fs_0,
    output reg                 id_cp2_ts_0,
    output reg                 id_cp2_as_0,
    output reg  [`WORDDATABUS] id_cp2_wr_data,
    output reg [`WORDDATABUS]  id_insn
    );
    reg [`WORDDATABUS]          if_insn_buf;
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			id_pc		   <=  `WORDADDRW'h0;
			id_en		   <=  `DISABLE;
			id_alu_op	   <=  `ALU_OP_NOP;
			id_alu_in_0	   <=  `WORDDATAW'h0;
			id_alu_in_1	   <=  `WORDDATAW'h0;
			id_br_flag	   <=  `DISABLE;
			id_mem_op	   <=  `MEMOPNOP;
			id_mem_wr_data <=  `WORDDATAW'h0;
			id_ctrl_op	   <=  `CTRLOPNOP;
			id_dst_addr	   <=  `REGADDRW'd0;
			id_gpr_we_	   <=  `DISABLE_;
			id_exp_code	   <=  `ISAEXP_NOEXP;
            id_cp2_fs_0    <=  `DISABLE;
            id_cp2_ts_0    <=  `DISABLE;
            id_cp2_as_0    <=  `DISABLE;
            id_cp2_wr_data <=  `WORDDATAW'b0;
            if_insn_buf <=  `WORDDATAW'b0;
		end else begin
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin 
				   id_pc		  <=  `WORDADDRW'h0;
				   id_en		  <=  `DISABLE;
				   id_alu_op	  <=  `ALU_OP_NOP;
				   id_alu_in_0	  <=  `WORDDATAW'h0;
				   id_alu_in_1	  <=  `WORDDATAW'h0;
				   id_br_flag	  <=  `DISABLE;
				   id_mem_op	  <=  `MEMOPNOP;
				   id_mem_wr_data <=  `WORDDATAW'h0;
				   id_ctrl_op	  <=  `CTRLOPNOP;
				   id_dst_addr	  <=  `REGADDRW'd0;
				   id_gpr_we_	  <=  `DISABLE_;
				   id_exp_code	  <=  `ISAEXP_NOEXP;
                   id_cp2_fs_0    <=  `DISABLE;
                   id_cp2_ts_0    <=  `DISABLE;
                   id_cp2_as_0    <=  `DISABLE;
                   if_insn_buf <=  `WORDDATAW'b0;
				end else begin		  	
				   id_pc		  <=  if_pc;
				   id_en		  <=  if_en;
				   id_alu_op	  <=  alu_op;
				   id_alu_in_0	  <=  alu_in_0;
				   id_alu_in_1	  <=  alu_in_1;
				   id_br_flag	  <=  br_flag;
				   id_mem_op	  <=  mem_op;
				   id_mem_wr_data <=  mem_wr_data;
				   id_ctrl_op	  <=  ctrl_op;
				   id_dst_addr	  <=  dst_addr;
				   id_gpr_we_	  <=  gpr_we_;
				   id_exp_code	  <=  exp_code;

                   id_cp2_wr_data    <=  cp2_wr_data;
                   id_cp2_fs_0       <=  cp2_fs_s;
                   id_cp2_ts_0       <=  cp2_ts_s;
                   id_cp2_as_0       <=  cp2_as_s;
                   if_insn_buf <=  if_insn;
				end
			end
		end
    end

    always@(negedge clk)begin//cp2的指令传送
        if(cp2_irenable_s==`ENABLE)begin
            cp_irenable_0<=`ENABLE;
            id_insn      <=  if_insn_buf;
        end else begin
            cp_irenable_0<=`DISABLE;
            id_insn      <= `WORDADDRW'b0;
        end
    end


endmodule
