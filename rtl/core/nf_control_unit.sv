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
    input   logic   [1  : 0]    instr_type,     // instruction type
    input   logic   [4  : 0]    opcode,         // operation code field in instruction code
    input   logic   [2  : 0]    funct3,         // funct 3 field in instruction code
    input   logic   [6  : 0]    funct7,         // funct 7 field in instruction code
    output  logic   [4  : 0]    imm_src,        // for enable immediate data
    output  logic   [0  : 0]    srcBsel,        // for selecting srcB ALU
    output  logic   [2  : 0]    branch_type,    // for executing branch instructions
    output  logic   [0  : 0]    branch_hf,      // branch help field
    output  logic   [0  : 0]    we_rf,          // write enable signal for register file
    output  logic   [0  : 0]    we_dm,          // write enable signal for data memory and others
    output  logic   [0  : 0]    rf_src,         // write data select for register file
    output  logic   [31 : 0]    ALU_Code        // output code for ALU unit
);

    instr_cf    instr_cf_0;

    assign  instr_cf_0.IT = instr_type,
            instr_cf_0.OP = opcode,
            instr_cf_0.F3 = funct3,
            instr_cf_0.F7 = funct7;

    assign  branch_hf = ~ instr_cf_0.F3[0];

    always_comb
    begin
        we_rf       = '0;
        we_dm       = '0;
        rf_src      = RF_ALUR;
        ALU_Code    = ALU_ADD;
        srcBsel     = SRCB_IMM;
        imm_src     = I_NONE;
        branch_type = B_NONE;
        case( instr_cf_0.IT )
            `RVI :
                casex( ret_code( instr_cf_0 ) )
                    //  R - type commands
                    ret_code( ADD   ) : begin we_rf = '1; ALU_Code = ALU_ADD;  srcBsel = SRCB_RD1;                                                                        end
                    ret_code( AND   ) : begin we_rf = '1; ALU_Code = ALU_AND;  srcBsel = SRCB_RD1;                                                                        end
                    ret_code( SUB   ) : begin we_rf = '1; ALU_Code = ALU_SUB;  srcBsel = SRCB_RD1;                                                                        end
                    ret_code( SLL   ) : begin we_rf = '1; ALU_Code = ALU_SLL;  srcBsel = SRCB_RD1;                                                                        end
                    ret_code( OR    ) : begin we_rf = '1; ALU_Code = ALU_OR;   srcBsel = SRCB_RD1;                                                                        end
                    //  I - type commands
                    ret_code( ADDI  ) : begin we_rf = '1; ALU_Code = ALU_ADD;  srcBsel = SRCB_IMM; imm_src = I_SEL;                                                       end
                    ret_code( ORI   ) : begin we_rf = '1; ALU_Code = ALU_OR;   srcBsel = SRCB_IMM; imm_src = I_SEL;                                                       end
                    ret_code( SLLI  ) : begin we_rf = '1; ALU_Code = ALU_SLL;  srcBsel = SRCB_IMM; imm_src = I_SEL;                                                       end
                    ret_code( LW    ) : begin we_rf = '1; ALU_Code = ALU_ADD;  srcBsel = SRCB_IMM; imm_src = I_SEL;                                     rf_src = RF_DMEM; end
                    //  U - type commands
                    ret_code( LUI   ) : begin we_rf = '1; ALU_Code = ALU_LUI;  srcBsel = SRCB_IMM; imm_src = U_SEL;                                                       end
                    //  B - type commands
                    ret_code( BEQ   ) : begin we_rf = '0; ALU_Code = ALU_ADD;  srcBsel = SRCB_RD1; imm_src = B_SEL; branch_type = B_EQ_NEQ;                               end
                    ret_code( BNE   ) : begin we_rf = '0; ALU_Code = ALU_ADD;  srcBsel = SRCB_RD1; imm_src = B_SEL; branch_type = B_EQ_NEQ;                               end
                    //  S - type commands
                    ret_code( SW    ) : begin we_rf = '0; ALU_Code = ALU_ADD;  srcBsel = SRCB_IMM; imm_src = S_SEL;                         we_dm = '1;                   end
                    //  J - type commands
                    ret_code( JAL   ) : begin we_rf = '0; ALU_Code = ALU_ADD;  srcBsel = SRCB_IMM; imm_src = J_SEL;                         we_dm = '1;                   end
                    //  in the future
                    default : ;
                endcase
            default : ;
        endcase
    end

    function logic [14 : 0] ret_code(instr_cf instr_cf_);
        return  { instr_cf_.OP , instr_cf_.F3 , instr_cf_.F7[5] };
    endfunction : ret_code

endmodule : nf_control_unit
