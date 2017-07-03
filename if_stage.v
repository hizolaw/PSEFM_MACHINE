`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2017 04:38:23 PM
// Design Name: 
// Module Name: if_stage
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
module if_stage(
    input   wire                  clk,
    input   wire                  rst,
    input   wire [`WORDDATABUS]   insn,//instruction
    input   wire                  stall,
    input   wire                  flush,
    input   wire [`WORDDATABUS]   new_pc,
    input   wire                  br_taken,
    input   wire [`WORDDATABUS]   br_addr,
 //   output  wire [`WORDADDRBUS]   instruction_mem_addr,
    output  reg                  busy,
    output  wire [`WORDADDRBUS]   if_pc_phisics,
    output  wire [`WORDDATABUS]   if_insn,
    output  wire                  if_en
    );
    

    wire  [`WORDADDRBUS]   if_pc_virtual;
    assign if_pc_phisics=if_pc_virtual&32'h1fffffff;
    if_reg if_reg(
        .clk(clk),
        .rst(rst),
        .insn(insn),
        .stall(stall),
        .flush(flush),
        .new_pc(new_pc),
        .br_taken(br_taken),
        .br_addr(br_addr),
//        .instruction_mem_addr(instruction_mem_addr),
        .if_pc(if_pc_virtual),
        .if_insn(if_insn),
        .if_en(if_en)
    );
    always @(*)begin
        if(rst==`RESET_ENABLE)begin
            busy=`DISABLE;
        end
    end

endmodule
