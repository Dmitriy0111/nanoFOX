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
    input   logic   [4  : 0]    wa3_imem,       // write address from mem stage
    input   logic   [0  : 0]    we_rf_imem,     // write enable register from mem stage
    input   logic   [4  : 0]    wa3_iwb,        // write address from write back stage
    input   logic   [0  : 0]    we_rf_iwb,      // write enable register from write back stage
    input   logic   [4  : 0]    ra1_id,         // read address 1 from decode stage
    input   logic   [4  : 0]    ra2_id,         // read address 2 from decode stage
    input   logic   [4  : 0]    ra1_iexe,       // read address 1 from execution stage
    input   logic   [4  : 0]    ra2_iexe,       // read address 2 from execution stage
    // bypass inputs
    input   logic   [31 : 0]    rd1_iexe,       // read data 1 from execution stage
    input   logic   [31 : 0]    rd2_iexe,       // read data 2 from execution stage
    input   logic   [31 : 0]    result_imem,    // ALU result from mem stage
    input   logic   [31 : 0]    result_iwb,     // ALU result from write back stage
    input   logic   [31 : 0]    rd1_id,         // read data 1 from decode stage
    input   logic   [31 : 0]    rd2_id,         // read data 2 from decode stage
    // bypass outputs
    output  logic   [31 : 0]    rd1_i_exu,      // bypass data 1 for execution stage
    output  logic   [31 : 0]    rd2_i_exu,      // bypass data 2 for execution stage
    output  logic   [31 : 0]    cmp_d1,         // bypass data 1 for decode stage (branch)
    output  logic   [31 : 0]    cmp_d2          // bypass data 2 for decode stage (branch)
);

    logic   [1 : 0]     rd1_bypass;     // bypass selecting for rd1 ( not branch operations )
    logic   [1 : 0]     rd2_bypass;     // bypass selecting for rd2 ( not branch operations )

    logic   [0 : 0]     cmp_d1_bypass;  // bypass selecting for rd1 ( branch operations )
    logic   [0 : 0]     cmp_d2_bypass;  // bypass selecting for rd2 ( branch operations )

    assign  cmp_d1_bypass = ( wa3_imem == ra1_id ) && we_rf_imem && ( | ra1_id );   // zero without bypass ( | ra1_id )
    assign  cmp_d2_bypass = ( wa3_imem == ra2_id ) && we_rf_imem && ( | ra2_id );   // zero without bypass ( | ra2_id )

    assign  cmp_d1 = cmp_d1_bypass ? result_imem : rd1_id;
    assign  cmp_d2 = cmp_d2_bypass ? result_imem : rd2_id;

    always_comb
    begin
        rd1_bypass = `HU_BP_NONE;
        rd2_bypass = `HU_BP_NONE;
        case( 1 )
            ( ( wa3_imem == ra1_iexe ) && we_rf_imem && ( | ra1_iexe ) ) : rd1_bypass = `HU_BP_MEM; // zero without bypass ( | ra1_iexe )
            ( ( wa3_iwb  == ra1_iexe ) && we_rf_iwb  && ( | ra1_iexe ) ) : rd1_bypass = `HU_BP_WB;  // zero without bypass ( | ra1_iexe )
            default : ;
        endcase
        case( 1 )
            ( ( wa3_imem == ra2_iexe ) && we_rf_imem && ( | ra2_iexe ) ) : rd2_bypass = `HU_BP_MEM; // zero without bypass ( | ra2_iexe )
            ( ( wa3_iwb  == ra2_iexe ) && we_rf_iwb  && ( | ra2_iexe ) ) : rd2_bypass = `HU_BP_WB;  // zero without bypass ( | ra2_iexe )
            default : ;
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
