/*
*  File            :   nf_hazard_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is hazard unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_hazard_unit.svh"
`include "../inc/nf_cpu.svh"

module nf_hazard_unit
(
    // forwarding/bypassing
    input   logic   [4 : 0]     wa3_imem,
    input   logic   [0 : 0]     we_rf_imem,
    input   logic   [4 : 0]     wa3_iwb,
    input   logic   [0 : 0]     we_rf_iwb,
    input   logic   [4 : 0]     ra1_iexe,
    input   logic   [4 : 0]     ra2_iexe,
    output  logic   [1 : 0]     rd1_bypass,
    output  logic   [1 : 0]     rd2_bypass,
    output  logic   [0 : 0]     cmp_d1_bypass,
    output  logic   [0 : 0]     cmp_d2_bypass,
    // lw hazard stall and flush
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
    input   logic   [0 : 0]     branch_type,
    input   logic   [0 : 0]     we_dm_imem,
    input   logic   [0 : 0]     req_ack_dm,
    input   logic   [0 : 0]     rf_src_imem
);

    logic   lw_stall;
    logic   sw_stall;
    logic   branch_exe_id_stall;

    assign  cmp_d1_bypass = ( wa3_imem == ra1_id ) && we_rf_imem;
    assign  cmp_d2_bypass = ( wa3_imem == ra2_id ) && we_rf_imem;

    always_comb
    begin
        rd1_bypass = `HU_BP_NONE;
        rd2_bypass = `HU_BP_NONE;
        case( 1 )
            ( ( wa3_imem == ra1_iexe ) && we_rf_imem ) : rd1_bypass = `HU_BP_MEM;
            ( ( wa3_iwb  == ra1_iexe ) && we_rf_iwb  ) : rd1_bypass = `HU_BP_WB;
            default                                    : ;
        endcase
        case( 1 )
            ( ( wa3_imem == ra2_iexe ) && we_rf_imem ) : rd2_bypass = `HU_BP_MEM;
            ( ( wa3_iwb  == ra2_iexe ) && we_rf_iwb  ) : rd2_bypass = `HU_BP_WB;
            default                                    : ;
        endcase
    end

    assign lw_stall = ( ( ( ra1_id == wa3_iexe ) || ( ra2_id == wa3_iexe ) ) && we_rf_iexe && rf_src_iexe ) || ( rf_src_imem && we_rf_imem && ( ~ req_ack_dm ) );
    assign branch_exe_id_stall = ( branch_type != `B_NONE ) && we_rf_iexe && ( ( wa3_iexe == ra1_id ) || ( wa3_iexe == ra2_id ) );
    assign sw_stall = we_dm_imem && ( ~ req_ack_dm );

    assign stall_if   = lw_stall || sw_stall || branch_exe_id_stall;
    assign stall_id   = lw_stall || sw_stall || branch_exe_id_stall;
    assign flush_iexe = lw_stall || branch_exe_id_stall;
    assign stall_iexe = lw_stall || sw_stall;
    assign stall_imem = lw_stall || sw_stall;
    assign stall_iwb  = lw_stall || sw_stall;
    
endmodule : nf_hazard_unit
