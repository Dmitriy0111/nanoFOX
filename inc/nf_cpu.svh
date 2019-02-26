/*
*  File            :   nf_cpu.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit commands
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

//  Base Instruction Formats for ISA
//  fields          31              25 24       20 19       15 14       12 11           7 6         0
//  instr R-type    |     funct7     | |   rs2   | |   rs1   | |  funct3 | |      rd    | | opcode  |
//                  --------------------------------------------------------------------------------
//  fields          31              25 24       20 19       15 14       12 11           7 6         0
//  instr I-type    |            imm[11:0]       | |   rs1   | |  funct3 | |      rd    | | opcode  |
//                  --------------------------------------------------------------------------------
//  fields          31              25 24       20 19       15 14       12 11           7 6         0
//  instr S-type    |   imm[11:5]    | |   rs2   | |   rs1   | |  funct3 | |   imm[4:0] | | opcode  |
//                  --------------------------------------------------------------------------------
//  fields          31              25 24       20 19       15 14       12 11           7 6         0
//  instr U-type    |                        imm[31:12]                  | |      rd    | | opcode  |
//                  --------------------------------------------------------------------------------
//  fields          31          31 30           25 24       20 19       15 14       12 11           8 7         7 6         0
//  instr B-type    |  imm[12]   | |  imm[10:5]  | |   rs2   | |   rs1   | |  funct3 | |   imm[4:1] | | imm[11] | | opcode  |
//                  --------------------------------------------------------------------------------------------------------
//  fields          31          31 30           21 20         20 19            12 11           7 6         0
//  instr J-type    |  imm[20]   | |  imm[10:1]  | |  imm[11]  | |  imm[19:12]  | |      rd    | | opcode  |
//                  ---------------------------------------------------------------------------------------
//  rs1 and rs2 are sources registers, rd are destination register. 
//  imm is immediate data. 
//  opcode is operation code for instruction
//  funct3 and funct7 help's for encode more instructions with same opcode field

// LUI -    Load Upper Immediate
//          rd = Immed << 12
`define C_LUI       7'b0110111
`define F3_LUI      3'b???    
`define F7_LUI      7'b???????

// AUIPC -  U-type, Add upper immediate to PC
//          rd = PC + Immed << 12
`define C_AUIPC     7'b0010111
`define F3_AUIPC    3'b???    
`define F7_AUIPC    7'b???????

// JAL -    J-type, Jump and load PC + 4 in register
//          rd = PC + 4
//          PC = Immed << 12
`define C_JAL       7'b1101111
`define F3_JAL      3'b???
`define F7_JAL      7'b???????

// JALR -   I-type, Jump and link register
//          rd = PC + 4
//          PC = Immed << 12
`define C_JALR      7'b1100111
`define F3_JALR     3'b000 
`define F7_JALR     7'b???????

// BEQ -    B-type, Branch if equal
// 
`define C_BEQ       7'b1100011
`define F3_BEQ      3'b000
`define F7_BEQ      7'b???????
                            
// BNE -    B-type, Branch if not equal
// 
`define C_BNE       7'b1100011
`define F3_BNE      3'b001
`define F7_BNE      7'b???????

// BLT -    B-type, Branch if less
// 
`define C_BLT       7'b1100011
`define F3_BLT      3'b100    
`define F7_BLT      7'b???????

// BGE -    B-type, Branch if greater
// 
`define C_BGE       7'b1100011
`define F3_BGE      3'b101    
`define F7_BGE      7'b???????
                              
// BLTU -   B-type, Branch if less unsigned
// 
`define C_BLTU      7'b1100011
`define F3_BLTU     3'b110    
`define F7_BLTU     7'b???????
                              
// BGEU -   B-type, Branch if greater unsigned
//
`define C_BGEU      7'b1100011
`define F3_BGEU     3'b111    
`define F7_BGEU     7'b???????
                              
// LB -     I-type, Load byte
//          rd = mem[addr]
`define C_LB        7'b0000011
`define F3_LB       3'b000    
`define F7_LB       7'b???????
                              
// LH -     I-type, Load half word
//          rd = mem[addr]
`define C_LH        7'b0000011
`define F3_LH       3'b001    
`define F7_LH       7'b???????
                              
// LW -     I-type, Load word
//          rd = mem[addr]
`define C_LW        7'b0000011
`define F3_LW       3'b010    
`define F7_LW       7'b???????
                              
// LBU -    I-type, Load byte unsigned
//          rd = mem[addr]
`define C_LBU       7'b0000011
`define F3_LBU      3'b100    
`define F7_LBU      7'b???????
                              
// LHU -    I-type, Load half word unsigned
//          rd = mem[addr]
`define C_LHU       7'b0000011
`define F3_LHU      3'b101    
`define F7_LHU      7'b???????
                              
// SB -     S-type, Store byte
//          mem[addr] = rs1
`define C_SB        7'b0100011
`define F3_SB       3'b000    
`define F7_SB       7'b???????
                              
// SH -     S-type, Store half word
//          mem[addr] = rs1
`define C_SH        7'b0100011
`define F3_SH       3'b001    
`define F7_SH       7'b???????
                              
// SW -     S-type, Store word
//          mem[addr] = rs1
`define C_SW        7'b0100011
`define F3_SW       3'b010    
`define F7_SW       7'b???????
                              
// ADDI -   I-type, Adding with immidiate
//          rd = rs1 + Immed
`define C_ADDI      7'b0010011
`define F3_ADDI     3'b000    
`define F7_ADDI     7'b???????
                              
// SLTI -   I-type, Set less immidiate
//          rd = rs1 < signed   ( Immed ) ? '0 : '1
`define C_SLTI      7'b0010011
`define F3_SLTI     3'b010    
`define F7_SLTI     7'b???????
                              
// SLTIU -  I-type, Set less unsigned immidiate
//          rd = rs1 < unsigned ( Immed ) ? '0 : '1
`define C_SLTIU     7'b0010011
`define F3_SLTIU    3'b011    
`define F7_SLTIU    7'b???????
                              
// XORI -   I-type, Excluding Or operation with immidiate
//          rd = rs1 ^ Immed
`define C_XORI      7'b0010011
`define F3_XORI     3'b100    
`define F7_XORI     7'b???????
                              
// ORI -    I-type, Or operation with immidiate
//          rd = rs1 | Immed
`define C_ORI       7'b0010011
`define F3_ORI      3'b110    
`define F7_ORI      7'b???????
                              
// ANDI -   I-type, And operation with immidiate
//          rd = rs1 & Immed
`define C_ANDI      7'b0010011
`define F3_ANDI     3'b111    
`define F7_ANDI     7'b???????
                              
// SLLI -   I-type, Shift Left Logical
//          rd = rs1 << shamt
`define C_SLLI      7'b0010011
`define F3_SLLI     3'b001    
`define F7_SLLI     7'b0000000
                              
// SRLI -   I-type, Shift Right Logical
//          rd = rs1 >> shamt
`define C_SRLI      7'b0010011
`define F3_SRLI     3'b101    
`define F7_SRLI     7'b0000000
                              
// SRAI -   I-type, Shift Right Arifmetical
//          rd = rs1 >> shamt
`define C_SRAI      7'b0010011
`define F3_SRAI     3'b101    
`define F7_SRAI     7'b0100000
                              
// ADD -    R-type, Adding with register
//          rd = rs1 + rs2
`define C_ADD       7'b0110011
`define F3_ADD      3'b000    
`define F7_ADD      7'b0000000
                              
// SUB -    R-type, Adding with register
//          rd = rs1 - rs2
`define C_SUB       7'b0110011
`define F3_SUB      3'b000    
`define F7_SUB      7'b0100000
                              
// SLL -    R-type, Set left logical
//          rd = rs1 << rs2
`define C_SLL       7'b0110011
`define F3_SLL      3'b001    
`define F7_SLL      7'b0000000
                              
// SLT -    R-type, Set less
//          rd = rs1 < rs2 ? '0 : '1
`define C_SLT       7'b0110011
`define F3_SLT      3'b010    
`define F7_SLT      7'b0000000
                              
// SLTU -   R-type, Set less unsigned
//          rd = rs1 < rs2 ? '0 : '1
`define C_SLTU      7'b0110011
`define F3_SLTU     3'b011    
`define F7_SLTU     7'b0000000
                              
// XOR -    R-type, Excluding Or two register
//          rd = rs1 ^ rs2
`define C_XOR       7'b0110011
`define F3_XOR      3'b100    
`define F7_XOR      7'b0000000
                              
// SRL -    R-type, Set right logical
//          rd = rs1 >> rs2
`define C_SRL       7'b0110011
`define F3_SRL      3'b101    
`define F7_SRL      7'b0000000
                              
// SRA -    R-type, Set right arifmetical
//          rd = rs1 >> rs2
`define C_SRA       7'b0110011
`define F3_SRA      3'b101    
`define F7_SRA      7'b0100000
                              
// OR -     R-type, Or two register
//          rd = rs1 | rs2
`define C_OR        7'b0110011
`define F3_OR       3'b110    
`define F7_OR       7'b0000000
                              
// AND -    R-type, And two register
//          rd = rs1 & rs2
`define C_AND       7'b0110011  
`define F3_AND      3'b111      
`define F7_AND      7'b0000000
                                
// For Verification
`define C_ANY       7'b???????
`define F3_ANY      3'b???    
`define F7_ANY      7'b???????


//ALU commands
`define ALU_ADD     'b000
`define ALU_OR      'b001
`define ALU_LUI     'b010
`define ALU_SLLI    'b011
`define ALU_SUB     'b100

//sign imm select
`define I_SEL       'b00        // for i type instruction
`define U_SEL       'b01        // for u type instruction
`define B_SEL       'b10        // for b type instruction
`define S_SEL       'b11        // for s type instruction

//branch type constants
`define B_NONE      'b0
`define B_EQ_NEQ    'b1

//srcB select constants
`define SRCB_IMM    'b0
`define SRCB_RD1    'b1

//RF src constants
`define RF_ALUR     'b0         // RF write data is ALU result
`define RF_DMEM     'b1         // RF write data is data memory read data
