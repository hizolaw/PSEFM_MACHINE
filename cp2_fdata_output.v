`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2017 09:50:41 PM
// Design Name: 
// Module Name: cp2_fdata_output
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

`include "bus.vh"
`include "cp2.vh"
`include "signal.vh"


module cp2_fdata_output(
    input wire clk_,
    input wire rst,
    input wire decode_as,
    input wire decode_fs,
    input wire [`WORDDATABUS] decode_fdata,
    output reg  cp2_fds_0,
    output reg [`WORDDATABUS] cp2_fdata_0
    );

    always @(posedge clk_ or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)begin
            cp2_fds_0<=`DISABLE;
            cp2_fdata_0<=`WORDDATAW'b0;
        end else begin
            if(decode_as || decode_fs)begin
                cp2_fds_0<=`ENABLE;
                cp2_fdata_0<=decode_fdata;
            end else begin
                cp2_fds_0<=`DISABLE;
                cp2_fdata_0<=`WORDDATAW'b0;
            end
        end
    end
endmodule
