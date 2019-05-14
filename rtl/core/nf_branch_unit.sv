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

    // 
    logic   [32 : 0]    sub_res;    // substruction result
    // branch wires
    logic   [0  : 0]    beq_bne;    // for beq and bne instructions
    logic   [0  : 0]    blt_bge;    // for 
    logic   [0  : 0]    bltu_bgeu;  // for 
    // for less and greater operation
    logic   [0  : 0]    zero;       // zero flag
    logic   [0  : 0]    sign;       // sign flag
    logic   [0  : 0]    sof;        // substruction overflow flag
    logic   [0  : 0]    carry;      // carry flag
    logic   [0  : 0]    equal;      // equality flag

    // finding result of substruction
    assign sub_res = d1 - d2;
    // finding flags
    assign equal = ( d1 == d2 );            // equal flag
    assign zero  = ~| sub_res[0 +: 32];     // finding zero flag
    assign carry = sub_res[32];             // finding carry flag
    assign sign  = sub_res[31];             // finding sign flag
    assign sof   = ( ! d1[31] && d2[31] && sub_res[31] ) || ( d1[31] && ! d2[31] && ! sub_res[31] );    // finding substruction overflow flag
    // finding substruction overflow
    assign beq_bne   = branch_type[0] && ( ! ( equal       ^ branch_hf ) );     // finding result for beq or bne operation
    // assign beq_bne   = branch_type[0] && ( ! ( zero        ^ branch_hf ) );     // finding result for beq or bne operation
    assign blt_bge   = branch_type[1] && ( ! ( sign  ^ sof ^ branch_hf ) );     // finding result for blt or bge operation
    assign bltu_bgeu = branch_type[2] && ( ! ( carry       ^ branch_hf ) );     // finding result for bltu or bgeu operation
    // finding pc source
    assign pc_src = | { beq_bne , blt_bge , bltu_bgeu , branch_type[3] };

endmodule : nf_branch_unit
