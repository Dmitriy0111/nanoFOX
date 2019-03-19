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
    // scan wires
    input   logic   [0 : 0]     we_rf_imem,     // write enable register from memory stage
    input   logic   [4 : 0]     wa3_iexe,       // write address from execution stage
    input   logic   [0 : 0]     we_rf_iexe,     // write enable register from memory stage
    input   logic   [0 : 0]     rf_src_iexe,    // register source from execution stage
    input   logic   [4 : 0]     ra1_id,         // read address 1 from decode stage
    input   logic   [4 : 0]     ra2_id,         // read address 2 from decode stage
    input   logic   [3 : 0]     branch_type,    // branch type
    input   logic   [0 : 0]     we_dm_imem,     // write enable data memory from memory stage
    input   logic   [0 : 0]     req_ack_dm,     // request acknowledge data memory
    input   logic   [0 : 0]     req_ack_i,      // request acknowledge instruction
    input   logic   [0 : 0]     rf_src_imem,    // register source from memory stage
    // control wires
    output  logic   [0 : 0]     stall_if,       // stall fetch stage
    output  logic   [0 : 0]     stall_id,       // stall decode stage
    output  logic   [0 : 0]     stall_iexe,     // stall execution stage
    output  logic   [0 : 0]     stall_imem,     // stall memory stage
    output  logic   [0 : 0]     stall_iwb,      // stall write back stage
    output  logic   [0 : 0]     flush_iexe      // flush execution stage
);

    logic   lw_stall_id_iexe;
    logic   lw_stall_imem_iwb;
    logic   branch_exe_id_stall;
    logic   sw_data_stall;
    logic   lw_instr_stall;

    assign  lw_stall_id_iexe    =   ( ( ra1_id == wa3_iexe ) || ( ra2_id == wa3_iexe ) ) && 
                                    we_rf_iexe && 
                                    rf_src_iexe;

    assign  lw_stall_imem_iwb   =   rf_src_imem && 
                                    we_rf_imem && 
                                    ( ~ req_ack_dm );

    assign  branch_exe_id_stall =   ( ! ( ( branch_type[0 +: 3] == B_NONE[0 +: 3] ) || ( branch_type[3] ) ) ) && 
                                    we_rf_iexe && 
                                    ( ( wa3_iexe == ra1_id ) || ( wa3_iexe == ra2_id ) ) && 
                                    ( ( | ra1_id ) || ( | ra2_id ) );

    assign  sw_data_stall       =   we_dm_imem && 
                                    ( ~ req_ack_dm );

    assign  lw_instr_stall      =   ~ req_ack_i;

    assign  stall_if   = lw_stall_id_iexe  || lw_stall_imem_iwb || sw_data_stall || branch_exe_id_stall || lw_instr_stall;
    assign  stall_id   = lw_stall_id_iexe  || lw_stall_imem_iwb || sw_data_stall || branch_exe_id_stall || lw_instr_stall;
    assign  flush_iexe = lw_stall_id_iexe  || lw_stall_imem_iwb ||                  branch_exe_id_stall || lw_instr_stall;
    assign  stall_iexe = lw_stall_imem_iwb ||                      sw_data_stall;
    assign  stall_imem = lw_stall_imem_iwb ||                      sw_data_stall;
    assign  stall_iwb  = lw_stall_imem_iwb ||                      sw_data_stall;
    
endmodule : nf_hz_stall_unit
