/*
*  File            :   nf_i_exu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is instruction execution unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"
`include "../../inc/nf_cpu.svh"

module nf_i_exu
(
    input   logic   [0  : 0]    clk,        // clock
    input   logic   [31 : 0]    rd1,        // read data from reg file (port1)
    input   logic   [31 : 0]    rd2,        // read data from reg file (port2)
    input   logic   [31 : 0]    ext_data,   // sign extended immediate data
    input   logic   [31 : 0]    pc_v,       // program-counter value
    input   logic   [1  : 0]    srcA_sel,   // source A enable signal for ALU
    input   logic   [1  : 0]    srcB_sel,   // source B enable signal for ALU
    input   logic   [1  : 0]    shift_sel,  // for selecting shift input
    input   logic   [4  : 0]    shamt,      // for shift operations
    input   logic   [3  : 0]    ALU_Code,   // code for ALU
    output  logic   [31 : 0]    result      // result of ALU operation
);

    // wires for ALU inputs
    logic   [31 : 0]    srcA;   // source A ALU
    logic   [31 : 0]    srcB;   // source B ALU
    logic   [4  : 0]    shift;  // for shift ALU input
    // finding srcA value
    always_comb
    begin
        srcA = rd1;
        case( srcA_sel )
            SRCA_IMM    :   srcA = ext_data;
            SRCA_RD1    :   srcA = rd1;
            SRCA_PC     :   srcA = pc_v;
            default     :   ;
        endcase
    end
    // finding srcB value
    always_comb
    begin
        srcB = rd2;
        case( srcB_sel )
            SRCB_RD2    :   srcB = rd2;
            SRCB_IMM    :   srcB = ext_data;
            SRCB_12     :   srcB = ext_data << 12;
            default     :   ;
        endcase
    end
    // finding shift value
    always_comb
    begin
        shift = rd2[0 +: 5];
        case( shift_sel )
            SRCS_SHAMT  :   shift = shamt;
            SRCS_RD2    :   shift = rd2[0 +: 5];
            SRCS_12     :   shift = 5'd12;
            default     :   ;
        endcase
    end
    // creating ALU unit
    nf_alu 
    alu_0
    (
        .clk            ( clk           ),  // clock
        .srcA           ( srcA          ),  // source A for ALU unit
        .srcB           ( srcB          ),  // source B for ALU unit
        .shift          ( shift         ),  // for shift operation
        .ALU_Code       ( ALU_Code      ),  // ALU code from control unit
        .result         ( result        )   // result of ALU operation
    );

endmodule : nf_i_exu
