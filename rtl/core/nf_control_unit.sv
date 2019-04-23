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
    input   logic   [1 : 0]     instr_type,     // instruction type
    input   logic   [4 : 0]     opcode,         // operation code field in instruction code
    input   logic   [2 : 0]     funct3,         // funct 3 field in instruction code
    input   logic   [6 : 0]     funct7,         // funct 7 field in instruction code
    output  logic   [4 : 0]     imm_src,        // for enable immediate data
    output  logic   [0 : 0]     srcBsel,        // for selecting srcB ALU
    output  logic   [0 : 0]     res_sel,        // for selecting result
    output  logic   [3 : 0]     branch_type,    // for executing branch instructions
    output  logic   [0 : 0]     branch_hf,      // branch help field
    output  logic   [0 : 0]     branch_src,     // for selecting branch source (JALR)
    output  logic   [0 : 0]     we_rf,          // write enable signal for register file
    output  logic   [0 : 0]     we_dm,          // write enable signal for data memory and others
    output  logic   [0 : 0]     rf_src,         // write data select for register file
    output  logic   [1 : 0]     size_dm,        // size for load/store instructions
    output  logic   [3 : 0]     ALU_Code        // output code for ALU unit
);

    instr_cf    instr_cf_0;

    assign instr_cf_0.IT = instr_type,
           instr_cf_0.OP = opcode,
           instr_cf_0.F3 = funct3,
           instr_cf_0.F7 = funct7;

    assign branch_hf  = ~ instr_cf_0.F3[0];
    assign branch_src = instr_cf_0.OP == JALR.OP;
    assign we_dm      = instr_cf_0.OP == SW.OP;
    assign size_dm    = instr_cf_0.F3[0 +: 2];

    always_comb
    begin
        we_rf       = '0;
        rf_src      = RF_ALUR;
        ALU_Code    = ALU_ADD;
        srcBsel     = SRCB_IMM;
        res_sel     = RES_ALU;
        imm_src     = I_SEL;
        branch_type = B_NONE;
        case( instr_cf_0.IT )
            `RVI :
                casex( ret_code( instr_cf_0 ) )
                    //  R - type commands
                    ret_code( ADD   ) : begin we_rf = '1; ALU_Code = ALU_ADD; srcBsel = SRCB_RD2; res_sel = RES_ALU;                                                            end
                    ret_code( AND   ) : begin we_rf = '1; ALU_Code = ALU_AND; srcBsel = SRCB_RD2; res_sel = RES_ALU;                                                            end
                    ret_code( SUB   ) : begin we_rf = '1; ALU_Code = ALU_SUB; srcBsel = SRCB_RD2; res_sel = RES_ALU;                                                            end
                    ret_code( SLL   ) : begin we_rf = '1; ALU_Code = ALU_SLL; srcBsel = SRCB_RD2; res_sel = RES_ALU;                                                            end
                    ret_code( OR    ) : begin we_rf = '1; ALU_Code = ALU_OR;  srcBsel = SRCB_RD2; res_sel = RES_ALU;                                                            end
                    //  I - type commands
                    ret_code( ADDI  ) : begin we_rf = '1; ALU_Code = ALU_ADD; srcBsel = SRCB_IMM; res_sel = RES_ALU; imm_src = I_SEL;                                           end
                    ret_code( ORI   ) : begin we_rf = '1; ALU_Code = ALU_OR;  srcBsel = SRCB_IMM; res_sel = RES_ALU; imm_src = I_SEL;                                           end
                    ret_code( SLLI  ) : begin we_rf = '1; ALU_Code = ALU_SLL; srcBsel = SRCB_IMM; res_sel = RES_ALU; imm_src = I_SEL;                                           end
                    ret_code( LW    ) : begin we_rf = '1; ALU_Code = ALU_ADD; srcBsel = SRCB_IMM; res_sel = RES_ALU; imm_src = I_SEL;                         rf_src = RF_DMEM; end
                    ret_code( JALR  ) : begin we_rf = '1; ALU_Code = ALU_ADD; srcBsel = SRCB_IMM; res_sel = RES_UB ; imm_src = I_SEL; branch_type = B_UB;                       end
                    //  U - type commands
                    ret_code( LUI   ) : begin we_rf = '1; ALU_Code = ALU_LUI; srcBsel = SRCB_IMM; res_sel = RES_ALU; imm_src = U_SEL;                                           end
                    //  B - type commands
                    ret_code( BEQ   ) : begin we_rf = '0; ALU_Code = ALU_ADD; srcBsel = SRCB_RD2; res_sel = RES_ALU; imm_src = B_SEL; branch_type = B_EQ_NEQ;                   end
                    ret_code( BNE   ) : begin we_rf = '0; ALU_Code = ALU_ADD; srcBsel = SRCB_RD2; res_sel = RES_ALU; imm_src = B_SEL; branch_type = B_EQ_NEQ;                   end
                    //  S - type commands
                    ret_code( SW    ) : begin we_rf = '0; ALU_Code = ALU_ADD; srcBsel = SRCB_IMM; res_sel = RES_ALU; imm_src = S_SEL;                                           end
                    //  J - type commands
                    ret_code( JAL   ) : begin we_rf = '1; ALU_Code = ALU_ADD; srcBsel = SRCB_IMM; res_sel = RES_UB ; imm_src = J_SEL; branch_type = B_UB;                       end
                    //  in the future
                    default : ;
                endcase
            default : ;
        endcase
    end

    function logic [8 : 0] ret_code(instr_cf instr_cf_);
        return  { instr_cf_.OP , instr_cf_.F3 , instr_cf_.F7[5] };
    endfunction : ret_code

endmodule : nf_control_unit
