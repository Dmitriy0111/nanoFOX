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
    input   logic   [3  : 0]    branch_type,    // from control unit, '1 if branch instruction
    input   logic   [0  : 0]    branch_hf,      // from control unit for beq and bne commands (equal and not equal)
    input   logic   [31 : 0]    d1,             // from register file (rd1)
    input   logic   [31 : 0]    d2,             // from register file (rd2)
    output  logic   [0  : 0]    pc_src          // next program counter
);
    // for equal and not equal operation
    logic   [0 : 0]     equal;  // For beq and bne instructions
    // finding equality
    assign equal  = ( d2 == d1 );
    // finding pc source
    assign pc_src = ( branch_type[0] && ( ! ( equal ^ branch_hf ) ) ) || branch_type[3];

endmodule : nf_branch_unit
