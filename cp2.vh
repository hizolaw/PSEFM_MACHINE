
`ifndef __CP2DEF_HEADER__				  
	`define __CP2DEF_HEADER__
    
    `define NumAddrBus 4:0
    `define TasksNumAddrBusAddOne 6:0
    `define TasksNumAddrBus 5:0

    `define IO_REGS_NUM  11
    `define IO_NUM       4
    `define IO_TPORT_ADDR 0
    `define IO_TPIN_ADDR  1 
    `define IO_DDR_ADDR   2 
    `define IO_PINCY_ADDR_BASE   3 
    `define IO_PINPH_ADDR_BASE   7  
    `define IO_PA_BUS   31:24
    `define IO_PB_BUS   23:16
    `define IO_PC_BUS   15:8
    `define IO_PD_BUS   7:0

    `define IO_TPORT    0
    `define IO_TPIN     1
    `define IO_DDR      2

    `define TR_REGS_NUM   32
    `define TR_NUM   8
    
    `define TR_READ_ADDR_BASE    0
    `define TR_READB_ADDR_BASE   8
    `define TR_CY_ADDR_BASE      16
    `define TR_PH_ADDR_BASE      24

    `define TR_TASKS_NUM  64
    
    `define CY_INFO         0
    `define PH_INFO         1
    `define DEADLINE_INFO   2
    `define IS_CY_INFO      3
    `define TRIGGER_INFO    4
    `define STATUS_INFO     5
    `define EXIST_INFO      6
    `define OTHERS          7

    //contex_save_block command
    `define SET_TASK_PC_STACK  0
    //`define SET_TASK_STACK  1
    `define SET_OS_START    2
    `define SET_TASK_END_COMMAND    3

    `define MFC2_FMT        5'b00000
    `define MTC2_FMT        5'b00100
    `define MTC2TC_FMT      5'b00101
    `define TINIT_FMT       5'b00110
    `define TDEL_FMT        5'b00111
    `define TTTASK_FMT      5'b01000
    `define DISTTTASK_FMT   5'b01001
    `define CHTS            5'b01010
    `define SCHSTART        5'b01011
    `define CYTASK          5'b01100

    `define CP2_NOSEL      3'h5  
    `define CP2_TIMESEL    3'h0   
    `define CP2_IOSEL      3'h1   
    `define CP2_TRSEL      3'h2   
    `define CP2_TASKSEL    3'h3  
    `define CP2_GETTOPTASK 3'h4
     
    `define NumAddrBus 4:0
    `define TasksNumAddrBusAddOne 6:0
    `define TasksNumAddrBus 5:0
    `define DoubleWordDataBus  63:0
    `define DOUBLEWORD_DATA_W  64
    `define WORD_DATA_W        32
    
    `define TASKNOSEL           3'd7
    `define TASKCYSEL           3'd0
    `define TASKPHSEL           3'd1
    `define TASKDEADLINESEL     3'd2
    `define TASKISCYSEL         3'd3
    `define TASKISTTSEL         3'd4
    `define TASKSTATUSSEL       3'd5
    `define TASKEXISTSEL        3'd6


    `define READ_DATA_SRC_TIME  2'b00
    `define READ_DATA_SRC_TTR   2'b01
    `define READ_DATA_SRC_TASK   2'b10
    `define READ_DATA_SRC_TOP_TASK   2'b11
    
    `define CP2EXECCODE_TTTASK     7'b1 

`endif
