/*
*  File            :   nf_control_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is controll unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_cpu.svh"

module nf_control_unit
(
    input   logic   [6  : 0]    opcode,         // operation code field in instruction code
    input   logic   [2  : 0]    funct3,         // funct 3 field in instruction code
    input   logic   [6  : 0]    funct7,         // funct 7 field in instruction code
    output  logic   [1  : 0]    imm_src,        // for enable immediate data
    output  logic   [0  : 0]    srcBsel,        // for selecting srcB ALU
    output  logic   [0  : 0]    branch_type,    // for executing branch instructions
    output  logic   [0  : 0]    eq_neq,         // equal and not equal control
    output  logic   [0  : 0]    we_rf,          // write enable signal for register file
    output  logic   [0  : 0]    we_dm,          // write enable signal for data memory and others
    output  logic   [0  : 0]    rf_src,         // write data select for register file
    output  logic   [31 : 0]    ALU_Code        // output code for ALU unit
);

always_comb
begin
    we_rf       = '0;
    we_dm       = '0;
    eq_neq      = '0;
    rf_src      = `RF_ALUR;
    ALU_Code    = `ALU_ADD;
    srcBsel     = `SRCB_IMM;
    imm_src     = `I_SEL;
    branch_type = `B_NONE;
    casex( { opcode , funct3 , funct7 } )
        //  R - type command's
        { `C_ADD  , `F3_ADD  , `F7_ADD } : begin we_rf = '1; ALU_Code = `ALU_ADD;  srcBsel = `SRCB_RD1;                                                                                        end
        { `C_SUB  , `F3_SUB  , `F7_SUB } : begin we_rf = '1; ALU_Code = `ALU_SUB;  srcBsel = `SRCB_RD1;                                                                                        end
        { `C_OR   , `F3_OR   , `F7_ANY } : begin we_rf = '1; ALU_Code = `ALU_OR;   srcBsel = `SRCB_RD1;                                                                                        end
        //  I - type command's
        { `C_SLLI , `F3_SLLI , `F7_ANY } : begin we_rf = '1; ALU_Code = `ALU_SLLI; srcBsel = `SRCB_IMM; imm_src = `I_SEL;                                                                      end
        { `C_ADDI , `F3_ADDI , `F7_ANY } : begin we_rf = '1; ALU_Code = `ALU_ADD;  srcBsel = `SRCB_IMM; imm_src = `I_SEL;                                                                      end
        { `C_LW   , `F3_LW   , `F7_ANY } : begin we_rf = '1; ALU_Code = `ALU_ADD;  srcBsel = `SRCB_IMM; imm_src = `I_SEL;                                                   rf_src = `RF_DMEM; end
        //  U - type command's
        { `C_LUI  , `F3_ANY  , `F7_ANY } : begin we_rf = '1; ALU_Code = `ALU_LUI;  srcBsel = `SRCB_IMM; imm_src = `U_SEL;                                                                      end
        //  B - type command's
        { `C_BEQ  , `F3_BEQ  , `F7_ANY } : begin we_rf = '0; ALU_Code = `ALU_ADD;  srcBsel = `SRCB_RD1; imm_src = `B_SEL; branch_type = `B_EQ_NEQ; eq_neq = '1;                                end
        //  S - type command's
        { `C_SW   , `F3_SW   , `F7_ANY } : begin we_rf = '0; ALU_Code = `ALU_ADD;  srcBsel = `SRCB_IMM; imm_src = `S_SEL;                                       we_dm = '1;                    end
        //  J - type command's
        //  in the future
        default                          : ;
    endcase
end

endmodule : nf_control_unit
