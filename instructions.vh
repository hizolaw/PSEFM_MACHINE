`ifndef __INSTRUCTIONS__HEADER__
    `define __INSTRUCTIONS__HEADER__
    `define     INS_NOP     32'h00000000

    //Instruction op define
    `define     INS_FUNC_ALU     6'b000000
    `define     INS_FUNC_CP0     6'b010000
    `define     INS_FUNC_CP2     6'b010010
    `define     INS_FUNC_ERET    6'b010000
    `define     INS_FUNC_ADDI    6'b001000
    `define     INS_FUNC_ADDIU   6'b001001
    `define     INS_FUNC_ANDI    6'b001100
    `define     INS_FUNC_ORI     6'b001101
    `define     INS_FUNC_XORI    6'b001110
    `define     INS_FUNC_LUI     6'b001111
    `define     INS_FUNC_LB      6'b100000
    `define     INS_FUNC_LBU     6'b100100
    `define     INS_FUNC_LH      6'b100001
    `define     INS_FUNC_LHU     6'b100101
    `define     INS_FUNC_SB      6'b101000
    `define     INS_FUNC_SH      6'b101001
    `define     INS_FUNC_LW      6'b100011
    `define     INS_FUNC_SW      6'b101011
    `define     INS_FUNC_BEQ     6'b000100
    `define     INS_FUNC_BNE     6'b000101
    `define     INS_FUNC_BGTZ    6'b000111
    `define     INS_FUNC_BLEZ    6'b000110
    `define     INS_FUNC_BZ    6'b000001
    `define     INS_FUNC_BLTZ    6'b000001
    `define     INS_FUNC_BGEZAL  6'b000001
    `define     INS_FUNC_BLTZAL  6'b000001
    `define     INS_FUNC_SLTI    6'b001010
    `define     INS_FUNC_SLTIU   6'b001011
    `define     INS_FUNC_J       6'b000010
    `define     INS_FUNC_JAL     6'b000011
    
    `define     INS_ERET         {6'b010000,1'b1,19'b0,6'b011000}
    
    `define     CP2_FMT_MTC2     5'd00100
    `define     CP2_FMT_MFC2     5'd00000
    
    `define     CP2_FMT_MFCTC2   5'd00101

`endif
