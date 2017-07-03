`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2017 02:49:50 AM
// Design Name: 
// Module Name: gpr
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
module gpr (
	/********** clk & reset**********/
	input  wire				   clk_,				   //
	input  wire				   reset,			   //
	/********** read 0 **********/
	input  wire [`REGADDRBUS]  rd_addr_0,		   // address
	output wire [`WORDDATABUS] rd_data_0,		   // data
	/********** read 1 **********/
	input  wire [`REGADDRBUS]  rd_addr_1,		   //
	output wire [`WORDDATABUS] rd_data_1,		   //
	/********** write**********/
	input  wire				   we_,				   //
	input  wire [`REGADDRBUS]  wr_addr,			   // address
	input  wire [`WORDDATABUS] wr_data			   // data
);

	/**********  **********/
	reg [`WORDDATABUS]		   gpr [`REGNUM-1:0]; // regist array
	integer					   i;				   //

	/********** (Write After Read) **********/
	//  direct output the gpr[addr] data , 0
	assign rd_data_0 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_0)) ?
					   wr_data : gpr[rd_addr_0];
	assign rd_data_1 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_1)) ?
					   wr_data : gpr[rd_addr_1];

	always @ (negedge clk_ or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			for (i = 0; i < `REGNUM; i = i + 1) begin
				gpr[i]		 <=  `WORDDATAW'h0;
			end
		end else begin
			if (we_ == `ENABLE_) begin
				gpr[wr_addr] <=  wr_data;
			end
		end
	end

endmodule
