/*
*  File            :   nf_sign_ex.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is module for sign extending
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_cpu.svh"

module nf_sign_ex
(
    input           [11 : 0]    imm_data_i, // immediate data in i-type instruction
    input           [19 : 0]    imm_data_u, // immediate data in u-type instruction
    input           [11 : 0]    imm_data_b, // immediate data in b-type instruction
    input           [1  : 0]    imm_src,    // selection immediate data input
    output  logic   [31 : 0]    imm_ex      // extended immediate data
);

    always_comb
    begin
        imm_ex = '0;
        case( imm_src )
            `i_sel    :   imm_ex = { { 20 { imm_data_i[11] } } , imm_data_i[0 +: 12] };
            `u_sel    :   imm_ex = { '0                        , imm_data_u[0 +: 20] };
            `b_sel    :   imm_ex = { { 20 { imm_data_b[11] } } , imm_data_b[0 +: 12] };
            default   :   imm_ex = { { 20 { imm_data_i[11] } } , imm_data_i[0 +: 12] };
        endcase
    end

endmodule : nf_sign_ex
