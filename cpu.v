`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2017 04:31:01 PM
// Design Name: 
// Module Name: cpu
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

module cpu(
    input wire clk,
    input wire rst,
    input wire [`IRQ_BUS]       irq,
    //coprocessor's api
    output wire                 cp_irenable_0,
    output wire [`WORDDATABUS]  cp_ir_0,
    output wire                 cp2_as_0,
    output wire                 cp2_ts_0,
    output wire                 cp2_fs_0,
    output wire [`WORDDATABUS]  cp2_tdata_0,
    input  wire                 cp2_abusy_0,
    input  wire                 cp2_tbusy_0,
    input  wire                 cp2_fbusy_0,
    input wire                 cp2_fds_0,
    output  wire                 cp2_tds_0, 
    input  wire [`WORDDATABUS]  cp2_fdata_0,
    input  wire                 cp2_excs_0,
    input  wire                 cp2_exc_0,
    input  wire [`CP2EXECCODEBUS] cp2_exccode_0
    );
    wire                clk_;
    wire [`WORDDATABUS] insn;
    wire                stall;
    wire                if_flush;
    wire                id_flush;
    wire                ex_flush;
    wire                mem_flush;
    wire                int_detect;
    wire [`ISAEXPBUS]   int_type;
    wire [`WORDDATABUS] new_pc;
    wire                br_taken;
    wire [`WORDDATABUS] br_addr;
    wire [`WORDADDRBUS] if_pc;
    wire [`WORDDATABUS] if_insn;
    wire                if_busy;
    wire                mem_busy;

    wire    [`WORDDATABUS]      wb_fwd_data;

    wire [`WORDDATABUS] gpr_rd_data_0;
    wire [`WORDDATABUS] gpr_rd_data_1;
    wire [`REGADDRBUS]  gpr_rd_addr_0;
    wire [`REGADDRBUS]  gpr_rd_addr_1;

    wire  [`WORDDATABUS]    gpr_wr_data;
    wire                    gpr_wea;
    wire  [`REGADDRBUS]     gpr_wr_addr;

    wire [`WORDDATABUS] id_insn;


    wire [`WORDDATABUS] ex_insn;
    wire                ex_en;
    wire [`WORDDATABUS] ex_fwd_data;
    wire [`REGADDRBUS]  ex_dst_addr;
    wire                ex_gpr_we_;

    wire [`WORDDATABUS] mem_fwd_data;

    wire [`WORDADDRBUS] mem_data_addr;
    wire [`WORDDATABUS] mem_data_input;
    wire [`WEABUS]      mem_data_wea;
    wire [`WORDDATABUS] mem_data_output;

    wire [`WORDADDRBUS] mem_pc     ; 
    wire                mem_en     ; 
    wire				mem_br_flag;    
    wire [`CTRLOPBUS]   mem_ctrl_op; 
    wire [`REGADDRBUS]  mem_dst_addr; 
    wire				mem_gpr_we_;    
    wire [`ISAEXPBUS]   mem_exp_code; 
    wire [`WORDDATABUS] mem_out ;
    
    wire                mem_cp2_fs_0;
    wire                mem_cp2_ts_0;
    wire                mem_cp2_as_0;
 
    wire [`REGADDRBUS]	  creg_rd_addr;
	wire [`WORDDATABUS]	  creg_rd_data;
	wire [`CPUEXEMODEBUS] exe_mode;		

	wire					 ld_hazard;	 

    wire [`WORDADDRBUS]	     id_pc;		
    wire					 id_en;			
    wire [`ALUOPBUS]		 id_alu_op;		
    wire [`WORDDATABUS]	     id_alu_in_0;
    wire [`WORDDATABUS]	     id_alu_in_1;
    wire					 id_br_flag;
    wire [`MEMOPBUS]		 id_mem_op;
    wire [`WORDDATABUS]	     id_mem_wr_data;
    wire [`CTRLOPBUS]	     id_ctrl_op;	
    wire [`REGADDRBUS]	     id_dst_addr;
    wire					 id_gpr_we_;
    wire [`ISAEXPBUS]	     id_exp_code;	
    wire                     id_cp2_fs_0;
    wire                     id_cp2_ts_0;
    wire                     id_cp2_as_0;
    wire [`WORDDATABUS]      id_cp2_wr_data;
 
    wire [`WORDADDRBUS]      ex_pc;		  
    wire				     ex_br_flag;	  
    wire [`MEMOPBUS]	     ex_mem_op;	  
    wire [`WORDDATABUS]      ex_mem_wr_data;
    wire [`CTRLOPBUS]        ex_ctrl_op;	  
    wire [`ISAEXPBUS]        ex_exp_code;	  
    wire [`WORDDATABUS]      ex_out;		  
    wire                     ex_cp2_fs_0;
    wire                     ex_cp2_ts_0;
    wire                     ex_cp2_as_0;
    wire [`WORDDATABUS]      ex_cp2_wr_data;

    assign  cp2_fs_0=   ex_cp2_fs_0;
    assign  cp2_ts_0=   ex_cp2_ts_0;
    assign  cp2_as_0=   ex_cp2_as_0;
    assign  clk_    =   ~clk;
    assign  cp_ir_0 =  id_insn;

    assign  wb_fwd_data = mem_out;

    mem mem(
        .clka(clk_),
        .clkb(clk_),
        .rst(rst),
        .insn_addr(if_pc),
        .insn(insn),
        .mem_data_addr(mem_data_addr),
        .mem_data_input(mem_data_input),
        .mem_data_wea(mem_data_wea),
        .mem_data_output(mem_data_output)
    );

    if_stage if_stage(
        .clk(clk),
        .rst(rst),
        .insn(insn),
        .stall(if_stall),
        .flush(if_flush),
        .new_pc(new_pc),
        .br_taken(br_taken),
        .br_addr(br_addr),
        //.instruction_mem_addr(instruction_mem_addr),
        .busy(if_busy),
        .if_pc_phisics(if_pc),
        .if_insn(if_insn),
        .if_en(if_en)
    );

    id_stage id_stage(
        .clk(clk),
        .reset(rst),

        .gpr_rd_data_0(gpr_rd_data_0),
        .gpr_rd_data_1(gpr_rd_data_1),
        .gpr_rd_addr_0(gpr_rd_addr_0),
        .gpr_rd_addr_1(gpr_rd_addr_1),

        .ex_en(ex_en),			
        .ex_fwd_data(ex_fwd_data),	 
        .ex_dst_addr(ex_dst_addr),	 
        .ex_gpr_we_(ex_gpr_we_),	 
        .ex_cp2_fs_0(ex_cp2_fs_0),
        .ex_cp2_as_0(ex_cp2_as_0),
        .ex_ctrl_op(ex_ctrl_op),
     
        .mem_en			(mem_en			),		 
        .mem_gpr_we_	(mem_gpr_we_	), 
        .mem_dst_addr	(mem_dst_addr	),
        .mem_cp2_fs_0	(mem_cp2_fs_0	),
        .mem_cp2_as_0	(mem_cp2_as_0	),
        .mem_ctrl_op    (mem_ctrl_op),
        .cp2_fdata_0	(cp2_fdata_0	),
                                     
        .wb_fwd_data	(wb_fwd_data	),
		                   
        .mem_fwd_data(mem_fwd_data),	 
                        
        .exe_mode(exe_mode),		 
        .creg_rd_data(creg_rd_data),	 
        .creg_rd_addr(creg_rd_addr),	 
                        
        .stall(id_stall),			 
        .flush(id_flush),			 
        .br_addr(br_addr),		 
        .br_taken(br_taken),		 
        .ld_hazard(ld_hazard),		 
                        
        .if_pc(if_pc),			 
        .if_en(if_en),			 
                        
        .id_pc(id_pc),			 
        .id_en(id_en),			 
        .id_alu_op(id_alu_op),		 
        .id_alu_in_0(id_alu_in_0),	 
        .id_alu_in_1(id_alu_in_1),	 
        .id_br_flag(id_br_flag),	 
        .id_mem_op(id_mem_op),		 
        .id_mem_wr_data(id_mem_wr_data), 
        .id_ctrl_op(id_ctrl_op),	 
        .id_dst_addr(id_dst_addr),	 
        .id_gpr_we_(id_gpr_we_),	 
        .id_exp_code(id_exp_code),
        .id_insn(id_insn),
        .cp_irenable_0(cp_irenable_0),
        .id_cp2_fs_0(id_cp2_fs_0),
        .id_cp2_ts_0(id_cp2_ts_0),
        .id_cp2_as_0(id_cp2_as_0),
        .id_cp2_wr_data(id_cp2_wr_data),
        .if_insn(if_insn)		 
    );
    
    ex_stage ex_stage(
        .clk(clk),			  
        .reset(rst),		  
                       
        .stall(ex_stall),		  
        .flush(ex_flush),		  
        .int_detect(int_detect),	  
        .int_type(int_type)    ,

        .fwd_data(ex_fwd_data),	  
                       
        .id_pc(id_pc),		  
        .id_en(id_en),		  
        .id_alu_op(id_alu_op),	  
        .id_alu_in_0(id_alu_in_0),	  
        .id_alu_in_1(id_alu_in_1),	  
        .id_br_flag(id_br_flag),	  
        .id_mem_op(id_mem_op),	  
        .id_mem_wr_data(id_mem_wr_data),
        .id_ctrl_op(id_ctrl_op),	  
        .id_dst_addr(id_dst_addr),	  
        .id_gpr_we_(id_gpr_we_),	  
        .id_exp_code(id_exp_code),
        .id_cp2_fs_0(id_cp2_fs_0),
        .id_cp2_ts_0(id_cp2_ts_0),
        .id_cp2_as_0(id_cp2_as_0),
        .id_cp2_wr_data(id_cp2_wr_data),

        .ex_pc(ex_pc),		  
        .ex_en(ex_en),		  
        .ex_br_flag(ex_br_flag),	  
        .ex_mem_op(ex_mem_op),	  
        .ex_mem_wr_data(ex_mem_wr_data),
        .ex_ctrl_op(ex_ctrl_op),	  
        .ex_dst_addr(ex_dst_addr),	  
        .ex_gpr_we_(ex_gpr_we_),	  
        .ex_exp_code(ex_exp_code),	  
        .ex_out(ex_out),		  
        .ex_cp2_fs_0(ex_cp2_fs_0),
        .ex_cp2_ts_0(ex_cp2_ts_0),
        .ex_cp2_as_0(ex_cp2_as_0),
        .ex_cp2_wr_data(ex_cp2_wr_data)
    );

    mem_stage mem_stage(
        .clk(clk),			   
        .reset(rst),		   
        
        .stall(mem_stall),		   
        .flush(mem_flush),		   
        .busy(mem_busy),		   
                        
        .fwd_data(mem_fwd_data),	   
                         
        .ex_pc          (ex_pc),		   
        .ex_en          (ex_en),		   
        .ex_br_flag     (ex_br_flag),	   
        .ex_mem_op      (ex_mem_op),	   
        .ex_mem_wr_data (ex_mem_wr_data), 
        .ex_ctrl_op     (ex_ctrl_op),	   
        .ex_dst_addr    (ex_dst_addr),	   
        .ex_gpr_we_     (ex_gpr_we_),	   
        .ex_exp_code    (ex_exp_code),	   
        .ex_out         (ex_out),
        .ex_cp2_fs_0    (ex_cp2_fs_0),
        .ex_cp2_ts_0    (ex_cp2_ts_0),
        .ex_cp2_as_0    (ex_cp2_as_0),
        .ex_cp2_wr_data (ex_cp2_wr_data),
        
        .mem_cp2_fs_0       (mem_cp2_fs_0),
        .mem_cp2_ts_0       (mem_cp2_ts_0),
        .mem_cp2_as_0       (mem_cp2_as_0),
        .cp2_tdata_0        (cp2_tdata_0),
        .cp2_tds_0          (cp2_tds_0),
                         
        .mem_data_addr  (mem_data_addr  ),
        .mem_data_input (mem_data_input ),
        .mem_data_wea   (mem_data_wea   ),
        .mem_data_output(mem_data_output),
                         
                         
        .mem_pc         (mem_pc         ),
        .mem_en         (mem_en         ),
        .mem_br_flag    (mem_br_flag    ),	   
        .mem_ctrl_op    (mem_ctrl_op    ),	   
        .mem_dst_addr   (mem_dst_addr   ),   
        .mem_gpr_we_    (mem_gpr_we_    ),	   
        .mem_exp_code   (mem_exp_code   ),   
        .mem_out		(mem_out		)   
    );

    ctrl ctrl(
        .clk(clk),
        .reset(rst),

        .creg_rd_addr(creg_rd_addr),
        .creg_rd_data(creg_rd_data),
        .exe_mode(exe_mode),

        .irq			    (irq		 ),			
        .int_detect			(int_detect	 ),	
        .int_type(int_type)    ,
                                         
        .id_pc			    (id_pc		 ),		
                                         
        .mem_pc			    (mem_pc		 ),		
        .mem_en			    (mem_en		 ),		
        .mem_br_flag		(mem_br_flag ),	
        .mem_ctrl_op		(mem_ctrl_op ),	
        .mem_dst_addr		(mem_dst_addr),
        .mem_gpr_we_        (mem_gpr_we_),
        .mem_exp_code		(mem_exp_code), 
        .mem_out			(mem_out	 ),		
                                         
        .mem_cp2_fs_0		(mem_cp2_fs_0),
        .mem_cp2_ts_0		(mem_cp2_ts_0),
        .mem_cp2_as_0		(mem_cp2_as_0),
        .cp2_fdata_0		(cp2_fdata_0 ),

        .if_busy			(if_busy	 ),		
        .ld_hazard			(ld_hazard	 ),	
        .mem_busy			(mem_busy	 ),		
                                         
        .cp2_exc_0          (cp2_exc_0),
        .cp2_excs_0         (cp2_excs_0),
        
        .if_stall			(if_stall	 ),		
        .id_stall			(id_stall	 ),		
        .ex_stall			(ex_stall	 ),		
        .mem_stall			(mem_stall	 ),	
                                
        .if_flush			(if_flush	 ),		
        .id_flush			(id_flush	 ),		
        .ex_flush			(ex_flush	 ),		
        .mem_flush			(mem_flush	 ),	
        .new_pc		        (new_pc), 		
        .gpr_wr_data        (gpr_wr_data),
        .gpr_wea            (gpr_wea),
        .gpr_wr_addr        (gpr_wr_addr)
    );


    gpr gpr(
        .clk_(clk_),
        .reset(rst),
        .rd_addr_0(gpr_rd_addr_0),
        .rd_addr_1(gpr_rd_addr_1),
        .rd_data_0(gpr_rd_data_0),
        .rd_data_1(gpr_rd_data_1),
        .we_(gpr_wea),
        .wr_addr(gpr_wr_addr),
        .wr_data(gpr_wr_data)
    );
endmodule
