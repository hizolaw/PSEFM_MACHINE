`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2017 04:40:57 PM
// Design Name: 
// Module Name: if_reg
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
`include"vector.vh"
`include"instructions.vh"
module if_reg(
    input   wire                  clk,
    input   wire                  rst,
    input   wire [`WORDDATABUS]   insn,//instruction
    input   wire                  stall,
    input   wire                  flush,
    input   wire [`WORDDATABUS]   new_pc,
    input   wire                  br_taken,
    input   wire [`WORDDATABUS]   br_addr,
    output  reg  [`WORDADDRBUS]   if_pc,
    output  reg  [`WORDDATABUS]   if_insn,
    output  reg                   if_en
    );
    always@(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin//复位
            if_pc<=`RESET_VECTOR;
            if_en<=`DISABLE;
        end else begin
            if(stall==`DISABLE)begin
                if(flush==`ENABLE)begin
                    if_pc<=new_pc;//异常，中断时的取指
                    if_en<=`DISABLE;
                end else if(br_taken==`ENABLE)begin
                    if_pc<=br_addr;//跳转指令的取指
                    if_en<=`ENABLE;
                end else begin
                    if_pc<=if_pc+4;//正常的取指地址
                    if_en<=`ENABLE;
                end
            end
        end
    end
    always@(*)begin//组合逻辑，指令出来，才往指令寄存器里送指令
        if(rst==`RESET_ENABLE)begin
            if_insn=`INS_NOP;
        end else begin
            if(stall==`DISABLE)begin
                if(flush==`ENABLE)begin
                    if_insn=`INS_NOP;//flush
                end else begin
                    if_insn=insn;//正常取指令
                end
            end
        end

    end
//    always@(if_pc or rst or insn)begin//组合逻辑，地址准备好，才开始向内存发出取指请求
//        if(rst==`RESET_ENABLE)begin
//            if_insn=`INS_NOP;
//            instruction_mem_clk=clk;
//        end else begin
//            if(clk==`LOW)begin
//                instruction_mem_clk=`LOW;
//            end else if(stall==`DISABLE)begin
//                instruction_mem_clk=`HIGH;//地址准备好了，把内存取指clk拉高，触发内存取指的地址读取
//                if(flush==`ENABLE)begin
//                    if_insn=`INS_NOP;//flush
//                end else begin
//                    if_insn=insn;//正常取指令
//                end
//            end else begin
//                instruction_mem_clk=`HIGH;//正常stall
//            end
//        end
//    end

endmodule
