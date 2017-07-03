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

    input  wire [`WORDDATABUS] rd_data,
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
    reg         [`WEABUS]      mem_mem_op_1;
    reg         [`WEABUS]      mem_mem_op_2;
    reg         [`WORDDATABUS] mem_out_buf_1;
    reg         [`WORDDATABUS] mem_out_buf_2;
    reg         [1:0]          addr_info_buf_1;
    reg         [1:0]          addr_info_buf_2;

	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin	 
			mem_pc		 <=  `WORDADDRW'h0;
			mem_en		 <=  `DISABLE;
			mem_br_flag	 <=  `DISABLE;
			mem_ctrl_op	 <=  `CTRLOPNOP;
			mem_dst_addr <=  `REGADDRW'h0;
			mem_gpr_we_	 <=  `DISABLE_;
			mem_exp_code <=  `ISAEXP_NOEXP;
            mem_mem_op_1 <=  `MEMOPNOP;
            mem_mem_op_2 <=  `MEMOPNOP;
            mem_out_buf_1  <=  `WORDDATAW'h0;
            mem_out_buf_2  <=  `WORDDATAW'h0;
            addr_info_buf_1  <=  2'b11;
            addr_info_buf_2  <=  2'b11;
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
                    mem_mem_op_1 <=  `MEMOPNOP;
                    mem_mem_op_2 <=  `MEMOPNOP;
                    mem_out_buf_1  <=  `WORDDATAW'h0;
                    mem_out_buf_2  <=  `WORDDATAW'h0;
                    addr_info_buf_1  <=  2'b11;
                    addr_info_buf_2  <=  2'b11;
				end else begin		  				
					mem_pc		 <=  ex_pc;
					mem_en		 <=  ex_en;
					mem_br_flag	 <=  ex_br_flag;
					mem_ctrl_op	 <=  ex_ctrl_op;
					mem_dst_addr <=  ex_dst_addr;
					mem_gpr_we_	 <=  ex_gpr_we_;
					mem_exp_code <=  ex_exp_code;
                    mem_mem_op_1 <=  ex_mem_op;
                    mem_mem_op_2 <=  mem_mem_op_1;
                    mem_out_buf_1  <=  out;
                    mem_out_buf_2  <=  mem_out_buf_1;
                    addr_info_buf_1  <=  addr[1:0];
                    addr_info_buf_2  <=  addr_info_buf_1;
				end
			end
		end
	end
    
    always @(*)begin//处理mem读的延迟clk
        if(reset==`RESET_ENABLE)begin
            mem_out = `WORDDATAW'h0;
        end else if(flush==`ENABLE)begin
		    mem_out	= `WORDDATAW'h0;
        end else 
        begin
            case(mem_mem_op_2)
                `MEMOPLHU     :begin
                    if(addr_info_buf_2[1])
                        mem_out=(rd_data&32'hffff0000)>>16;
                    else
                        mem_out=(rd_data&32'h0000ffff);
                end
                `MEMOPLH    :begin
                    if(addr_info_buf_2[1])
                        mem_out={rd_data[31],16'h0,rd_data[30:16]};
                    else
                        mem_out={rd_data[15],16'h0,rd_data[14:0]};
                end
                `MEMOPLB     :begin
                    mem_out=((~(32'hff<<addr_info_buf_2[1:0]))&rd_data)>>(addr_info_buf_2[1:0]);
                    mem_out={mem_out[7],24'h0,mem_out[6:0]};
                end
                `MEMOPLBU    :begin
                    mem_out=((~(32'hff<<addr_info_buf_2[1:0]))&rd_data)>>(addr_info_buf_2[1:0]);
                end
                default      :begin
                    mem_out=mem_out_buf_2;
                end
            endcase
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
                        cp2_tdata_0<=ex_cp2_wr_data;
                        cp2_tds_0<=`ENABLE;
                    end  else begin
                        cp2_tds_0<=`DISABLE;
                    end
                end
            end
        end
    end
    endmodule
