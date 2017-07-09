`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2017 11:13:58 AM
// Design Name: 
// Module Name: ex_reg
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

module ex_reg (
	input  wire				   clk,			   
	input  wire				   reset,		   
	
    input  wire [`WORDDATABUS] alu_out,		   
	input  wire				   alu_of,		   
	
    input  wire				   stall,		   
	input  wire				   flush,		   
	input  wire				   int_detect,	   
	input  wire [`ISAEXPBUS]   int_type,
	
    input  wire [`WORDADDRBUS] id_pc,		   
	input  wire				   id_en,		   
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

    output reg	[`WORDADDRBUS] ex_pc,		   
	output reg				   ex_en,		   
	output reg				   ex_br_flag,	   
	output reg	[`MEMOPBUS]	   ex_mem_op,	   
	output reg	[`WORDDATABUS] ex_mem_wr_data, 
	output reg	[`CTRLOPBUS]   ex_ctrl_op,	   
	output reg	[`REGADDRBUS]  ex_dst_addr,	   
	output reg				   ex_gpr_we_,	   
	output reg	[`ISAEXPBUS]   ex_exp_code,	   
	output reg	[`WORDDATABUS] ex_out,
	output reg                 ex_cp2_fs_0,
    output reg                 ex_cp2_ts_0,
    output reg                 ex_cp2_as_0,
    output reg  [`WORDDATABUS] ex_cp2_wr_data

);
    reg    id_cp2_fs_0_buf;   
    reg    id_cp2_ts_0_buf;
    reg    id_cp2_as_0_buf;

	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			ex_pc		   <=  `WORDADDRW'h0;
			ex_en		   <=  `DISABLE;
			ex_br_flag	   <=  `DISABLE;
			ex_mem_op	   <=  `MEMOPNOP;
			ex_mem_wr_data <=  `WORDDATAW'h0;
			ex_ctrl_op	   <=  `CTRLOPNOP;
			ex_dst_addr	   <=  `REGADDRW'd0;
			ex_gpr_we_	   <=  `DISABLE_;
			ex_exp_code	   <=  `ISAEXP_NOEXP;
			ex_out		   <=  `WORDDATAW'h0;
            ex_cp2_wr_data <=  `WORDDATAW'h0;
            id_cp2_fs_0_buf<=`DISABLE;   
            id_cp2_ts_0_buf<=`DISABLE;
            id_cp2_as_0_buf<=`DISABLE;

		end else begin
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin				  
					ex_pc		   <=  `WORDADDRW'h0;
					ex_en		   <=  `DISABLE;
					ex_br_flag	   <=  `DISABLE;
					ex_mem_op	   <=  `MEMOPNOP;
					ex_mem_wr_data <=  `WORDDATAW'h0;
					ex_ctrl_op	   <=  `CTRLOPNOP;
					ex_dst_addr	   <=  `REGADDRW'd0;
					ex_gpr_we_	   <=  `DISABLE_;
					ex_exp_code	   <=  `ISAEXP_NOEXP;
					ex_out		   <=  `WORDDATAW'h0;
                    ex_cp2_wr_data <=  `WORDDATAW'h0;
                    id_cp2_fs_0_buf<=`DISABLE;   
                    id_cp2_ts_0_buf<=`DISABLE;
                    id_cp2_as_0_buf<=`DISABLE;

				end else if (int_detect == `ENABLE) begin //interrupt detect
					ex_pc		   <=  id_pc;
					ex_en		   <=  id_en;
					ex_br_flag	   <=  id_br_flag;
					ex_mem_op	   <=  `MEMOPNOP;
					ex_mem_wr_data <=  `WORDDATAW'h0;
					ex_ctrl_op	   <=  `CTRLOPNOP;
					ex_dst_addr	   <=  `REGADDRW'd0;
					ex_gpr_we_	   <=  `DISABLE_;
					ex_exp_code	   <=  int_type;
					ex_out		   <=  `WORDDATAW'h0;
                    ex_cp2_wr_data <=  `WORDDATAW'h0;
                    id_cp2_fs_0_buf<=`DISABLE;   
                    id_cp2_ts_0_buf<=`DISABLE;
                    id_cp2_as_0_buf<=`DISABLE;
				end else if (alu_of == `ENABLE) begin	 
					ex_pc		   <=  id_pc;
					ex_en		   <=  id_en;
					ex_br_flag	   <=  id_br_flag;
					ex_mem_op	   <=  `MEMOPNOP;
					ex_mem_wr_data <=  `WORDDATAW'h0;
					ex_ctrl_op	   <=  `CTRLOPNOP;
					ex_dst_addr	   <=  `REGADDRW'd0;
					ex_gpr_we_	   <=  `DISABLE_;
					ex_exp_code	   <=  `ISAEXP_OVERFLOW;
					ex_out		   <=  `WORDDATAW'h0;
                    ex_cp2_wr_data <=  `WORDDATAW'h0;
                    id_cp2_fs_0_buf<=`DISABLE;   
                    id_cp2_ts_0_buf<=`DISABLE;
                    id_cp2_as_0_buf<=`DISABLE;

				end else begin				
					ex_pc		   <=  id_pc;
					ex_en		   <=  id_en;
					ex_br_flag	   <=  id_br_flag;
					ex_mem_op	   <=  id_mem_op;
					ex_mem_wr_data <=  id_mem_wr_data;
					ex_ctrl_op	   <=  id_ctrl_op;
					ex_dst_addr	   <=  id_dst_addr;
					ex_gpr_we_	   <=  id_gpr_we_;
					ex_exp_code	   <=  id_exp_code;
					ex_out		   <=  alu_out;
                    ex_cp2_wr_data <=  id_cp2_wr_data;
                    id_cp2_fs_0_buf<=id_cp2_fs_0;   
                    id_cp2_ts_0_buf<=id_cp2_ts_0;
                    id_cp2_as_0_buf<=id_cp2_as_0;
				end
			end
		end
    end
    
    always @(negedge clk or `RESET_EDGE reset)begin
    	if (reset == `RESET_ENABLE) begin 
            ex_cp2_fs_0 <= `DISABLE;
            ex_cp2_ts_0 <= `DISABLE;
            ex_cp2_as_0 <= `DISABLE;
		end else begin
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin				
                    ex_cp2_fs_0 <= `DISABLE;
                    ex_cp2_ts_0 <= `DISABLE;
                    ex_cp2_as_0 <= `DISABLE;
				end else if (int_detect == `ENABLE) begin //interrupt detect
	                ex_cp2_fs_0 <= `DISABLE;
                    ex_cp2_ts_0 <= `DISABLE;
                    ex_cp2_as_0 <= `DISABLE;
				end else if (alu_of == `ENABLE) begin	 
	                ex_cp2_fs_0 <= `DISABLE;
                    ex_cp2_ts_0 <= `DISABLE;
                    ex_cp2_as_0 <= `DISABLE;
				end else begin			
                    ex_cp2_fs_0 <= id_cp2_fs_0_buf;
                    ex_cp2_ts_0 <= id_cp2_ts_0_buf;
                    ex_cp2_as_0 <= id_cp2_as_0_buf;
				end
			end
		end
    end

endmodule
