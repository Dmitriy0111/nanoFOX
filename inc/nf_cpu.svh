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
`define RVC_0       2'b11
`define RVC_1       2'b11
`define RVC_2       2'b11
`define ANY         2'b??

typedef struct packed
{
    logic   [39 : 0]    I_NAME; // instruction name
    logic   [1  : 0]    IT;     // instruction type
    logic   [4  : 0]    OP;     // instruction opcode
    logic   [2  : 0]    F3;     // instruction function field 3
    logic   [6  : 0]    F7;     // instruction function field 7
} instr_cf;                     // instruction typedef

`ifndef COMMANDS
`define COMMANDS
// LUI      -    Load Upper Immediate
//          rd = Immed << 12
parameter instr_cf LUI   = { "  LUI",`RVI , 5'b01101 , 3'b??? , 7'b??????? };
// AUIPC    -  U-type, Add upper immediate to PC
//          rd = PC + Immed << 12
parameter instr_cf AUIPC = { "AUIPC",`RVI , 5'b00101 , 3'b??? , 7'b??????? };
// JAL      -   J-type, Jump and load PC + 4 in register
//          rd = PC + 4
//          PC = Immed << 12
parameter instr_cf JAL   = { "  JAL",`RVI , 5'b11011 , 3'b??? , 7'b??????? };
// JAL      -    J-type, Jump and load PC + 4 in register
//          rd = PC + 4
//          PC = Immed << 12
parameter instr_cf JALR  = { " JALR",`RVI , 5'b11001 , 3'b??? , 7'b??????? };
// BEQ      -    B-type, Branch if equal
// 
parameter instr_cf BEQ   = { "  BEQ",`RVI , 5'b11000 , 3'b000 , 7'b??????? };
// BNE      -    B-type, Branch if not equal
// 
parameter instr_cf BNE   = { "  BNE",`RVI , 5'b11000 , 3'b001 , 7'b??????? };
// BLT      -    B-type, Branch if less
// 
parameter instr_cf BLT   = { "  BLT",`RVI , 5'b11000 , 3'b100 , 7'b??????? };
// BGE      -    B-type, Branch if greater
// 
parameter instr_cf BGE   = { "  BGE",`RVI , 5'b11000 , 3'b101 , 7'b??????? };
// BLTU     -   B-type, Branch if less unsigned
// 
parameter instr_cf BLTU  = { " BLTU",`RVI , 5'b11000 , 3'b110 , 7'b??????? };
// BGEU     -   B-type, Branch if greater unsigned
//
parameter instr_cf BGEU  = { " BGEU",`RVI , 5'b11000 , 3'b111 , 7'b??????? };
// LB       -     I-type, Load byte
//          rd = mem[addr]
parameter instr_cf LB    = { "   LB",`RVI , 5'b00000 , 3'b000 , 7'b??????? };
// LH       -     I-type, Load half word
//          rd = mem[addr]
parameter instr_cf LH    = { "   LH",`RVI , 5'b00000 , 3'b001 , 7'b??????? };
// LW       -     I-type, Load word
//          rd = mem[addr]
parameter instr_cf LW    = { "   LW",`RVI , 5'b00000 , 3'b010 , 7'b??????? };
// LBU      -    I-type, Load byte unsigned
//          rd = mem[addr]
parameter instr_cf LBU   = { "  LBU",`RVI , 5'b00000 , 3'b100 , 7'b??????? };
// LHU      -    I-type, Load half word unsigned
//          rd = mem[addr]
parameter instr_cf LHU   = { "  LHU",`RVI , 5'b00000 , 3'b101 , 7'b??????? };
// SB       -     S-type, Store byte
//          mem[addr] = rs1
parameter instr_cf SB    = { "   SB",`RVI , 5'b01000 , 3'b000 , 7'b??????? };
// SH       -     S-type, Store half word
//          mem[addr] = rs1
parameter instr_cf SH    = { "   SH",`RVI , 5'b01000 , 3'b001 , 7'b??????? };
// SW       -     S-type, Store word
//          mem[addr] = rs1
parameter instr_cf SW    = { "   SW",`RVI , 5'b01000 , 3'b010 , 7'b??????? };
// ADDI     -   I-type, Adding with immidiate
//          rd = rs1 + Immed
parameter instr_cf ADDI  = { " ADDI",`RVI , 5'b00100 , 3'b000 , 7'b??????? };
// SLTI     -   I-type, Set less immidiate
//          rd = rs1 < signed   ( Immed ) ? '0 : '1
parameter instr_cf SLTI  = { " SLTI",`RVI , 5'b00100 , 3'b010 , 7'b??????? };
// SLTIU    -  I-type, Set less unsigned immidiate
//          rd = rs1 < unsigned ( Immed ) ? '0 : '1
parameter instr_cf SLTIU = { "SLTIU",`RVI , 5'b00100 , 3'b011 , 7'b??????? };
// XORI     -   I-type, Excluding Or operation with immidiate
//          rd = rs1 ^ Immed
parameter instr_cf XORI  = { " XORI",`RVI , 5'b00100 , 3'b100 , 7'b??????? };
// ORI      -    I-type, Or operation with immidiate
//          rd = rs1 | Immed
parameter instr_cf ORI   = { "  ORI",`RVI , 5'b00100 , 3'b110 , 7'b??????? };
// ANDI     -   I-type, And operation with immidiate
//          rd = rs1 & Immed
parameter instr_cf ANDI  = { " ANDI",`RVI , 5'b00100 , 3'b111 , 7'b??????? };
// SLLI     -   I-type, Shift Left Logical
//          rd = rs1 << shamt
parameter instr_cf SLLI  = { " SLLI",`RVI , 5'b00100 , 3'b001 , 7'b0000000 };
// SRLI     -   I-type, Shift Right Logical
//          rd = rs1 >> shamt
parameter instr_cf SRLI  = { " SRLI",`RVI , 5'b00100 , 3'b101 , 7'b0000000 };
// SRAI     -   I-type, Shift Right Arifmetical
//          rd = rs1 >> shamt
parameter instr_cf SRAI  = { " SRAI",`RVI , 5'b00100 , 3'b101 , 7'b0100000 };
// ADD      -    R-type, Adding with register
//          rd = rs1 + rs2
parameter instr_cf ADD   = { "  ADD",`RVI , 5'b01100 , 3'b000 , 7'b0000000 };
// SUB      -    R-type, Adding with register
//          rd = rs1 - rs2
parameter instr_cf SUB   = { "  SUB",`RVI , 5'b01100 , 3'b000 , 7'b0100000 };
// SLL      -    R-type, Set left logical
//          rd = rs1 << rs2
parameter instr_cf SLL   = { "  SLL",`RVI , 5'b01100 , 3'b001 , 7'b0000000 };
// SLT      -    R-type, Set less
//          rd = rs1 < rs2 ? '0 : '1
parameter instr_cf SLT   = { "  SLT",`RVI , 5'b01100 , 3'b010 , 7'b0000000 };
// SLTU     -   R-type, Set less unsigned
//          rd = rs1 < rs2 ? '0 : '1
parameter instr_cf SLTU  = { " SLTU",`RVI , 5'b01100 , 3'b011 , 7'b0000000 };
// XOR      -    R-type, Excluding Or two register
//          rd = rs1 ^ rs2
parameter instr_cf XOR   = { "  XOR",`RVI , 5'b01100 , 3'b100 , 7'b0000000 };
// SRL      -    R-type, Set right logical
//          rd = rs1 >> rs2
parameter instr_cf SRL   = { "  SRL",`RVI , 5'b01100 , 3'b101 , 7'b0000000 };
// SRA      -    R-type, Set right arifmetical
//          rd = rs1 >> rs2
parameter instr_cf SRA   = { "  SRA",`RVI , 5'b01100 , 3'b101 , 7'b0100000 };
// OR       -     R-type, Or two register
//          rd = rs1 | rs2
parameter instr_cf OR    = { "   OR",`RVI , 5'b01100 , 3'b110 , 7'b0000000 };
// AND      -    R-type, And two register
//          rd = rs1 & rs2
parameter instr_cf AND   = { "  AND",`RVI , 5'b01100 , 3'b111 , 7'b0000000 };
// VER      -    For verification
parameter instr_cf VER   = { "  VER",`RVI , 5'b????? , 3'b??? , 7'b??????? };
`endif

`ifndef ALU_TYPES
`define ALU_TYPES
//ALU commands
typedef enum logic [4 : 0]
{
    ALU_ADD,
    ALU_OR, 
    ALU_LUI,
    ALU_SLL,
    ALU_SRL,
    ALU_SUB,
    ALU_AND,
    ALU_XOR
} alu_types;
`endif

`ifndef IMM_SEL_TYPES
`define IMM_SEL_TYPES
//branch type constants
typedef enum logic [4 : 0]  // one hot
{
    //sign imm select
    I_NONE      =   5'h00,
    I_SEL       =   5'h01,       // for i type instruction
    U_SEL       =   5'h02,       // for u type instruction
    B_SEL       =   5'h04,       // for b type instruction
    S_SEL       =   5'h08,       // for s type instruction
    J_SEL       =   5'h10        // for j type instruction
} imm_sel_types;
`endif

`ifndef BRANCH_TYPES
`define BRANCH_TYPES
//branch type constants
typedef enum logic [3 : 0]  // one hot
{
    B_NONE      =   4'h0,
    B_EQ_NEQ    =   4'h1,
    B_GE_LT     =   4'h2,
    B_GEU_LTU   =   4'h4,
    B_UB        =   4'h8
} b_types;
`endif

`ifndef SRCB_TYPES
`define SRCB_TYPES
//srcB select constants
typedef enum logic [0 : 0]
{
    SRCB_IMM    =   1'b0,
    SRCB_RD2    =   1'b1
} srcb_types;
`endif

`ifndef RES_TYPES
`define RES_TYPES
//result select constants
typedef enum logic [0 : 0]
{
    RES_ALU     =   1'b0,
    RES_UB      =   1'b1
} res_types;
`endif

`ifndef RF_SRC_TYPES
`define RF_SRC_TYPES
//srcB select constants
typedef enum logic [0 : 0]
{
    RF_ALUR     =   1'b0,   // RF write data is ALU result
    RF_DMEM     =   1'b1    // RF write data is data memory read data
} rf_src_types;
`endif
