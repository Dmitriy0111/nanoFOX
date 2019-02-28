/*
*  File            :   nf_hz_stall_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is stall and flush hazard unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_hazard_unit.svh"
`include "../../inc/nf_cpu.svh"

module nf_hz_stall_unit
(
    // lw hazard stall and flush
    input   logic   [0 : 0]     we_rf_imem,
    input   logic   [4 : 0]     wa3_iexe,
    input   logic   [0 : 0]     we_rf_iexe,
    input   logic   [0 : 0]     rf_src_iexe,
    input   logic   [4 : 0]     ra1_id,
    input   logic   [4 : 0]     ra2_id,
    output  logic   [0 : 0]     stall_if,
    output  logic   [0 : 0]     stall_id,
    output  logic   [0 : 0]     stall_iexe,
    output  logic   [0 : 0]     stall_imem,
    output  logic   [0 : 0]     stall_iwb,
    output  logic   [0 : 0]     flush_iexe,
    input   logic   [2 : 0]     branch_type,
    input   logic   [0 : 0]     we_dm_imem,
    input   logic   [0 : 0]     req_ack_dm,
    input   logic   [0 : 0]     req_ack_i,
    input   logic   [0 : 0]     rf_src_imem
);

    logic   lw_stall;
    logic   sw_data_stall;
    logic   lw_instr_stall;
    logic   branch_exe_id_stall;

    assign lw_stall = ( ( ( ra1_id == wa3_iexe ) || ( ra2_id == wa3_iexe ) ) && we_rf_iexe && rf_src_iexe ) || ( rf_src_imem && we_rf_imem && ( ~ req_ack_dm ) );
    assign branch_exe_id_stall = ( branch_type != B_NONE ) && we_rf_iexe && ( ( wa3_iexe == ra1_id ) || ( wa3_iexe == ra2_id ) );
    assign sw_data_stall = we_dm_imem && ( ~ req_ack_dm );
    assign lw_instr_stall = ~ req_ack_i;

    assign stall_if   = lw_stall || sw_data_stall || branch_exe_id_stall || lw_instr_stall;
    assign stall_id   = lw_stall || sw_data_stall || branch_exe_id_stall || lw_instr_stall;
    assign flush_iexe = lw_stall ||                  branch_exe_id_stall || lw_instr_stall;
    assign stall_iexe = lw_stall || sw_data_stall;
    assign stall_imem = lw_stall || sw_data_stall;
    assign stall_iwb  = lw_stall || sw_data_stall;
    
endmodule : nf_hz_stall_unit
