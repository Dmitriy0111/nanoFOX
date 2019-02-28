/*
*  File            :   nf_hz_bypass_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is bypass hazard unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_hazard_unit.svh"
`include "../../inc/nf_cpu.svh"

module nf_hz_bypass_unit
(
    // scan wires
    input   logic   [4  : 0]    wa3_imem,
    input   logic   [0  : 0]    we_rf_imem,
    input   logic   [4  : 0]    wa3_iwb,
    input   logic   [0  : 0]    we_rf_iwb,
    input   logic   [4  : 0]    ra1_id,
    input   logic   [4  : 0]    ra2_id,
    input   logic   [4  : 0]    ra1_iexe,
    input   logic   [4  : 0]    ra2_iexe,
    // bypass inputs
    input   logic   [31 : 0]    rd1_iexe,
    input   logic   [31 : 0]    rd2_iexe,
    input   logic   [31 : 0]    result_imem,
    input   logic   [31 : 0]    result_iwb,
    input   logic   [31 : 0]    rd1_id,
    input   logic   [31 : 0]    rd2_id,
    // bypass outputs
    output  logic   [31 : 0]    rd1_i_exu,
    output  logic   [31 : 0]    rd2_i_exu,
    output  logic   [31 : 0]    cmp_d1,
    output  logic   [31 : 0]    cmp_d2
);

    logic   [1  : 0]    rd1_bypass;
    logic   [1  : 0]    rd2_bypass;

    logic   [0  : 0]    cmp_d1_bypass;
    logic   [0  : 0]    cmp_d2_bypass;

    assign  cmp_d1_bypass = ( wa3_imem == ra1_id ) && we_rf_imem;
    assign  cmp_d2_bypass = ( wa3_imem == ra2_id ) && we_rf_imem;

    assign  cmp_d1 = cmp_d1_bypass ? result_imem : rd1_id;
    assign  cmp_d2 = cmp_d2_bypass ? result_imem : rd2_id;

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

    always_comb
    begin
        rd1_i_exu = rd1_iexe;
        rd2_i_exu = rd2_iexe;
        case( rd1_bypass )
            `HU_BP_NONE : rd1_i_exu = rd1_iexe;
            `HU_BP_MEM  : rd1_i_exu = result_imem;
            `HU_BP_WB   : rd1_i_exu = result_iwb;
            default     : ;
        endcase
        case( rd2_bypass )
            `HU_BP_NONE : rd2_i_exu = rd2_iexe;
            `HU_BP_MEM  : rd2_i_exu = result_imem;
            `HU_BP_WB   : rd2_i_exu = result_iwb;
            default     : ;
        endcase
    end
    
endmodule : nf_hz_bypass_unit
