`ifndef __BUS_HEADER__
    `define __BUS_HEADER__

    `define     WORDDATAW       32
    `define     WORDADDRW       32

    `define     WORDDATABUS     31:0
    `define     BYTEDATABUS     7:0
    `define     WORDADDRBUS     31:0
    `define     WEABUS          3:0
    `define     REGADDRBUS      4:0

    
    //指令bus
    `define     ISAOPLOC        31:26       
    `define     ISAFUNCLOC      5:0      
    `define     ISAFUNCW        6      
    `define     ISARSLOC        25:21       
    `define     ISARTLOC        20:16       
    `define     ISARDLOC        15:11       
    `define     ISASHAMTLOC     10:6       
    `define     ISAIMMLOC       15:0       
    `define     ISAOPBUS        5:0       
    `define     ISARSBUS        4:0       
    `define     ISARTBUS        4:0       
    `define     ISARDBUS        4:0      
    `define     ISAIMMBUS       15:0  
    `define     ISAFUNCBUS      5:0      
    `define     ISASHAMTBUS     4:0      

    `define     ISAIMMW         16
    `define     ISAEXTW         16
    `define     ISAIMMMSB       15
    
    `define     WORDADDRLOC     31:2

    `define     CPUEXEMODEW     1
    `define     CPUEXEMODEBUS   0:0

    `define     CPUKERNELMODE        1'b0
    `define     CPUINTERRUPTMODE     1'b1

    `define     ALUOPBUS        5:0

    `define     CTRLOPBUS       1:0
	`define     CTRLOPNOP	    2'h0 // No Operation
	`define     CTRLOPWRCR      2'h1 // ctrl op write ctrl register
	`define     CTRLOPEXRT	    2'h2 // return from exception
	`define     CTRLOPRCR      2'h3 // ctrl op read ctrl register

   	// exception bus define
	`define     ISA_EXP_W	    3	 // exception index width
    `define     ISAEXPBUS       2:0
	// exception index enum
	`define ISAEXP_NOEXP	    3'h0	 // None
	`define ISAEXP_EXTINT	    3'h1	 // out interrupt
	`define ISAEXP_UNDEFINSN    3'h2	 // undefine exception
	`define ISAEXP_OVERFLOW     3'h3	 // overflow exception
	`define ISAEXP_MISSALIGN    3'h4	 // address not align
	`define ISAEXP_TRAP	        3'h5	 // trap exception
	`define ISAEXP_PRVVIO	    3'h6	 // Violation  authority exception
	`define ISAEXP_CP2	        3'h7	 // Violation  authority exception

    `define CP2EXECCODEBUS      6:0

    `define     CPU_IRQ_CH     6
    `define     IRQ_BUS_LOC    15:10
    `define     IRQ_BUS        5:0

    `define     MEMOPBUS       3:0
    `define     MEMOPLW        4'h4
    `define     MEMOPLH        4'h5
    `define     MEMOPLHU       4'h6
    `define     MEMOPLB        4'h7
    `define     MEMOPLBU       4'h8
    `define     MEMOPSW        4'h3
    `define     MEMOPSH        4'h2
    `define     MEMOPSB        4'h1
    `define     MEMOPNOP       4'h0
    

    `define     REGADDRW        5
    `define     REGADDRBUS      4:0
    `define     REGNUM          32


    `define     CP2EXCCODEBUS   6:0
    `define     CP2TYPEBUS      1:0
    `define     FS_TYPE         2'b11
    `define     TS_TYPE         2'b10
    `define     AS_TYPE         2'b01
    `define     NONE_TYPE       2'b00
`endif
