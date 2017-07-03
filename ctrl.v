`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2017 04:10:29 PM
// Design Name: 
// Module Name: ctrl
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
`include"ctrl.vh"
`include"signal.vh"
`include"vector.vh"
module ctrl (
	
    input  wire					  clk,			
	input  wire					  reset,		
	
    input  wire [`REGADDRBUS]	  creg_rd_addr, 
	output reg	[`WORDDATABUS]	  creg_rd_data, 
	output reg	[`CPUEXEMODEBUS]  exe_mode,		
	
    input  wire [`IRQ_BUS]         irq,			
	output reg					  int_detect,	
	output reg  [`ISAEXPBUS]      int_type,

    input  wire [`WORDADDRBUS]	  id_pc,		
	
    input  wire [`WORDADDRBUS]	  mem_pc,		
	input  wire					  mem_en,		
	input  wire					  mem_br_flag,	
	input  wire [`CTRLOPBUS]	  mem_ctrl_op,	
	input  wire [`REGADDRBUS]	  mem_dst_addr,
    input  wire                   mem_gpr_we_, 
	input  wire [`ISAEXPBUS]	  mem_exp_code, 
	input  wire [`WORDDATABUS]	  mem_out,		
	
    input wire                    mem_cp2_fs_0,
    input wire                    mem_cp2_ts_0,
    input wire                    mem_cp2_as_0,
    input wire [`WORDADDRBUS]     cp2_fdata_0,

    input  wire					  if_busy,		
	input  wire					  ld_hazard,	
	input  wire					  mem_busy,		

    input  wire                  cp2_exc_0, 
    input  wire                  cp2_excs_0, 
	
    output wire					  if_stall,		
	output wire					  id_stall,		
	output wire					  ex_stall,		
	output wire					  mem_stall,	

    output wire					  if_flush,		
	output wire					  id_flush,		
	output wire					  ex_flush,		
	output wire					  mem_flush,	
	output reg	[`WORDADDRBUS]	  new_pc,
    output reg  [`WORDDATABUS]    gpr_wr_data,
    output reg                    gpr_wea,
    output reg  [`REGADDRBUS]     gpr_wr_addr
);
    reg     [`WORDDATABUS]          cp0[31:0];  

	wire    [`IRQ_BUS]              mask;			

    wire    [`WORDDATABUS]          count;
    wire    [`WORDDATABUS]          compare;
    wire    [`WORDDATABUS]          status;
    wire    [`WORDDATABUS]          course;
    wire    [`WORDDATABUS]          epc;
    wire    [`WORDDATABUS]          prid;
	wire					        int_en;		

    assign count   =    cp0[`CTRL_COUNT  ];
    assign compare =    cp0[`CTRL_COMPARE];
    assign status  =    cp0[`CTRL_STATUS ];
    assign course  =    cp0[`CTRL_COUSE  ];
    assign epc     =    cp0[`CTRL_EPC    ];
    assign prid    =    cp0[`CTRL_PRID   ];
    assign int_en  =    status[0:0];
	assign mask    =    cp0[`CTRL_STATUS][`IRQ_BUS_LOC];			
	reg	 [`CPUEXEMODEBUS]		 pre_exe_mode;	
	reg							 pre_int_en;	
	//reg	 [`WordAddrBus]			 exp_vector;	
	//reg	 [`IsaExpBus]			 exp_code;		
	reg							 dly_flag;		

	reg [`WORDADDRBUS]		     pre_pc;			
	reg						     br_flag;			

	wire   stall	 = if_busy | mem_busy;
	assign if_stall	 = stall | ld_hazard;
	assign id_stall	 = stall;
	assign ex_stall	 = stall;
	assign mem_stall = stall;
	
    reg	   flush;
	assign if_flush	 = flush;
	assign id_flush	 = flush | ld_hazard;
	assign ex_flush	 = flush;
	assign mem_flush = flush;

	always @(*) begin
        new_pc = `WORDADDRW'h0;
		flush  = `DISABLE;
        if (mem_en == `ENABLE) begin 
			if (mem_exp_code != `ISAEXP_NOEXP) begin		 
				//new_pc = exp_vector;
				new_pc = `INT_VECTOR;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRLOPEXRT) begin 
				new_pc = epc;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRLOPWRCR) begin 
				new_pc = mem_pc;
				flush  = `ENABLE;
			end
		end
    end

    //中断检测
    always @(*) begin
		if (reset == `RESET_ENABLE) begin
		    int_detect = `DISABLE;
            int_type=`ISAEXP_NOEXP;
        end else begin
		    if ((int_en == `ENABLE) && ((|((~mask) & irq)) == `ENABLE || cp2_exc_0&cp2_excs_0)) begin
		    	int_detect = `ENABLE;
                if(cp2_exc_0&cp2_excs_0)begin
                    int_type=`ISAEXP_CP2;
                end begin
                    int_type=`ISAEXP_EXTINT;
                end
            end else begin
		    	int_detect = `DISABLE;
            end
        end
	end

    //cp0寄存器的读
    always @(*) begin
        case (creg_rd_addr)
            `CTRL_COUNT    , 
            `CTRL_COMPARE  , 
            `CTRL_STATUS   , 
            `CTRL_COUSE    , 
            `CTRL_EPC      , 
            `CTRL_PRID      :begin
                creg_rd_data = cp0[creg_rd_addr];
            end
            default         :begin
                creg_rd_data = `WORDDATAW'b0;
            end
        endcase
    end
//	always @(*) begin
//		case (creg_rd_addr)
//		   `CREG_ADDR_STATUS	 : begin 
//			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, int_en, exe_mode};
//		   end
//		   `CREG_ADDR_PRE_STATUS : begin 
//			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, 
//							   pre_int_en, pre_exe_mode};
//		   end
//		   `CREG_ADDR_PC		 : begin 
//			   creg_rd_data = {id_pc, `BYTE_OFFSET_W'h0};
//		   end
//		   `CREG_ADDR_EPC		 : begin 
//			   creg_rd_data = {epc, `BYTE_OFFSET_W'h0};
//		   end
//		   `CREG_ADDR_EXP_VECTOR : begin 
//			   creg_rd_data = {exp_vector, `BYTE_OFFSET_W'h0};
//		   end
//		   `CREG_ADDR_CAUSE		 : begin
//			   creg_rd_data = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}}, 
//							   dly_flag, exp_code};
//		   end
//		   `CREG_ADDR_INT_MASK	 : begin
//			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, mask};
//		   end
//		   `CREG_ADDR_IRQ		 : begin 
//			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, irq};
//		   end
//		   `CREG_ADDR_ROM_SIZE	 : begin 
//			   creg_rd_data = $unsigned(`ROM_SIZE);
//		   end
//		   `CREG_ADDR_SPM_SIZE	 : begin
//			   creg_rd_data = $unsigned(`SPM_SIZE);
//		   end
//		   `CREG_ADDR_CPU_INFO	 : begin 
//			   creg_rd_data = {`RELEASE_YEAR, `RELEASE_MONTH, 
//							   `RELEASE_VERSION, `RELEASE_REVISION};
//		   end
//		   default				 : begin 
//			   creg_rd_data = `WORD_DATA_W'h0;
//		   end
//		endcase
//	end
    
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
            exe_mode	 <=  `CPUKERNELMODE;
			cp0[`CTRL_STATUS ][0:0]	 <=  `DISABLE;
			pre_exe_mode <=  `CPUKERNELMODE;
			pre_int_en	 <=  `DISABLE;
			//exp_code	 <=  `ISAEXP_NOEXP;
			cp0[`CTRL_STATUS][`IRQ_BUS_LOC]		 <=  {`CPU_IRQ_CH{`ENABLE}};
			dly_flag	 <=  `DISABLE;
			//exp_vector	 <=  `WORDADDRW'h0;
			pre_pc		 <=  `WORDADDRW'h0;
			br_flag		 <=  `DISABLE;
            
            cp0[`CTRL_COUNT  ]       <=  `WORDADDRW'h0;
            cp0[`CTRL_COMPARE]      <=  `WORDADDRW'h0;
            //status       <=  `WORD_ADDR_W'h0;
            cp0[`CTRL_COUSE  ]       <=  `ISAEXP_NOEXP;
            cp0[`CTRL_EPC    ]          <=  `WORDADDRW'h0;
       
            gpr_wr_data <=  `WORDDATAW'b0;
            gpr_wea     <=  `DISABLE_;
            gpr_wr_addr <=  0;
		
        end else begin
			if ((mem_en == `ENABLE) && (stall == `DISABLE)) begin
				pre_pc		 <=  mem_pc;
				br_flag		 <=  mem_br_flag;
                if (mem_exp_code != `ISAEXP_NOEXP) begin// 发生异常
					exe_mode	 <=  `CPUINTERRUPTMODE;
			        cp0[`CTRL_STATUS ][0:0]	 <=  `DISABLE;
					pre_exe_mode <=  exe_mode;
					pre_int_en	 <=  int_en;
					//exp_code	 <=  mem_exp_code;
                    cp0[`CTRL_COUSE  ]       <=  mem_exp_code;
					dly_flag	 <=  br_flag;
                    cp0[`CTRL_EPC    ]  <=  pre_pc;
                    gpr_wea      <=  `DISABLE_;
				end else if (mem_ctrl_op == `CTRLOPEXRT) begin //  异常返回
					exe_mode	 <=  pre_exe_mode;
					cp0[`CTRL_STATUS ][0:0]		 <=  pre_int_en;
                    gpr_wea      <=  `DISABLE_;
				end else if (mem_ctrl_op == `CTRLOPWRCR) begin  //  控制寄存器的写入
				    // cp0寄存器写
                    case (mem_dst_addr)
                        `CTRL_COUNT    , 
                        `CTRL_COMPARE  , 
                        `CTRL_STATUS   , 
                        `CTRL_COUSE    , 
                        `CTRL_EPC      :begin 
                            cp0[creg_rd_addr]<=mem_out;
                            gpr_wea      <=  `DISABLE_;
                        end
                    endcase	
                end else begin
                    gpr_wr_data <= (mem_cp2_fs_0 | mem_cp2_as_0) ? cp2_fdata_0: mem_out;// 没写cp2_fds_0的检查，以后再说
                    gpr_wea     <=  mem_gpr_we_;
                    gpr_wr_addr <=  mem_dst_addr;

                end
			end
		end
	end
endmodule
