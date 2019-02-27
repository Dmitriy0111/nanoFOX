/*
*  File            :   nf_cpu.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit commands
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

//  Base Instruction Formats for ISA
//  fields          31                           25 24                           20 19       15 14        12 11                         7 6          0
//  instr R-type    |           funct7            | |             rs2             | |   rs1   | |  funct3  | |            rd            | |  opcode  |
//                  ----------------------------------------------------------------------------------------------------------------------------------
//  fields          31                                                           20 19       15 14        12 11                         7 6          0
//  instr I-type    |                          imm[11:0]                          | |   rs1   | |  funct3  | |            rd            | |  opcode  |
//                  ----------------------------------------------------------------------------------------------------------------------------------
//  fields          31                           25 24                           20 19       15 14        12 11                         7 6          0
//  instr S-type    |          imm[11:5]          | |             rs2             | |   rs1   | |  funct3  | |         imm[4:0]         | |  opcode  |
//                  ----------------------------------------------------------------------------------------------------------------------------------
//  fields          31                                                                                    12 11                         7 6          0
//  instr U-type    |                                      imm[31:12]                                      | |            rd            | |  opcode  |
//                  ----------------------------------------------------------------------------------------------------------------------------------
//  fields          31           31 30           25 24                           20 19       15 14        12 11           8 7           7 6          0
//  instr B-type    |   imm[12]   | |  imm[10:5]  | |             rs2             | |   rs1   | |  funct3  | |  imm[4:1]  | |  imm[11]  | |  opcode  |
//                  ----------------------------------------------------------------------------------------------------------------------------------
//  fields          31           31 30                             21 20         20 19                    12 11                         7 6          0
//  instr J-type    |   imm[20]   | |           imm[10:1]           | |  imm[11]  | |      imm[19:12]      | |            rd            | |  opcode  |
//                  ----------------------------------------------------------------------------------------------------------------------------------
//  rs1 and rs2 are sources registers, rd are destination register. 
//  imm is immediate data. 
//  opcode is operation code for instruction
//  funct3 and funct7 help's for encode more instructions with same opcode field

`define RVI         2'b11
`define ANY         2'b??

typedef struct packed
{
    logic   [4 : 0] OP;
    logic   [2 : 0] F3;
    logic   [6 : 0] F7;
} instr_cf;                 // instruction opcode, function3, function7 fields

`ifndef COMMANDS
`define COMMANDS
// LUI      -    Load Upper Immediate
//          rd = Immed << 12
parameter instr_cf LUI   = { 5'b01101 , 3'b??? , 7'b??????? };
// AUIPC    -  U-type, Add upper immediate to PC
//          rd = PC + Immed << 12
parameter instr_cf AUIPC = { 5'b00101 , 3'b??? , 7'b??????? };
// JAL      -   J-type, Jump and load PC + 4 in register
//          rd = PC + 4
//          PC = Immed << 12
parameter instr_cf JAL   = { 5'b11011 , 3'b??? , 7'b??????? };
// JAL      -    J-type, Jump and load PC + 4 in register
//          rd = PC + 4
//          PC = Immed << 12
parameter instr_cf JALR  = { 5'b11001 , 3'b??? , 7'b??????? };
// BEQ      -    B-type, Branch if equal
// 
parameter instr_cf BEQ   = { 5'b11000 , 3'b000 , 7'b??????? };
// BNE      -    B-type, Branch if not equal
// 
parameter instr_cf BNE   = { 5'b11000 , 3'b001 , 7'b??????? };
// BLT      -    B-type, Branch if less
// 
parameter instr_cf BLT   = { 5'b11000 , 3'b100 , 7'b??????? };
// BGE      -    B-type, Branch if greater
// 
parameter instr_cf BGE   = { 5'b11000 , 3'b101 , 7'b??????? };
// BLTU     -   B-type, Branch if less unsigned
// 
parameter instr_cf BLTU  = { 5'b11000 , 3'b110 , 7'b??????? };
// BGEU     -   B-type, Branch if greater unsigned
//
parameter instr_cf BGEU  = { 5'b11000 , 3'b111 , 7'b??????? };
// LB       -     I-type, Load byte
//          rd = mem[addr]
parameter instr_cf LB    = { 5'b00000 , 3'b000 , 7'b??????? };
// LH       -     I-type, Load half word
//          rd = mem[addr]
parameter instr_cf LH    = { 5'b00000 , 3'b001 , 7'b??????? };
// LW       -     I-type, Load word
//          rd = mem[addr]
parameter instr_cf LW    = { 5'b00000 , 3'b010 , 7'b??????? };
// LBU      -    I-type, Load byte unsigned
//          rd = mem[addr]
parameter instr_cf LBU   = { 5'b00000 , 3'b100 , 7'b??????? };
// LHU      -    I-type, Load half word unsigned
//          rd = mem[addr]
parameter instr_cf LHU   = { 5'b00000 , 3'b101 , 7'b??????? };
// SB       -     S-type, Store byte
//          mem[addr] = rs1
parameter instr_cf SB    = { 5'b01000 , 3'b000 , 7'b??????? };
// SH       -     S-type, Store half word
//          mem[addr] = rs1
parameter instr_cf SH    = { 5'b01000 , 3'b001 , 7'b??????? };
// SW       -     S-type, Store word
//          mem[addr] = rs1
parameter instr_cf SW    = { 5'b01000 , 3'b010 , 7'b??????? };
// ADDI     -   I-type, Adding with immidiate
//          rd = rs1 + Immed
parameter instr_cf ADDI  = { 5'b00100 , 3'b000 , 7'b??????? };
// SLTI     -   I-type, Set less immidiate
//          rd = rs1 < signed   ( Immed ) ? '0 : '1
parameter instr_cf SLTI  = { 5'b00100 , 3'b010 , 7'b??????? };
// SLTIU    -  I-type, Set less unsigned immidiate
//          rd = rs1 < unsigned ( Immed ) ? '0 : '1
parameter instr_cf SLTIU = { 5'b00100 , 3'b011 , 7'b??????? };
// XORI     -   I-type, Excluding Or operation with immidiate
//          rd = rs1 ^ Immed
parameter instr_cf XORI  = { 5'b00100 , 3'b100 , 7'b??????? };
// ORI      -    I-type, Or operation with immidiate
//          rd = rs1 | Immed
parameter instr_cf ORI   = { 5'b00100 , 3'b110 , 7'b??????? };
// ANDI     -   I-type, And operation with immidiate
//          rd = rs1 & Immed
parameter instr_cf ANDI  = { 5'b00100 , 3'b111 , 7'b??????? };
// SLLI     -   I-type, Shift Left Logical
//          rd = rs1 << shamt
parameter instr_cf SLLI  = { 5'b00100 , 3'b001 , 7'b0000000 };
// SRLI     -   I-type, Shift Right Logical
//          rd = rs1 >> shamt
parameter instr_cf SRLI  = { 5'b00100 , 3'b101 , 7'b0000000 };
// SRAI     -   I-type, Shift Right Arifmetical
//          rd = rs1 >> shamt
parameter instr_cf SRAI  = { 5'b00100 , 3'b101 , 7'b0100000 };
// ADD      -    R-type, Adding with register
//          rd = rs1 + rs2
parameter instr_cf ADD   = { 5'b01100 , 3'b000 , 7'b0000000 };
// SUB      -    R-type, Adding with register
//          rd = rs1 - rs2
parameter instr_cf SUB   = { 5'b01100 , 3'b000 , 7'b0100000 };
// SLL      -    R-type, Set left logical
//          rd = rs1 << rs2
parameter instr_cf SLL   = { 5'b01100 , 3'b001 , 7'b0000000 };
// SLT      -    R-type, Set less
//          rd = rs1 < rs2 ? '0 : '1
parameter instr_cf SLT   = { 5'b01100 , 3'b010 , 7'b0000000 };
// SLTU     -   R-type, Set less unsigned
//          rd = rs1 < rs2 ? '0 : '1
parameter instr_cf SLTU  = { 5'b01100 , 3'b011 , 7'b0000000 };
// XOR      -    R-type, Excluding Or two register
//          rd = rs1 ^ rs2
parameter instr_cf XOR   = { 5'b01100 , 3'b100 , 7'b0000000 };
// SRL      -    R-type, Set right logical
//          rd = rs1 >> rs2
parameter instr_cf SRL   = { 5'b01100 , 3'b101 , 7'b0000000 };
// SRA      -    R-type, Set right arifmetical
//          rd = rs1 >> rs2
parameter instr_cf SRA   = { 5'b01100 , 3'b101 , 7'b0100000 };
// OR       -     R-type, Or two register
//          rd = rs1 | rs2
parameter instr_cf OR    = { 5'b01100 , 3'b110 , 7'b0000000 };
// AND      -    R-type, And two register
//          rd = rs1 & rs2
parameter instr_cf AND   = { 5'b01100 , 3'b111 , 7'b0000000 };
// VER      -    For verification
parameter instr_cf VER   = { 5'b????? , 3'b??? , 7'b??????? };
`endif

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
