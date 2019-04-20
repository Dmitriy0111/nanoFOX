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

`define C_LUI       7'b0110111  // U-type, Load upper immediate
                                //         Rt = Immed << 12
`define C_SLLI      7'b0010011  // I-type, Shift right logical
                                //         rd = rs1 << shamt
`define C_ADDI      7'b0010011  // I-type, Adding with immediate
                                //         rd = rs1 + Immed
`define C_ADD       7'b0110011  // R-type, Adding with register
                                //         rd = rs1 + rs2
`define C_SUB       7'b0110011  // R-type, Adding with register
                                //         rd = rs1 - rs2
`define C_OR        7'b0110011  // R-type, Or with two register
                                //         rd = rs1 | rs2
`define C_BEQ       7'b1100011  // B-type, Branch if equal
                                //         
`define C_ANY       7'b???????  // for verification

//instruction function3 field
`define F3_SLLI     3'b001      // I-type, Shift right logical
                                //         rd = rs1 << shamt
`define F3_ADDI     3'b000      // I-type, Adding with immediate
                                //         rd = rs1 + Immed
`define F3_ADD      3'b000      // R-type, Adding with register
                                //         rd = rs1 + rs2
`define F3_SUB      3'b000      // R-type, Subtracting with register
                                //         rd = rs1 - rs2
`define F3_OR       3'b110      // R-type, Or with two register
                                //         rd = rs1 | rs2
`define F3_BEQ      3'b000      // B-type, Branch if equal
                                //         
`define F3_ANY      3'b???      // if instruction haven't function field and for verification

//instruction function7 field
`define F7_ADD      7'b0000000  // R-type, Adding with register
                                //         rd = rs1 + rs2
`define F7_SUB      7'b0100000  // R-type, Subtracting with register
                                //         rd = rs1 - rs2        
`define F7_ANY      7'b???????  // if instruction haven't function field and for verification



//ALU commands
`define ALU_ADD     3'b000
`define ALU_OR      3'b001
`define ALU_LUI     3'b010
`define ALU_SLL     3'b011
`define ALU_SUB     3'b100

//sign imm select
`define I_SEL       2'b00   // for i type instruction
`define U_SEL       2'b01   // for u type instruction
`define B_SEL       2'b10   // for b type instruction

//branch type constants
`define B_NONE      1'b0
`define B_EQ_NEQ    1'b1

//srcB select constants
`define SRCB_IMM    1'b0
`define SRCB_RD1    1'b1
