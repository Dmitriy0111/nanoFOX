/*
*  File            :   nf_branch_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.12.10
*  Language        :   SystemVerilog
*  Description     :   This is branch unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_cpu.svh"

module nf_branch_unit
(
    input   logic   [2  : 0]    branch_type,    // from control unit, '1 if branch instruction
    input   logic   [0  : 0]    branch_hf,      // from control unit for beq and bne commands (equal and not equal)
    input   logic   [31 : 0]    d0,             // from register file (rd1)
    input   logic   [31 : 0]    d1,             // from register file (rd2)
    output  logic   [0  : 0]    pc_src          // next program counter
);

    logic   equal;

    assign  equal  = ( d0 == d1 );
    assign  pc_src = branch_type[0] && ( ! ( equal ^ branch_hf ) );

endmodule : nf_branch_unit
