/*
*  File            :   nf_i_exu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is instruction execution unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_i_exu
(
    input   logic   [31 : 0]    rd1,
    input   logic   [31 : 0]    rd2,
    input   logic   [31 : 0]    ext_data,
    input   logic   [0  : 0]    srcB_sel,
    input   logic   [4  : 0]    shamt,
    input   logic   [31 : 0]    ALU_Code,
    output  logic   [31 : 0]    result
);
    // wires for ALU inputs
    logic   [31 : 0]    srcA;
    logic   [31 : 0]    srcB;
    // assign's ALU signals
    assign  srcA = rd1;
    assign  srcB = srcB_sel ? rd2 : ext_data;
    // creating ALU unit
    nf_alu alu_0
    (
        .srcA           ( srcA          ),
        .srcB           ( srcB          ),
        .shamt          ( shamt         ),
        .ALU_Code       ( ALU_Code      ),
        .result         ( result        )
    );

endmodule : nf_i_exu
