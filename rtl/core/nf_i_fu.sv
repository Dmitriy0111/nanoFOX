/*
*  File            :   nf_i_fu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is instruction fetch unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"

module nf_i_fu
(
    // clock and reset
    input   logic   [0  : 0]    clk,
    input   logic   [0  : 0]    resetn,
    // instruction ram
    input   logic   [0  : 0]    req_ack_i,
    output  logic   [0  : 0]    req_i,
    // instruction fetch stage
    output  logic   [31 : 0]    pc_if,      // program counter from fetch stage
    // program counter inputs
    input   logic   [31 : 0]    pc_branch,  // program counter branch value from decode stage
    input   logic   [0  : 0]    pc_src,     // next program counter source
    input   logic   [0  : 0]    stall_if,   // for stalling instruction fetch stage
    output  logic   [0  : 0]    flush_id    // for flushing instruction decode stage
    
);

    logic   [31 : 0]    pc_i;
    logic   [31 : 0]    pc_not_branch;

    assign pc_not_branch = pc_if + 4;
    assign pc_i  = pc_src ? pc_branch : pc_not_branch;

    logic   [0  : 0]    flush_id_ifu;
    logic   [0  : 0]    flush_id_branch;
    logic   [0  : 0]    flush_id_delayed;
    logic   [0  : 0]    flush_id_sw_instr;

    assign  flush_id_sw_instr = ~ req_ack_i;
    assign  flush_id_branch = pc_src;
    assign  flush_id = flush_id_ifu || flush_id_delayed || flush_id_branch || flush_id_sw_instr;
    assign  req_i = '1;

    nf_register         #( 1 ) reg_flush_id_delayed ( clk, resetn, flush_id_branch, flush_id_delayed );
    nf_register_we_r    #( 1 ) reg_flush_id_ifu     ( clk, resetn, '1, '1, '0,      flush_id_ifu     );

    // creating program counter
    nf_register_we_r   #( 32 ) register_pc          ( clk, resetn, ( ~ stall_if ) , '0, pc_i, pc_if      );

endmodule : nf_i_fu
