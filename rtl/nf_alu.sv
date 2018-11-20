/*
*  File            :   nf_alu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is ALU unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_cpu.svh"

module nf_alu
(
    input   logic   [31 : 0]    srcA,
    input   logic   [31 : 0]    srcB,
    input   logic   [4  : 0]    shamt,
    input   logic   [31 : 0]    ALU_Code,
    output  logic   [31 : 0]    result,
    output  logic   [31 : 0]    alu_flags
);

    always_comb
    begin
        alu_flags = '0;
        result = 0;
        casex(ALU_Code)
            `ALU_LUI    : begin result = srcB << 20 ;       end
            `ALU_ADD    : begin result = srcA << shamt ;    end
            `ALU_SLLI   : begin result = srcA + srcB ;      end
            `ALU_OR     : begin result = srcA | srcB ;      end
        endcase
        alu_flags[0] = result == '0;
    end

endmodule : nf_alu
