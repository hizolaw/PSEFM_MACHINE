`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2017 02:57:51 PM
// Design Name: 
// Module Name: mem_stage
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
module mem_stage (
	input  wire				   clk,			   
	input  wire				   reset,		   
	
    input  wire				   stall,		   
	input  wire				   flush,		   
	output reg				   busy,		   
	
    output wire [`WORDDATABUS] fwd_data,	   
	
    input  wire [`WORDADDRBUS] ex_pc,		   
	input  wire				   ex_en,		   
	input  wire				   ex_br_flag,	   
	input  wire [`MEMOPBUS]	   ex_mem_op,	   
	input  wire [`WORDDATABUS] ex_mem_wr_data, 
	input  wire [`CTRLOPBUS]   ex_ctrl_op,	   
	input  wire [`REGADDRBUS]  ex_dst_addr,	   
	input  wire				   ex_gpr_we_,	   
	input  wire [`ISAEXPBUS]   ex_exp_code,	   
	input  wire [`WORDDATABUS] ex_out,
	input  wire                ex_cp2_fs_0,
    input  wire                ex_cp2_ts_0,
    input  wire                ex_cp2_as_0,
    input  wire [`WORDDATABUS] ex_cp2_wr_data,

    output wire                 mem_cp2_fs_0,
    output wire                 mem_cp2_ts_0,
    output wire                 mem_cp2_as_0,
    output wire  [`WORDDATABUS] cp2_tdata_0,
    output wire                 cp2_tds_0,

    output wire [`WORDADDRBUS] mem_data_addr,
    output wire [`WORDDATABUS] mem_data_input,
    output wire [`WEABUS]      mem_data_wea,
    input  wire [`WORDDATABUS] mem_data_output,


    output wire [`WORDADDRBUS] mem_pc,
    output wire                mem_en,
	output wire				   mem_br_flag,	   
	output wire [`CTRLOPBUS]   mem_ctrl_op,	   
	output wire [`REGADDRBUS]  mem_dst_addr,   
	output wire				   mem_gpr_we_,	   
	output wire [`ISAEXPBUS]   mem_exp_code,   
	output wire [`WORDDATABUS] mem_out		   
);

	wire [`WORDDATABUS]		   rd_data;		   
	wire [`WORDADDRBUS]		   addr;		   
	//wire					   as_;			   
	//wire					   rw;			   
	//wire [`WORDDATABUS]		   wr_data;		   
	wire [`WORDDATABUS]		   out;			   
	wire					   miss_align;	   

    assign mem_data_addr    = addr;
	assign fwd_data	 = out;
    always @(*)begin
        if(reset==`RESET_ENABLE)begin
            busy=`DISABLE;
        end
    end
	mem_ctrl mem_ctrl (
		.ex_en			(ex_en),			   
		.ex_mem_op		(ex_mem_op),		   
		.ex_mem_wr_data (ex_mem_wr_data),	   
		.ex_out			(ex_out),			   
        .rd_data      (mem_data_output),
		
        //.rd_data		(rd_data),			   
		.addr			(addr),				   
	//	.as_			(as_),				   
	//	.rw				(rw),				   
		.wr_data		(mem_data_input),
		//.wr_data		(wr_data),
        .wea            (mem_data_wea),
		
        .out			(out)   
	//	.miss_align		(miss_align)		   
	);


	mem_reg mem_reg (
		.clk		  (clk),				   
		.reset		  (reset),				   
		
        .out		  (out),				   
	//	.miss_align	  (miss_align),			   
		
        .stall		  (stall),				   
		.flush		  (flush),				   
		
        .ex_pc		  (ex_pc),				   
		.ex_en		  (ex_en),				   
		.ex_br_flag	  (ex_br_flag),			   
		.ex_ctrl_op	  (ex_ctrl_op),			   
		.ex_dst_addr  (ex_dst_addr),		   
		.ex_gpr_we_	  (ex_gpr_we_),			   
		.ex_exp_code  (ex_exp_code),
        .ex_mem_op    (ex_mem_op),
	
        .ex_cp2_fs_0    (ex_cp2_fs_0),
        .ex_cp2_ts_0    (ex_cp2_ts_0),
        .ex_cp2_as_0    (ex_cp2_as_0),
        .ex_cp2_wr_data (ex_cp2_wr_data),
 

        .mem_cp2_fs_0       (mem_cp2_fs_0),
        .mem_cp2_ts_0       (mem_cp2_ts_0),
        .mem_cp2_as_0       (mem_cp2_as_0),
        .cp2_tdata_0    (cp2_tdata_0),
        .cp2_tds_0      (cp2_tds_0),
        
        .addr         (addr),
        .mem_pc		  (mem_pc),				   
		.mem_en		  (mem_en),				   
		.mem_br_flag  (mem_br_flag),		   
		.mem_ctrl_op  (mem_ctrl_op),		   
		.mem_dst_addr (mem_dst_addr),		   
		.mem_gpr_we_  (mem_gpr_we_),		   
		.mem_exp_code (mem_exp_code),		   
		.mem_out	  (mem_out)				   
	);

endmodule
