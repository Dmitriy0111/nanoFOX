/*
*  File            :   nf_sign_ex.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is module for sign extending
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_cpu.svh"

module nf_sign_ex
(
    input   logic   [11 : 0]    imm_data_i, // immediate data in i-type instruction
    input   logic   [19 : 0]    imm_data_u, // immediate data in u-type instruction
    input   logic   [11 : 0]    imm_data_b, // immediate data in b-type instruction
    input   logic   [11 : 0]    imm_data_s, // immediate data in s-type instruction
    input   logic   [19 : 0]    imm_data_j, // immediate data in j-type instruction
    input   logic   [4  : 0]    imm_src,    // selection immediate data input
    output  logic   [31 : 0]    imm_ex      // extended immediate data
);

    always_comb
    begin
        imm_ex = { { 20 { imm_data_i[11] } } , imm_data_i };
        case( imm_src )
            I_SEL     :   imm_ex = { { 20 { imm_data_i[11] } } , imm_data_i };
            U_SEL     :   imm_ex = { '0                        , imm_data_u };
            B_SEL     :   imm_ex = { { 20 { imm_data_b[11] } } , imm_data_b };
            S_SEL     :   imm_ex = { { 20 { imm_data_s[11] } } , imm_data_s };
            J_SEL     :   imm_ex = { { 12 { imm_data_j[19] } } , imm_data_j };
            default   : ;
        endcase
    end

endmodule : nf_sign_ex
