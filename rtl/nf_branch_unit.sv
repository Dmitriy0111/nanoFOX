/*
*  File            :   nf_branch_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.12.10
*  Language        :   SystemVerilog
*  Description     :   This is branch unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_cpu.svh"

module nf_branch_unit
(
    input   logic   [0  : 0]    branch_type,    // branch type
    input   logic   [0  : 0]    branch_hf,      // branch help field
    input   logic   [31 : 0]    d1,             // from register file (rd1)
    input   logic   [31 : 0]    d2,             // from register file (rd2)
    output  logic   [0  : 0]    pc_src          // next program counter
);

    logic   equal;

    assign  equal  = ( d2 == d1 );
    assign  pc_src = branch_type && ( ! ( equal ^ branch_hf ) );

endmodule : nf_branch_unit
