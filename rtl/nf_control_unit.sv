/*
*  File            :   nf_control_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is controll unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_cpu.svh"

module nf_control_unit
(
    input   logic   [6  : 0]    opcode,         // operation code field in instruction code
    input   logic   [2  : 0]    funct3,         // funct 3 field in instruction code
    input   logic   [6  : 0]    funct7,         // funct 7 field in instruction code
    output  logic   [1  : 0]    imm_src,        // for selecting immediate data
    output  logic   [0  : 0]    srcBsel,        // for selecting srcB ALU
    output  logic   [0  : 0]    branch_type,    // for executing branch instructions
    output  logic   [0  : 0]    branch_hf,      // branch help field
    output  logic   [0  : 0]    we,             // write enable signal for register file
    output  logic   [2  : 0]    ALU_Code        // output code for ALU unit
);

    always_comb
    begin
        we          = '0;
        ALU_Code    = `ALU_ADD;
        srcBsel     = `SRCB_IMM;
        imm_src     = `I_SEL;
        branch_hf   = '0;
        branch_type = `B_NONE;
        casex( { opcode , funct3 , funct7 } )
            //  R - type command's
            { `C_ADD  , `F3_ADD  , `F7_ADD } : begin we = '1; ALU_Code = `ALU_ADD; srcBsel = `SRCB_RD1;                                                            end
            { `C_SUB  , `F3_SUB  , `F7_SUB } : begin we = '1; ALU_Code = `ALU_SUB; srcBsel = `SRCB_RD1;                                                            end
            { `C_OR   , `F3_OR   , `F7_ANY } : begin we = '1; ALU_Code = `ALU_OR;  srcBsel = `SRCB_RD1;                                                            end
            //  I - type command's
            { `C_SLLI , `F3_SLLI , `F7_ANY } : begin we = '1; ALU_Code = `ALU_SLL; srcBsel = `SRCB_IMM; imm_src = `I_SEL;                                          end
            { `C_ADDI , `F3_ADDI , `F7_ANY } : begin we = '1; ALU_Code = `ALU_ADD; srcBsel = `SRCB_IMM; imm_src = `I_SEL;                                          end
            //  U - type command's
            { `C_LUI  , `F3_ANY  , `F7_ANY } : begin we = '1; ALU_Code = `ALU_LUI; srcBsel = `SRCB_IMM; imm_src = `U_SEL;                                          end
            //  B - type command's
            { `C_BEQ  , `F3_BEQ  , `F7_ANY } : begin we = '0; ALU_Code = `ALU_ADD; srcBsel = `SRCB_RD1; imm_src = `B_SEL; branch_type = `B_EQ_NEQ; branch_hf = '1; end
            //  S - type command's
            //  in the future
            //  J - type command's
            //  in the future
            default                          : ;
        endcase
    end

endmodule : nf_control_unit
