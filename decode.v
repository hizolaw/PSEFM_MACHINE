`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// // Company: 
// Engineer: 
// 
// Create Date: 06/02/2017 01:13:20 AM
// Design Name: 
// Module Name: decode
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
`include"instructions.vh"
`include"cp2.vh"
`include"ctrl.vh"
module decoder(
    input   wire    [`WORDADDRBUS]      if_pc,
    input   wire    [`WORDDATABUS]      if_insn,
    input   wire                        if_en,
    input   wire    [`WORDDATABUS]      gpr_rd_data_0,
    input   wire    [`WORDDATABUS]      gpr_rd_data_1,
    output  wire    [`REGADDRBUS]       gpr_rd_addr_0,   
    output  wire    [`REGADDRBUS]       gpr_rd_addr_1,   
	input   wire					    id_en,			 
	input   wire    [`REGADDRBUS]	    id_dst_addr,	 
	input   wire       				    id_gpr_we_,	
	input   wire    [`MEMOPBUS]		    id_mem_op,		 
    input   wire    [`CTRLOPBUS]        id_ctrl_op,
    input   wire                        id_cp2_as_0,
    input   wire                        id_cp2_fs_0,
	input   wire       				    ex_en,			 
	input   wire    [`REGADDRBUS]	    ex_dst_addr,	 
	input   wire       				    ex_gpr_we_,	
	input   wire    [`WORDDATABUS]	    ex_fwd_data,	 
    input   wire                        ex_cp2_fs_0,
    input   wire                        ex_cp2_as_0,
    input   wire    [`CTRLOPBUS]        ex_ctrl_op,
    input   wire [`MEMOPBUS]	     ex_mem_op	,  

	input   wire       				    mem_en,			 
	input   wire       				    mem_gpr_we_,	
	input   wire    [`REGADDRBUS]	    mem_dst_addr,	 
	input   wire    [`WORDDATABUS]	    mem_fwd_data,	
    input   wire                        mem_cp2_fs_0,
    input   wire                        mem_cp2_as_0,
    input   wire    [`CTRLOPBUS]        mem_ctrl_op,
    input   wire    [`WORDDATABUS]      cp2_fdata_0,

    input   wire    [`WORDDATABUS]      wb_fwd_data,

	input   wire    [`CPUEXEMODEBUS]    exe_mode,		
	input   wire    [`WORDDATABUS]	    creg_rd_data,	
	output  wire    [`REGADDRBUS]	    creg_rd_addr,	 
	output  reg	    [`ALUOPBUS]		    alu_op,		
	output  reg	    [`WORDDATABUS]	    alu_in_0,		
	output  reg	    [`WORDDATABUS]	    alu_in_1,		
	output  reg	    [`WORDDATABUS]	    br_addr,		
	output  reg	    				    br_taken,		
	output  reg	    				    br_flag,		
	output  reg	    [`MEMOPBUS]		    mem_op,		 
	output  wire    [`WORDDATABUS]	    mem_wr_data,	 
	output  reg	    [`CTRLOPBUS]	    ctrl_op,		 
	output  reg	    [`REGADDRBUS]	    dst_addr,		 
	output  reg	    				    gpr_we_,		 
	output  reg	    [`ISAEXPBUS]	    exp_code,		
	output  reg					        ld_hazard,		
    output  reg                         cp2_irenable_s,
    output  reg                         cp2_ts_s,
    output  reg                         cp2_fs_s,
    output  reg                         cp2_as_s,
    output  reg     [`WORDDATABUS]      cp2_wr_data
    );
	wire [`ISAOPBUS]	op		= if_insn[`ISAOPLOC];	  
	wire [`ISAFUNCBUS]	func	= if_insn[`ISAFUNCLOC];	  
	wire [`REGADDRBUS]	rs_addr = if_insn[`ISARSLOC]; 
	wire [`REGADDRBUS]	rt_addr = if_insn[`ISARTLOC]; 
	wire [`REGADDRBUS]	rd_addr = if_insn[`ISARDLOC]; 
	wire [`ISAIMMBUS]	imm		= if_insn[`ISAIMMLOC];	  
	wire [`ISASHAMTBUS] shamt   = if_insn[`ISASHAMTLOC];
    wire [`WORDDATABUS] imm_s = {{`ISAEXTW{imm[`ISAIMMMSB]}}, imm};
	wire [`REGADDRBUS]  fmt   =  rs_addr;
    wire [`WORDDATABUS] imm_u = {{`ISAEXTW{1'b0}}, imm};
	
    wire [`WORDDATABUS] shamt_u = {`WORDDATAW{shamt}};
    
    assign gpr_rd_addr_0 = rs_addr; 
	assign gpr_rd_addr_1 = rt_addr; 
	assign creg_rd_addr	 = (if_insn==`INS_ERET)?`CTRL_EPC:rd_addr; 
	reg         [`WORDDATABUS]  creg_data;
    reg			[`WORDDATABUS]	rs_data;						  
	wire signed [`WORDDATABUS]	s_rs_data = $signed(rs_data);	  
	reg			[`WORDDATABUS]	rt_data;						  
	wire signed [`WORDDATABUS]	s_rt_data = $signed(rt_data);	  
	assign mem_wr_data = rt_data; 
	

    wire [`WORDDATABUS] ret_addr  = if_pc + 3'd4;					
	wire [`WORDDATABUS] br_target = if_pc + imm_s;
	wire [`WORDDATABUS] jr_target = {4'b0,if_insn[25:0],2'b0};	
    //creg forwarding
    always@(*)begin
        if ((id_en == `ENABLE) && (id_ctrl_op==`CTRLOPWRCR) &&
            (creg_rd_addr==id_dst_addr))begin
            creg_data=ex_fwd_data;
        end else if((ex_en == `ENABLE) && (ex_ctrl_op==`CTRLOPWRCR) &&
            (creg_rd_addr==ex_dst_addr))begin
            creg_data=mem_fwd_data;
        end else if((mem_en == `ENABLE) && (mem_ctrl_op==`CTRLOPWRCR) &&
            (creg_rd_addr==mem_dst_addr))begin
            creg_data=wb_fwd_data;
        end else begin
            creg_data=creg_rd_data;
        end
    end

    //forwarding
    always@(*)begin
        /*rs*/
        if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && 
			(id_dst_addr == rs_addr)) begin
			rs_data = ex_fwd_data;  //ex的数据直通	 
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && 
					 (ex_dst_addr == rs_addr)) begin
			rs_data = mem_fwd_data;	//mem的数据直通
        end else if((mem_en == `ENABLE) && (mem_gpr_we_ == `ENABLE_) && 
					 (mem_dst_addr == rs_addr))begin //wb的数据直通
            rs_data = (mem_cp2_fs_0 | mem_cp2_as_0) ? cp2_fdata_0: wb_fwd_data;
        end else begin
			rs_data = gpr_rd_data_0;//gpr直接读取 
		end
        /*rt*/
		if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && 
			(id_dst_addr == rt_addr)) begin
			rt_data = ex_fwd_data;	
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && 
					 (ex_dst_addr == rt_addr)) begin
			rt_data = mem_fwd_data;	 
		end else if((mem_en == `ENABLE) && (mem_gpr_we_ == `ENABLE_) && 
					 (mem_dst_addr == rt_addr))begin //wb的数据直通
            rt_data = (mem_cp2_fs_0 | mem_cp2_as_0) ? cp2_fdata_0: wb_fwd_data;
        end else begin
			rt_data = gpr_rd_data_1; 
		end
    end

    //load harzard
	always @(*) begin
		if ((id_en == `ENABLE) && (|id_mem_op[4:3] ) &&((id_dst_addr == rs_addr) 
            || (id_dst_addr == rt_addr)) ||(ex_en ==`ENABLE &&(|ex_mem_op[4:3] )&&((ex_dst_addr == rs_addr) || (ex_dst_addr == rt_addr)))
            ||(id_en==`ENABLE&&id_gpr_we_==`ENABLE_&&(id_dst_addr==rs_addr||id_dst_addr==rt_addr)&&(id_cp2_fs_0|id_cp2_as_0))
            ||(ex_en==`ENABLE&&ex_gpr_we_==`ENABLE_&&(ex_dst_addr==rs_addr||ex_dst_addr==rt_addr)&&(ex_cp2_fs_0|ex_cp2_as_0))) begin
			ld_hazard = `ENABLE; 
		end else begin
			ld_hazard = `DISABLE; 
		end
	end

    //instrutions decode
    always @(*)begin
		alu_op	 = `ALU_OP_NOP;
		alu_in_0 = rs_data;
		alu_in_1 = rt_data;
		br_taken = `DISABLE;
		br_flag	 = `DISABLE;
		br_addr	 = {`WORDADDRW{1'b0}};
		mem_op	 = `MEMOPNOP;
		ctrl_op	 = `CTRLOPNOP;
		dst_addr = rt_addr;
		gpr_we_	 = `DISABLE_;
		exp_code = `ISAEXP_NOEXP;
        cp2_irenable_s = `DISABLE;
        cp2_ts_s = `DISABLE;
        cp2_fs_s = `DISABLE;
        cp2_as_s = `DISABLE;
        cp2_wr_data = {`WORDADDRW{1'b0}};
		//id_gpr_we_	  <=  gpr_we_;
        if(if_en == `ENABLE)begin
            case (op)
                `INS_FUNC_ALU   :begin
                    case(func)
                        `ALU_OP_ADD,
                        `ALU_OP_ADDU,
                        `ALU_OP_SUB,
                        `ALU_OP_SUBU,
                        `ALU_OP_AND,
                        `ALU_OP_OR,
                        `ALU_OP_XOR,
                        `ALU_OP_NOR,
                        `ALU_OP_SLT,
                        `ALU_OP_SLTU    :begin
                            alu_op = func;
                            dst_addr = rd_addr;
                            gpr_we_ = `ENABLE_;
                        end
                        `ALU_OP_SLL,
                        `ALU_OP_SRL,
                        `ALU_OP_SRA     :begin
                            alu_op   = func;
                            dst_addr = rd_addr;
                            alu_in_0 = rt_data;
                            alu_in_1 = shamt_u;
                        end
                        `ALU_OP_SLLV,
                        `ALU_OP_SRLV,
                        `ALU_OP_SRAV    :begin
                            alu_op = func;
                            dst_addr = rd_addr;
                            alu_in_0 = rt_data;
                            alu_in_1 = rs_data;
                            gpr_we_ = `ENABLE_;
                        end
                        default         :begin
                            exp_code=`ISAEXP_UNDEFINSN;
                        end
                    endcase
                end
                `INS_FUNC_CP0   :begin
                    case(rs_addr)
                        5'b00000:begin  //rs为0时，表示是mfc0指令
                            alu_in_0 = creg_data;
                            alu_in_1 = `WORDDATAW'b0;
		                    alu_op	 = `ALU_OP_ADDU;
                            dst_addr = rt_addr;
                            ctrl_op = `CTRLOPRCR;
                            gpr_we_ = `ENABLE_;
                        end
                        5'b00100:begin  //rs为100时，表示是mtc0指令
                            alu_in_0 = rt_data;
                            alu_in_1 = `WORDDATAW'b0;
		                    alu_op	 = `ALU_OP_ADDU;
                            ctrl_op = `CTRLOPWRCR;
                            dst_addr = creg_rd_addr;
                        end
                        5'b10000:begin
                            if(if_insn[5:0]==6'b011000&&exe_mode == `CPUKERNELMODE)begin
                                ctrl_op = `CTRLOPEXRT;
                            end else begin
                                exp_code = `ISAEXP_PRVVIO;
                            end
                        end
                        default:begin
                            exp_code=`ISAEXP_UNDEFINSN;
                        end
                    endcase
                end
                `INS_FUNC_CP2   :begin
                    cp2_irenable_s = `ENABLE;
                    //cp2_op_0 = 
                    case(fmt)
                        `MFC2_FMT       :begin
                            dst_addr = rt_addr;
                            gpr_we_ = `ENABLE_;
                            cp2_fs_s = `ENABLE;
                        end
                        `MTC2_FMT       :begin 
                            cp2_ts_s = `ENABLE;
                            cp2_wr_data = rt_data;
                        end
                        `MTC2TC_FMT     :begin
                            cp2_ts_s = `ENABLE;
                            cp2_wr_data = rt_data;
                        end
                        `TINIT_FMT      :begin
                            dst_addr = rt_addr;
                            gpr_we_ = `ENABLE_;
                            cp2_as_s = `ENABLE;
                        end
                        `TDEL_FMT       :begin
                            dst_addr = rt_addr;
                            gpr_we_ = `ENABLE_;
                            cp2_as_s = `ENABLE;
                        end
                        `TTTASK_FMT     :begin
                            dst_addr = rt_addr;
                            gpr_we_ = `ENABLE_;
                            cp2_as_s = `ENABLE;
                        end
                        `DISTTTASK_FMT  :begin
                            dst_addr = rt_addr;
                            gpr_we_ = `ENABLE_;
                            cp2_as_s = `ENABLE;
                        end
                        `CHTS           :begin
                            dst_addr = rt_addr;
                            gpr_we_  = `ENABLE_;
                            cp2_as_s = `ENABLE;
                        end
                        `SCHSTART       :begin//只需要传送指令
                            //cp2_as_s = `ENABLE;
                        end
                        default         :begin
                        end
                    endcase

                end
                `INS_FUNC_ERET  :begin  
                    if(exe_mode == `CPUKERNELMODE)begin
                        ctrl_op = `CTRLOPEXRT;
                        br_addr = creg_data;
                        br_taken = `ENABLE;
                        br_flag = `ENABLE;
                    end else begin
                        exp_code = `ISAEXP_PRVVIO;
                    end
                end
                `INS_FUNC_ADDI  :begin  
                    alu_op = `ALU_OP_ADD;
                    dst_addr = rt_addr;
                    alu_in_0 = rs_data;
                    alu_in_1 = imm_s;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_ADDIU :begin 
                    alu_op = `ALU_OP_ADDU;
                    dst_addr = rt_addr;
                    alu_in_0 = rs_data;
                    alu_in_1 = imm_s;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_ANDI  :begin  
                    alu_op = `ALU_OP_AND;
                    dst_addr = rt_addr;
                    alu_in_0 = rs_data;
                    alu_in_1 = imm_u;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_ORI   :begin   
                    alu_op = `ALU_OP_OR;
                    dst_addr = rt_addr;
                    alu_in_0 = rs_data;
                    alu_in_1 = imm_u;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_XORI  :begin  
                    alu_op   = `ALU_OP_XOR;
                    dst_addr = rt_addr;
                    alu_in_0 = rs_data;
                    alu_in_1 = imm_u;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_LUI   :begin
                    alu_op  =`ALU_OP_ADD;
                    alu_in_1= imm_u;
                    dst_addr = rt_addr;
                    gpr_we_ = `ENABLE_;

                end
                `INS_FUNC_LB    :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPLB;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_LBU   :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPLBU;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_LH    :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPLH;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_LHU   :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPLHU;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_SB    :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPSB;
                end
                `INS_FUNC_SH    :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPSH;
                end
                `INS_FUNC_LW    :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPLW;
                    gpr_we_ = `ENABLE_;
                end
                `INS_FUNC_SW    :begin
                    alu_op = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op = `MEMOPSW;
                end
                `INS_FUNC_BEQ   :begin
                    br_addr = br_target;
                    br_taken = (rs_data==rt_data)?`ENABLE:`DISABLE;
                    br_flag = `ENABLE;
                end
                `INS_FUNC_BNE   :begin
                    br_addr = br_target;
                    br_taken = (rs_data==rt_data)?`ENABLE:`DISABLE;
                    br_flag = `ENABLE;
                end
                `INS_FUNC_BGTZ  :begin
                    br_addr = br_target;
                    br_taken = ($signed(rs_data)>0)?`ENABLE:`DISABLE;
                    br_flag = `ENABLE;
                end
                `INS_FUNC_BLEZ  :begin
                    br_addr = br_target;
                    br_taken = ($signed(rs_data)<=0)?`ENABLE:`DISABLE;
                    br_flag = `ENABLE;
                end
                `INS_FUNC_BZ  :begin
                    br_addr = br_target;
                    if(rt_addr==5'b1)
                        br_taken = ($signed(rs_data)>=0)?`ENABLE:`DISABLE;
                    else
                        br_taken = ($signed(rs_data)<0)?`ENABLE:`DISABLE;

                    br_flag = `ENABLE;
                end
                //`INS_FUNC_BLTZ  :begin
                //    br_addr = br_target;
                //    br_taken = ($signed(rs_data)<0)?`ENABLE:`DISABLE;
                //    br_flag = `ENABLE;
                //end
                //`INS_FUNC_SLTI  :begin
                //end
                //`INS_FUNC_SLTIU :begin
                //end
                `INS_FUNC_J     :begin
                    br_addr = jr_target;
                    br_taken = `ENABLE;
                    br_flag = `ENABLE;
                end
                `INS_FUNC_JAL   :begin
                    alu_in_0 = ret_addr;
                    br_addr = imm_u<<2;
                    br_taken = `ENABLE;
                    br_flag = `ENABLE;
                    dst_addr = `REGADDRW'd31;
                    gpr_we_ = `ENABLE_;
                end
                default:begin
                    exp_code=`ISAEXP_UNDEFINSN;
                end
            endcase
        end
    end


endmodule
