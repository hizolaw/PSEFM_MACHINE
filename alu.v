`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2017 10:34:12 PM
// Design Name: 
// Module Name: alu
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
`include"alu.vh"

module alu(
    input wire rst,
    input wire [`WORDDATABUS] alu_a,
    input wire [`WORDDATABUS] alu_b,
    input wire [`ALUOPBUS]    alu_op,
    output reg [`WORDDATABUS] alu_out,
    //output wire [`WORDDATABUS] alu_out_hi,
    output reg                of
    //output wire               div_valid
);
    
    //reg [1:0] alu_status;
    
      
 	/********** 有符号的加法、减法 **********/
	wire signed [`WORDDATABUS] s_alu_a    = $signed(alu_a); 
	wire signed [`WORDDATABUS] s_alu_b    = $signed(alu_b); 
	wire signed [`WORDDATABUS] s_alu_out  = $signed(alu_out);  
 
    //wire s_axis_divisor_tvalid;
    //wire s_axis_divisor_tvalidu;
   
    //wire [31:0]s_axis_divisor_tdata;
    //wire [31:0]s_axis_dividend_tdata;
    //wire [63:0]m_axis_dout_tdata;
    //wire m_axis_dout_tvalid;
    //wire [31:0]s_axis_divisor_tdatau;
    //wire [31:0]s_axis_dividend_tdatau;
    //wire [63:0]m_axis_dout_tdatau;
    //wire m_axis_dout_tvalidu;
    /**mul **/ 
    //wire [63:0] mul_out_unsigned;
    //wire [63:0] mul_out_signed;
    //wire mul_unsigned_clk;
    //wire mul_signed_clk;
    //wire nclk;
    //wire aclk;
    //wire aclku;
    //wire is_div;
    //wire is_mul;

    //assign mul_unsigned_clk = (alu_op==`ALU_OP_MULTU)?clk:0;
    //assign mul_signed_clk = (alu_op==`ALU_OP_MULT)?clk:0;
    //assign aclk = (alu_op==`ALU_OP_DIV)?clk:0;
    //assign s_axis_divisor_tvalid = (alu_op==`ALU_OP_DIV)?div_valid:0;
    //assign aclku = (alu_op==`ALU_OP_DIVU)?clk:0;
    //assign s_axis_divisor_tvalidu = (alu_op==`ALU_OP_DIVU)?div_valid:0;
    //assign is_div=(alu_op==`ALU_OP_DIV | alu_op==`ALU_OP_DIVU)?1:0;
    //assign is_mul=(alu_op==`ALU_OP_MULT | alu_op==`ALU_OP_MULTU)?1:0;
    //assign nclk=(is_div)?
    //            0:
    //            ((is_mul)?0:clk);
   // assign div_valid = (alu_op==`ALU_OP_DIV)?m_axis_dout_tvalid:m_axis_dout_tvalidu;
    /*输出选择*/
    //assign alu_out = alu_op==`ALU_OP_DIV?m_axis_dout_tdata[63:32]:
    //                (alu_op==`ALU_OP_DIVU?m_axis_dout_tdatau[63:32]:
    //                (alu_op==`ALU_OP_MULT?mul_out_signed[31:0]:
    //                (alu_op==`ALU_OP_MULTU?mul_out_unsigned[31:0]:
    //                                       alu_out_normal)));
    //assign alu_out_hi =  alu_op==`ALU_OP_DIV?m_axis_dout_tdata[31:0]:
    //                    (alu_op==`ALU_OP_DIVU?m_axis_dout_tdatau[31:0]:
    //                    (alu_op==`ALU_OP_MULT?mul_out_signed[63:32]:
    //                    (alu_op==`ALU_OP_MULTU?mul_out_unsigned[63:32]:
    //                                           0)));;

    //div_gen_signed div_signed(
    //    .aclk(aclk),
    //    .s_axis_divisor_tdata(s_axis_divisor_tdata),
    //    .s_axis_divisor_tvalid(s_axis_divisor_tvalid),
    //    .s_axis_dividend_tdata(s_axis_dividend_tdata),
    //    .s_axis_dividend_tvalid(1),
    //    .m_axis_dout_tdata(m_axis_dout_tdata),
    //    .m_axis_dout_tvalid(m_axis_dout_tvalid)
    //);
    //div_gen_unsigned div_unsigned(
    //    .aclk(aclku),
    //    .s_axis_divisor_tdata(s_axis_divisor_tdatau),
    //    .s_axis_divisor_tvalid(s_axis_divisor_tvalidu),
    //    .s_axis_dividend_tdata(s_axis_dividend_tdatau),
    //    .s_axis_dividend_tvalid(1),
    //    .m_axis_dout_tdata(m_axis_dout_tdatau),
    //    .m_axis_dout_tvalid(m_axis_dout_tvalidu)
    //);

    //mult_gen_unsigned mul_unsigned(
    //    .A(alu_a),
    //    .B(alu_b),
    //    .P(mul_out_unsigned),
    //    .CLK(mul_unsigned_clk)
    //);
    //mult_gen_signed mul_signed(
    //    .A(alu_a),
    //    .B(alu_b),
    //    .P(mul_out_signed),
    //    .CLK(mul_signed_clk)
    //);

    always @(*) begin
        if(rst==`RESET_ENABLE)begin
            alu_out=0;
        end else begin
            case (alu_op)
                `ALU_OP_ADDU,`ALU_OP_ADD: begin
                    alu_out = alu_a + alu_b;
                end
                `ALU_OP_SUBU,`ALU_OP_SUB,`ALU_OP_SLT,`ALU_OP_SLTU: begin
                    alu_out = alu_a - alu_b;
                end
                `ALU_OP_AND: begin
                    alu_out = alu_a & alu_b;
                end
                `ALU_OP_OR : begin
                    alu_out = alu_a | alu_b;
                end
                `ALU_OP_XOR: begin
                    alu_out = alu_a ^ alu_b;
                end
                `ALU_OP_NOR: begin
                    alu_out = ~(alu_a | alu_b);
                end
                `ALU_OP_SLL,`ALU_OP_SLLV: begin
                    alu_out = alu_a << alu_b;
                end
                `ALU_OP_SRL,`ALU_OP_SRLV: begin
                    alu_out = alu_a >> alu_b;
                end
                `ALU_OP_SRA,`ALU_OP_SRAV: begin
                    alu_out = {alu_a[31],31'b0}|({1'b0,alu_a[30:0]} >> alu_b);
                end
                default: begin
                    alu_out = alu_a;
                end
            endcase
        end
    end

    always @(*) begin
		case (alu_op)
			`ALU_OP_ADD : begin 
				if (((s_alu_a > 0) && (s_alu_b > 0) && (s_alu_out < 0)) ||
					((s_alu_a < 0) && (s_alu_b < 0) && (s_alu_out > 0))) begin
					of <= `HIGH;
				end else begin
					of <= `LOW;
				end
			end
			`ALU_OP_SUB : begin 
				if (((s_alu_a < 0) && (s_alu_b > 0) && (s_alu_out > 0)) ||
					((s_alu_a > 0) && (s_alu_b < 0) && (s_alu_out < 0))) begin
					of <= `HIGH;
				end else begin
					of <= `LOW;
				end
			end
			default		: begin 
				of <= `LOW;
			end
		endcase
    end


endmodule
