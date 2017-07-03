`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2017 10:16:54 PM
// Design Name: 
// Module Name: psefm_machine
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


`include "cp2.vh"
`include "signal.vh"
`include"bus.vh"
module psefm_machine(
    input wire clk,
    input wire rst,
    input wire [`IRQ_BUS] irq,
    inout wire [`WORDDATABUS] io_pin
    );
    wire                 cp_irenable_0;
    wire [`WORDDATABUS]  cp_ir_0;
    wire                 cp2_as_0;
    wire                 cp2_ts_0;
    wire                 cp2_fs_0;
    wire [`WORDDATABUS]  cp2_tdata_0;
    wire                 cp2_abusy_0;
    wire                 cp2_tbusy_0;
    wire                 cp2_fbusy_0;
    wire [`WORDDATABUS]  cp2_fdata_0;
    wire                 cp2_excs_0;
    wire                 cp2_exc_0;
    wire [`CP2EXECCODEBUS] cp2_exccode_0;
 
    cpu cpu(
        .clk(clk),
        .rst(rst),
        .irq(irq),
        .cp_irenable_0	(cp_irenable_0),
        .cp_ir_0		(cp_ir_0	  ),
        .cp2_as_0		(cp2_as_0	  ),
        .cp2_ts_0		(cp2_ts_0	  ),
        .cp2_fs_0		(cp2_fs_0	  ),
        .cp2_tdata_0	(cp2_tdata_0  ),
        .cp2_abusy_0	(cp2_abusy_0  ),
        .cp2_tbusy_0	(cp2_tbusy_0  ),
        .cp2_fbusy_0	(cp2_fbusy_0  ),
        .cp2_fdata_0	(cp2_fdata_0  ),
        .cp2_tds_0		(cp2_tds_0	   ),
        .cp2_fds_0		(cp2_fds_0	   ),
        .cp2_excs_0	(cp2_excs_0  ),
        .cp2_exc_0		(cp2_exc_0	  ),
        .cp2_exccode_0  (cp2_exccode_0)

    );
    cp2 cp2(
        .clk			(clk		   ),
        .rst			(rst		   ),
        .cp2_irenable_0	(cp_irenable_0),
        .cp2_ts_0		(cp2_ts_0	   ),
        .cp2_fs_0		(cp2_fs_0	   ),
        .cp2_as_0		(cp2_as_0	   ),
        .cp2_ir_0		(cp_ir_0	   ),
        .cp2_tbusy_0	(cp2_tbusy_0   ),
        .cp2_fbusy_0	(cp2_fbusy_0   ),
        .cp2_abusy_0	(cp2_abusy_0   ),
        .cp2_tds_0		(cp2_tds_0	   ),
        .cp2_fds_0		(cp2_fds_0	   ),
        .cp2_tdata_0	(cp2_tdata_0   ),
        .cp2_fdata_0	(cp2_fdata_0   ),
        .cp2_excs_0	(cp2_excs_0   ),
        .cp2_exc_0		(cp2_exc_0	   ),
        .cp2_exccode_0  (cp2_exccode_0 ),
        .io_pin         (io_pin)
    );
endmodule
