`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2017 03:08:14 PM
// Design Name: 
// Module Name: mem_ctrl
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
module mem_ctrl(
	input  wire				   ex_en,		   
	input  wire [`MEMOPBUS]	   ex_mem_op,	   
	input  wire [`WORDDATABUS] ex_mem_wr_data, 
	input  wire [`WORDDATABUS] ex_out,		   
    input  wire [`WORDDATABUS] rd_data,
	
    //input  wire [`WORDDATABUS] rd_data,		   
	output wire [`WORDADDRBUS] addr,		   
	//output reg				   as_,			   
//	output reg				   rw,			   
	output reg [`WORDDATABUS]  wr_data,
    output reg  [`WEABUS]      wea,
    //output reg  [`WEABUS]      rea,
	
    output reg  [`WORDDATABUS] out		   
	//output reg				   miss_align
    );
    
//	wire [`ByteOffsetBus]	 offset;		   

	//assign wr_data = ex_mem_wr_data;		   
	assign addr	   = ex_out;	  
//	assign offset  = ex_out[`ByteOffsetLoc];  
    
    always @(*) begin
		out		   =  `WORDDATAW'h0;
		//as_		   = `DISABLE_;
	    wr_data    = ex_mem_wr_data;		   
		//rw		   = `READ;
        wea        =  4'b0000;
        if(ex_en ==`ENABLE)begin
            case(ex_mem_op)
                `MEMOPSW     :begin
                    //rw  = `WRITE;
                    wea = 4'b1111;
         //           as  = `ENABLE;
                end
                `MEMOPSH     :begin
                    //rw  = `WRITE;
                    wr_data = ex_mem_wr_data<<{addr[1],1'b0};
                    wea = 4'b0011<<{addr[1],1'b0};
          //          as  = `ENABLE;
                end
                `MEMOPSB     :begin
                    //rw  = `WRITE;
                    wr_data = ex_mem_wr_data<<addr[1:0];
                    wea = 4'b0001<<addr[1:0];
          //          as  = `ENABLE;
                end
                `MEMOPLW:begin
                    out=rd_data;
                end
                `MEMOPLHU     :begin
                    if(addr[1])
                        out=(rd_data&32'hffff0000)>>16;
                    else
                        out=(rd_data&32'h0000ffff);
                end
                `MEMOPLH    :begin
                    if(addr[1])
                        out={rd_data[31],16'h0,rd_data[30:16]};
                    else
                        out={rd_data[15],16'h0,rd_data[14:0]};
                end
                `MEMOPLB     :begin
                    out=((~(32'hff<<addr[1:0]))&rd_data)>>(addr[1:0]);
                    out={out[7],24'h0,out[6:0]};
                end
                `MEMOPLBU    :begin
                    out=((~(32'hff<<addr[1:0]))&rd_data)>>(addr[1:0]);
                end
                default      :begin// 无内存访问
                    out = ex_out;
                end
            endcase
        end
    end


endmodule
