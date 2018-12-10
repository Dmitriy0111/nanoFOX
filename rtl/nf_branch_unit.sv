/*
*  File            :   nf_branch_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.12.10
*  Language        :   SystemVerilog
*  Description     :   This is branch unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_cpu.svh"

module nf_branch_unit
(
    input   logic       branch, //from control unit, '1 if branch instruction
    input   logic       zero,   //from ALU unit
    input   logic       eq_neq, //from control unit for beq and bne commands
    output  logic       pc_b_en //next program counter
);

    assign pc_b_en = branch && ( ~ ( zero ^ eq_neq ) );

endmodule : nf_branch_unit
