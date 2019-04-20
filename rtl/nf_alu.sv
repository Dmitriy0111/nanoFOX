/*
*  File            :   nf_alu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is ALU unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_cpu.svh"

module nf_alu
(
    input   logic   [31 : 0]    srcA,       // source A for ALU unit
    input   logic   [31 : 0]    srcB,       // source B for ALU unit
    input   logic   [4  : 0]    shamt,      // for shift operation
    input   logic   [2  : 0]    ALU_Code,   // ALU code from control unit
    output  logic   [31 : 0]    result      // result of ALU operation
);

    always_comb
    begin
        result = 0;
        casex( ALU_Code )
            `ALU_LUI    : result = srcB << 12;
            `ALU_ADD    : result = srcA + srcB;
            `ALU_SUB    : result = srcA - srcB;
            `ALU_SLL    : result = srcA << shamt;
            `ALU_OR     : result = srcA | srcB;
            default     : result = 0;
        endcase
    end

endmodule : nf_alu
