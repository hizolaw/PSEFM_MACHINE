`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2017 04:28:37 PM
// Design Name: 
// Module Name: mem
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

module mem(
    input   wire                        clka,
    input   wire                        clkb,
    input   wire                        rst,
    input   wire    [`WORDADDRBUS]      insn_addr,
    output  wire    [`WORDDATABUS]      insn,
    input   wire    [`WORDADDRBUS]      mem_data_addr,
    input   wire    [`WORDDATABUS]      mem_data_input,
    input   wire    [`WEABUS]           mem_data_wea,
    output  wire     [`WORDDATABUS]     mem_data_output
    );
    blk_mem_gen_0 ram(.clka(clka),
                      .ena(`ENABLE),
                      .wea(4'b0000),
                      .addra(insn_addr[17:2]),
                      .dina(`WORDDATAW'b0), 
                      .douta(insn), 
                      .addrb(mem_data_addr[17:2]), 
                      .clkb(clkb),
                      .web(mem_data_wea),
                      .enb(`ENABLE),
                      .dinb(mem_data_input),
                      .doutb(mem_data_output));
    
endmodule
