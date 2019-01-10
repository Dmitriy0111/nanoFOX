/*
*  File            :   nf_branch_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.12.10
*  Language        :   SystemVerilog
*  Description     :   This is branch unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_cpu.svh"

module nf_branch_unit
(
    input   logic               branch, // from control unit, '1 if branch instruction
    input   logic               eq_neq, // from control unit for beq and bne commands (equal and not equal)
    input   logic   [31 : 0]    d0,     // from register file (rd1)
    input   logic   [31 : 0]    d1,     // from register file (rd2)
    output  logic               pc_b_en // next program counter
);

    logic   equal;

    assign  equal   = ( d0 == d1 );
    assign  pc_b_en = branch && ( ! ( equal ^ eq_neq ) );

endmodule : nf_branch_unit
