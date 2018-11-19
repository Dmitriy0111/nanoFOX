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
//  instr I-type    |            imm[11:0]       | |   rs1   | |  funct3 | |      rd    | | opcode  |
//  instr S-type    |   imm[11:5]    | |   rs2   | |   rs1   | |  funct3 | |   imm[4:0] | | opcode  |
//  instr U-type    |                        imm[31:12]                  | |      rd    | | opcode  |
//  rs1 and rs2 are sources register's, rd are destination register

`define C_LUI       7'b0110111  // U-type, Load Upper Immediate
                                //         Rt = Immed << 12
`define C_SLLI      7'b0010011  // I-type, Shift Right Logical
                                //         rd = rs1 << shamt
`define C_ADDI      7'b0010011  // I-type, Adding with immidiate
                                //         rd = rs1 + Immed
`define C_ADD       7'b0110011  // R-type, Adding with register
                                //         rd = rs1 + rs2
`define C_OR        7'b0110011  // R-type, Or with two register
                                //         rd = rs1 | rs2
`define C_BEQ       7'b1100011  // B-type, Branch if equal
                                //         

//instruction function field
`define F_SLLI      3'b001      // I-type, Shift Right Logical
                                //         rd = rs1 << shamt
`define F_ADDI      3'b000      // I-type, Adding with immidiate
                                //         rd = rs1 + Immed
`define F_ADD       3'b000      // R-type, Adding with register
                                //         rd = rs1 + rs2
`define F_OR        3'b110      // R-type, Or with two register
                                //         rd = rs1 | rs2
`define F_BEQ       3'b000      // B-type, Branch if equal
                                //         
`define F_ANY       3'b???      // if instruction haven't function field

//ALU commands
`define ALU_ADD     'b000
`define ALU_OR      'b001
`define ALU_LUI     'b010
`define ALU_SLLI    'b011
