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
    input   logic   [4 : 0]     wa3,            // write address field
    output  logic   [4 : 0]     imm_src,        // for enable immediate data
    output  logic   [1 : 0]     srcB_sel,       // for selecting srcB ALU
    output  logic   [1 : 0]     srcA_sel,       // for selecting srcA ALU
    output  logic   [1 : 0]     shift_sel,      // for selecting shift input
    output  logic   [0 : 0]     res_sel,        // for selecting result
    output  logic   [3 : 0]     branch_type,    // for executing branch instructions
    output  logic   [0 : 0]     branch_hf,      // branch help field
    output  logic   [0 : 0]     branch_src,     // for selecting branch source (JALR)
    output  logic   [0 : 0]     we_rf,          // write enable signal for register file
    output  logic   [0 : 0]     we_dm,          // write enable signal for data memory and others
    output  logic   [0 : 0]     rf_src,         // write data select for register file
    output  logic   [1 : 0]     size_dm,        // size for load/store instructions
    output  logic   [0 : 0]     sign_dm,        // sign extended data memory for load instructions
    output  logic   [1 : 0]     csr_cmd,        // csr command
    output  logic   [0 : 0]     csr_rreq,       // read request to csr
    output  logic   [0 : 0]     csr_wreq,       // write request to csr
    output  logic   [0 : 0]     csr_sel,        // csr select ( zimm or rd1 )
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
    assign sign_dm    = ~ instr_cf_0.F3[2];

    assign csr_rreq = ( instr_cf_0.OP == CSR_OP ) && ( | instr_cf_0.F3 ) && ( | wa3 );
    assign csr_wreq = ( instr_cf_0.OP == CSR_OP ) && ( | instr_cf_0.F3 );
    assign csr_sel  = ( instr_cf_0.F3[2] == '1 );

    // csr command select
    always_comb
    begin : csr_cmd_sel
        csr_cmd = CSR_NONE;
        if( instr_cf_0.IT == `RVI )
            case( instr_cf_0.OP )
                CSR_OP  :   csr_cmd = | instr_cf_0.F3 ? instr_cf_0.F3[1 : 0] : CSR_NONE;
                default :;
            endcase
    end
    // shift input selecting
    always_comb
    begin : shift_sel_log
        shift_sel = SRCS_RD2;
        if( instr_cf_0.IT == `RVI )
            case( instr_cf_0.OP )
                R_OP0   :   shift_sel = SRCS_RD2;
                I_OP0   :   shift_sel = SRCS_SHAMT;
                U_OP0   :   shift_sel = SRCS_12;
                default :;
            endcase
    end
    // immediate source selecting
    always_comb
    begin : imm_comb
        imm_src = I_SEL;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    J_OP0                   : imm_src = J_SEL;
                    S_OP0                   : imm_src = S_SEL;
                    B_OP0                   : imm_src = B_SEL;
                    U_OP0 , U_OP1           : imm_src = U_SEL;
                    I_OP0 , I_OP1 , I_OP2   : imm_src = I_SEL;
                    default                 :;
                endcase
            default :;
        endcase
    end
    // register file source selecting
    always_comb
    begin : rf_src_comb
        rf_src = RF_ALUR;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    I_OP1   : rf_src = RF_DMEM;
                    default :;
                endcase
            default :;
        endcase
    end
    // write enable register file
    always_comb
    begin : we_rf_comb
        we_rf = '0;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    R_OP0                   : we_rf = '1;
                    J_OP0                   : we_rf = '1;
                    S_OP0                   : we_rf = '0;
                    B_OP0                   : we_rf = '0;
                    U_OP0 , U_OP1           : we_rf = '1;
                    I_OP0 , I_OP1 , I_OP2   : we_rf = '1;
                    CSR_OP                  : we_rf = | wa3;
                    default                 :;
                endcase
            default :;
        endcase
    end
    // source A for ALU selecting
    always_comb
    begin : srcA_sel_comb
        srcA_sel = SRCA_RD1;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    R_OP0   :   srcA_sel = SRCA_RD1;
                    U_OP0   :   srcA_sel = SRCA_IMM;
                    U_OP1   :   srcA_sel = SRCA_PC;
                    default :;
                endcase
            default :;
        endcase
    end
    // source B for ALU selecting
    always_comb
    begin : srcB_sel_comb
        srcB_sel = SRCB_IMM;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    U_OP1           : srcB_sel = SRCB_12;
                    R_OP0 , B_OP0   : srcB_sel = SRCB_RD2;
                    default         :;
                endcase
            default :;
        endcase
    end
    // branch type finding
    always_comb
    begin : branch_type_comb
        branch_type = B_NONE;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    B_OP0           :
                        case( instr_cf_0.F3[2 : 1] )
                            2'b00   : branch_type = B_EQ_NEQ;
                            2'b10   : branch_type = B_GE_LT;
                            2'b11   : branch_type = B_GEU_LTU;
                            default :;
                        endcase
                    J_OP0 , I_OP2   : branch_type = B_UB;
                    default         :;
                endcase
            default :;
        endcase
    end
    // result select
    always_comb
    begin : res_sel_comb
        res_sel = RES_ALU;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    J_OP0 , I_OP2   : res_sel = RES_UB;     // JAL or JALR
                    default         :;
                endcase
            default :;
        endcase
    end
    // setting code for ALU    
    always_comb
    begin : ALU_Code_comb
        ALU_Code = ALU_ADD;
        case( instr_cf_0.IT )
            `RVI    :
                case( instr_cf_0.OP )
                    U_OP0           : ALU_Code = ALU_SLL;
                    R_OP0 , I_OP0   : 
                        case( instr_cf_0.F3 )
                            ADD.F3  : ALU_Code = instr_cf_0.F7[5] && (instr_cf_0.OP == R_OP0) ? ALU_SUB : ALU_ADD;
                            AND.F3  : ALU_Code = ALU_AND;
                            OR.F3   : ALU_Code = ALU_OR;
                            SLL.F3  : ALU_Code = ALU_SLL;
                            SRL.F3  : ALU_Code = instr_cf_0.F7[5] ? ALU_SRA : ALU_SRL;
                            XOR.F3  : ALU_Code = ALU_XOR;
                            SLT.F3  : ALU_Code = ALU_SLT;
                            SLTU.F3 : ALU_Code = ALU_SLTU;
                            default :;
                        endcase    
                    default         :;
                endcase
            default :;
        endcase
    end

endmodule : nf_control_unit
