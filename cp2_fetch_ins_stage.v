`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2017 07:09:02 PM
// Design Name: 
// Module Name: cp2_fetch_ins_stage
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
`include"cp2.vh"
`include"signal.vh"
`include"bus.vh"
module cp2_fetch_ins_stage(
    input wire                  clk,
    input wire                  rst,
    input wire                  irenable,
    input wire [`WORDADDRBUS]   ir,
    output reg [`WORDADDRBUS]   fetch_instruction,
    output reg                  decode_en
    );

    always @(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            fetch_instruction<=`WORD_DATA_W'b0;
            decode_en<=`DISABLE;
        end else begin
            if(irenable==`ENABLE)begin
                decode_en<=`ENABLE;
                fetch_instruction<=ir;
            end else begin
                decode_en<=`DISABLE;
            end
        end
    end
endmodule
