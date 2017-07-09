`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2017 02:58:52 PM
// Design Name: 
// Module Name: mem_reg
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

module mem_reg(
	input  wire				   clk,			 
	input  wire				   reset,		 
	
    input  wire [`WORDDATABUS] out,			 
//	input  wire				   miss_align,	 
	
    input  wire				   stall,		 
	input  wire				   flush,		 
	
    input  wire [`WORDADDRBUS] ex_pc,		 
	input  wire				   ex_en,		 
	input  wire				   ex_br_flag,	 
	input  wire [`CTRLOPBUS]   ex_ctrl_op,	 
	input  wire [`REGADDRBUS]  ex_dst_addr,	 
	input  wire				   ex_gpr_we_,	 
	input  wire [`ISAEXPBUS]   ex_exp_code,
    input  wire [`WEABUS]      ex_mem_op,
	input  wire                ex_cp2_fs_0,
    input  wire                ex_cp2_ts_0,
    input  wire                ex_cp2_as_0,
    input  wire [`WORDDATABUS] ex_cp2_wr_data,

    output reg                 mem_cp2_fs_0,
    output reg                 mem_cp2_ts_0,
    output reg                 mem_cp2_as_0,
    output reg  [`WORDDATABUS] cp2_tdata_0,
    output reg                 cp2_tds_0,

    input  wire [`WORDADDRBUS] addr,
    output reg	[`WORDADDRBUS] mem_pc,		 
	output reg				   mem_en,		 
	output reg				   mem_br_flag,	 
	output reg	[`CTRLOPBUS]   mem_ctrl_op,	 
	output reg	[`REGADDRBUS]  mem_dst_addr, 
	output reg				   mem_gpr_we_,	 
	output reg	[`ISAEXPBUS]   mem_exp_code, 
	output reg	[`WORDDATABUS] mem_out	 
    );
    
    reg [`WORDDATABUS]  ex_cp2_wr_data_buf;
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin	 
			mem_pc		 <=  `WORDADDRW'h0;
			mem_en		 <=  `DISABLE;
			mem_br_flag	 <=  `DISABLE;
			mem_ctrl_op	 <=  `CTRLOPNOP;
			mem_dst_addr <=  `REGADDRW'h0;
			mem_gpr_we_	 <=  `DISABLE_;
			mem_exp_code <=  `ISAEXP_NOEXP;
            mem_out      <=  `WORDDATAW'd0;
            ex_cp2_wr_data_buf<=`WORDDATAW'b0;
		end else begin
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin				  
                    //mem_mem_op   <=  `MEMOPNOP;
					mem_pc		 <=  `WORDADDRW'h0;
					mem_en		 <=  `DISABLE;
					mem_br_flag	 <=  `DISABLE;
					mem_ctrl_op	 <=  `CTRLOPNOP;
					mem_dst_addr <=  `REGADDRW'h0;
					mem_gpr_we_	 <=  `DISABLE_;
					mem_exp_code <=  `ISAEXP_NOEXP;
                    mem_out      <=  `WORDDATAW'd0;
                    ex_cp2_wr_data_buf<=`WORDDATAW'b0;
				end else begin		  				
					mem_pc		 <=  ex_pc;
					mem_en		 <=  ex_en;
					mem_br_flag	 <=  ex_br_flag;
					mem_ctrl_op	 <=  ex_ctrl_op;
					mem_dst_addr <=  ex_dst_addr;
					mem_gpr_we_	 <=  ex_gpr_we_;
					mem_exp_code <=  ex_exp_code;
                    mem_out      <=  out;
                    ex_cp2_wr_data_buf<=ex_cp2_wr_data;
				end
			end
		end
	end

    always @(negedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin	 
            mem_cp2_fs_0<=`DISABLE;
            mem_cp2_ts_0<=`DISABLE;
            mem_cp2_as_0<=`DISABLE;
            cp2_tdata_0<=`WORDDATAW'd0;
            cp2_tds_0<=`DISABLE;
        end else begin
            if (stall == `DISABLE) begin 
                if (flush == `ENABLE) begin				  
                    mem_cp2_fs_0<=`DISABLE;
                    mem_cp2_ts_0<=`DISABLE;
                    mem_cp2_as_0<=`DISABLE;
                    cp2_tdata_0<=`WORDDATAW'd0;
                    cp2_tds_0<=`DISABLE;
                end else begin
                    mem_cp2_fs_0<=ex_cp2_fs_0;
                    mem_cp2_ts_0<=ex_cp2_ts_0;
                    mem_cp2_as_0<=ex_cp2_as_0;
                    if(ex_cp2_ts_0) begin
                        cp2_tdata_0<=ex_cp2_wr_data_buf;
                        cp2_tds_0<=`ENABLE;
                    end  else begin
                        cp2_tds_0<=`DISABLE;
                    end
                end
            end
        end
    end
    endmodule
