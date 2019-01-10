/*
*  File            :   nf_hazard_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is hazard unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_hazard_unit.svh"

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
    // lw hazard stall and flush
    input   logic   [4 : 0]     wa3_iexe,
    input   logic   [0 : 0]     we_rf_iexe,
    input   logic   [4 : 0]     ra1_id,
    input   logic   [4 : 0]     ra2_id,
    output  logic   [0 : 0]     stall_if,
    output  logic   [0 : 0]     stall_id,
    output  logic   [0 : 0]     flush_iexe
);

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

    assign stall_if   = ~ ( ( ( ra1_id == wa3_iexe ) || ( ra2_id == wa3_iexe ) ) && we_rf_iexe );
    assign stall_id   =   ( ( ( ra1_id == wa3_iexe ) || ( ra2_id == wa3_iexe ) ) && we_rf_iexe );
    assign flush_iexe =   ( ( ( ra1_id == wa3_iexe ) || ( ra2_id == wa3_iexe ) ) && we_rf_iexe );
    
endmodule : nf_hazard_unit
