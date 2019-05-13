/*
*  File            :   nf_alu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is ALU unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_cpu.svh"

module nf_alu
(
    input   logic   [31 : 0]    srcA,       // source A for ALU unit
    input   logic   [31 : 0]    srcB,       // source B for ALU unit
    input   logic   [31 : 0]    shift,      // for shift operation
    input   logic   [3  : 0]    ALU_Code,   // ALU code from control unit
    output  logic   [31 : 0]    result      // result of ALU operation
);

    logic   [0  : 0]    less;
    logic   [32 : 0]    add_sub;

    assign add_sub = srcA - srcB;
    assign less = add_sub[32];

    always_comb
    begin
        result = 0;
        case( ALU_Code )
            ALU_ADD     : result = srcA + srcB;
            ALU_SLL     : result = srcA << shift;
            ALU_SRL     : result = srcA >> shift;
            ALU_OR      : result = srcA | srcB;
            ALU_XOR     : result = srcA ^ srcB;
            ALU_AND     : result = srcA & srcB;
            ALU_SLT     : result = ($signed(srcA) < $signed(srcB));
            ALU_SLTU    : result = less;
            default     : result = 0;
        endcase
    end

endmodule : nf_alu
