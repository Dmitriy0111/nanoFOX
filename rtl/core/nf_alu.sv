/*
*  File            :   nf_alu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is ALU unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_cpu.svh"

module nf_alu
(
    input   logic   [0  : 0]    clk,        // clock
    input   logic   [31 : 0]    srcA,       // source A for ALU unit
    input   logic   [31 : 0]    srcB,       // source B for ALU unit
    input   logic   [4  : 0]    shift,      // for shift operation
    input   logic   [3  : 0]    ALU_Code,   // ALU code from control unit
    output  logic   [31 : 0]    result      // result of ALU operation
);

    logic   [0  : 0]    carry;      // carry flag
    logic   [0  : 0]    sign;       // sign flag
    logic   [0  : 0]    sof;        // substruction overflow flag

    logic   [32 : 0]    add_sub;    // addition or substruction result
    logic   [31 : 0]    shift_res;  // shift result
    logic   [31 : 0]    logic_res;  // result for logic operation

    assign carry = add_sub[32];
    assign sign  = add_sub[31];
    assign sof   = ( ! srcA[31] && srcB[31] && add_sub[31] ) || ( srcA[31] && ! srcB[31] && ! add_sub[31] );

    // finding ALU shift result
    always_comb
    begin
        shift_res = srcA << shift;
        case( ALU_Code )
            ALU_SLL     : shift_res = srcA << shift;
            ALU_SRL     : shift_res = srcA >> shift;
            ALU_SRA     : shift_res = { 32 { srcA[31] } } << (31 - shift) | srcA >> shift;
            default     :;
        endcase
    end
    // finding ALU logic result
    always_comb
    begin
        logic_res = srcA | srcB;
        case( ALU_Code )
            ALU_OR      : logic_res = srcA | srcB;
            ALU_XOR     : logic_res = srcA ^ srcB;
            ALU_AND     : logic_res = srcA & srcB;
            default     :;
        endcase
    end
    // finding ALU addition or substruction result
    always_comb
    begin
        add_sub = srcA + srcB;
        case( ALU_Code )
            ALU_ADD     : add_sub = srcA + srcB;
            ALU_SLT,
            ALU_SLTU,
            ALU_SUB     : add_sub = srcA - srcB;
            default     :;
        endcase
    end
    // finding result of ALU operation
    always_comb
    begin
        result = add_sub[31 : 0];
        case( ALU_Code )
            ALU_ADD,
            ALU_SUB     : result = add_sub[31 : 0];
            ALU_SLL,
            ALU_SRL,
            ALU_SRA     : result = shift_res;
            ALU_OR,
            ALU_XOR,
            ALU_AND     : result = logic_res;
            ALU_SLT     : result = sign ^ sof;          //result = ($signed(srcA) < $signed(srcB));
            ALU_SLTU    : result = '0 | carry;          // ($unsigned(srcA) < $unsigned(srcB));
            default     : result = add_sub[31 : 0];
        endcase
    end

    // synthesis translate_off
    /***************************************************
    **                   Assertions                   **
    ***************************************************/

    // creating propertis

    property SRCA_CHECK;
        @(posedge clk) ! $isunknown( srcA );
    endproperty

    property SRCB_CHECK;
        @(posedge clk) ! $isunknown( srcB );
    endproperty

    property SHIFT_CHECK;
        @(posedge clk) ! $isunknown( shift );
    endproperty

    property OP_CHECK;
        @(posedge clk) ! $isunknown( ALU_Code );
    endproperty

    // assertions

    NF_UNK_SRCA     : assert property (  SRCA_CHECK ) else $error("nf_alu error! srcA is unknown");
    NF_UNK_SRCB     : assert property (  SRCB_CHECK ) else $error("nf_alu error! srcB is unknown");
    NF_UNK_SHIFT    : assert property ( SHIFT_CHECK ) else $error("nf_alu error! shift is unknown");
    NF_UNK_OP       : assert property (    OP_CHECK ) else $error("nf_alu error! ALU_Code is unknown");

    // synthesis translate_on

endmodule : nf_alu
