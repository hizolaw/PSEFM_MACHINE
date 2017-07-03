`ifndef __ALU_HEADER__
    `define __ALU_HEADER__
    
    //alu func define
    `define ALU_OP_NOP      6'b111111
    `define ALU_OP_ADD      6'b100000
    `define ALU_OP_ADDU     6'b100001
    `define ALU_OP_SUB      6'b100010
    `define ALU_OP_SUBU     6'b100011
    `define ALU_OP_AND      6'b100100
    `define ALU_OP_OR       6'b100101
    `define ALU_OP_XOR      6'b100110
    `define ALU_OP_NOR      6'b100111
    `define ALU_OP_SLT      6'b101010 //smaller than
    `define ALU_OP_SLTU     6'b101011
    `define ALU_OP_MULT     6'b011000
    `define ALU_OP_MULTU    6'b011001
    `define ALU_OP_DIV      6'b011010
    `define ALU_OP_DIVU     6'b011011
    `define ALU_OP_SLL      6'b000000 //shift left logic
    `define ALU_OP_SRL      6'b000010 //shift right logic
    `define ALU_OP_SRA      6'b000011 //shift right arithmetic
    `define ALU_OP_SLLV     6'b000100 //shift left logic
    `define ALU_OP_SRLV     6'b000110 //shift right logic
    `define ALU_OP_SRAV     6'b000111 //shift right arithmetic

`endif
