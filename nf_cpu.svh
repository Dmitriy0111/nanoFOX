/*
*  File            :   nf_cpu.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit commands
*  Copyright(c)    :   2018 Vlasov D.V.
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
//  rs1 and rs2 are sources register's, rd are destination register. 
//  imm is immediate data. 
//  opcode is operation code for instruction
//  funct3 and funct7 help's for encode more instraction's with same opcode field

`define C_LUI       7'b0110111  // U-type, Load Upper Immediate
                                //         Rt = Immed << 12
`define C_SLLI      7'b0010011  // I-type, Shift Right Logical
                                //         rd = rs1 << shamt
`define C_ADDI      7'b0010011  // I-type, Adding with immidiate
                                //         rd = rs1 + Immed
`define C_ADD       7'b0110011  // R-type, Adding with register
                                //         rd = rs1 + rs2
`define C_SUB       7'b0110011  // R-type, Adding with register
                                //         rd = rs1 - rs2
`define C_OR        7'b0110011  // R-type, Or with two register
                                //         rd = rs1 | rs2
`define C_BEQ       7'b1100011  // B-type, Branch if equal
                                //     
`define C_LW        7'b0000011  // I-type, Load word
                                // 
`define C_SW        7'b0100011  // S-type, Store word
                                //     
`define C_ANY       7'b???????  // for verification

//instruction function3 field
`define F3_SLLI     3'b001      // I-type, Shift Right Logical
                                //         rd = rs1 << shamt
`define F3_ADDI     3'b000      // I-type, Adding with immidiate
                                //         rd = rs1 + Immed
`define F3_ADD      3'b000      // R-type, Adding with register
                                //         rd = rs1 + rs2
`define F3_SUB      3'b000      // R-type, Subtracting with register
                                //         rd = rs1 - rs2
`define F3_OR       3'b110      // R-type, Or with two register
                                //         rd = rs1 | rs2
`define F3_BEQ      3'b000      // B-type, Branch if equal
                                //
`define F3_LW       3'b010      // I-type, Load word
                                // 
`define F3_SW       3'b010      // S-type, Store word
                                //  
`define F3_ANY      3'b???      // if instruction haven't function field

//instruction function7 field
`define F7_ADD      7'b0000000  // R-type, Adding with register
                                //         rd = rs1 + rs2
`define F7_SUB      7'b0100000  // R-type, Subtracting with register
                                //         rd = rs1 - rs2        
`define F7_ANY      7'b???????  // if instruction haven't function field



//ALU commands
`define ALU_ADD     'b000
`define ALU_OR      'b001
`define ALU_LUI     'b010
`define ALU_SLLI    'b011
`define ALU_COMP    'b100
`define ALU_SUB     'b101

//sign imm select
`define i_sel       'b00        // for i type instruction
`define u_sel       'b01        // for u type instruction
`define b_sel       'b10        // for b type instruction
`define s_sel       'b11        // for s type instruction
