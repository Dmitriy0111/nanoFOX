/*
*  File            :   nf_alu_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.13
*  Language        :   SystemVerilog
*  Description     :   This is testbench for ALU module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../../inc/nf_cpu.svh"

module nf_alu_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 200;

    logic   [31 : 0]    srcA;       // source A for ALU unit
    logic   [31 : 0]    srcB;       // source B for ALU unit
    logic   [31 : 0]    shift;      // for shift operation
    logic   [3  : 0]    ALU_Code;   // ALU code from control unit
    logic   [31 : 0]    result;     // result of ALU operation

    integer             cycle = 0;


    nf_alu 
    nf_alu_0
    (
        .srcA       ( srcA      ),  // source A for ALU unit
        .srcB       ( srcB      ),  // source B for ALU unit
        .shift      ( shift     ),  // for shift operation
        .ALU_Code   ( ALU_Code  ),  // ALU code from control unit
        .result     ( result    )   // result of ALU operation
    );

    task set_srcA(integer i);
        srcA = i;
    endtask : set_srcA

    task set_srcB(integer i);
        srcB = i;
    endtask : set_srcB

    task set_shift(integer i);
        shift = i;
    endtask : set_shift

    task set_ALU_code(logic [3 : 0] code);
        ALU_Code = code;
    endtask : set_ALU_code

    task check();
        case( ALU_Code )
            ALU_ADD     :   $display("ADD  operation. cycle = %d, srcA = %h, srcB  = %h, result = %h, test %s", cycle, srcA ,  srcB , result, result == ( srcA  +  srcB ) ? "Pass" : "Error" );
            ALU_AND     :   $display("AND  operation. cycle = %d, srcA = %h, srcB  = %h, result = %h, test %s", cycle, srcA ,  srcB , result, result == ( srcA  &  srcB ) ? "Pass" : "Error" );
            ALU_OR      :   $display("OR   operation. cycle = %d, srcA = %h, srcB  = %h, result = %h, test %s", cycle, srcA ,  srcB , result, result == ( srcA  |  srcB ) ? "Pass" : "Error" );
            ALU_XOR     :   $display("XOR  operation. cycle = %d, srcA = %h, srcB  = %h, result = %h, test %s", cycle, srcA ,  srcB , result, result == ( srcA  ^  srcB ) ? "Pass" : "Error" );
            ALU_SLL     :   $display("SLL  operation. cycle = %d, srcA = %h, shift = %h, result = %h, test %s", cycle, srcA , shift , result, result == ( srcA << shift ) ? "Pass" : "Error" );
            ALU_SRL     :   $display("SRL  operation. cycle = %d, srcA = %h, shift = %h, result = %h, test %s", cycle, srcA , shift , result, result == ( srcA >> shift ) ? "Pass" : "Error" );
            ALU_SLT     :   $display("SLT  operation. cycle = %d, srcA = %h, srcB  = %h, result = %h, test %s", cycle, srcA ,  srcB , result, result == ( $signed(srcA) <   $signed(srcB) ) ? "Pass" : "Error" );
            ALU_SLTU    :   $display("SLTU operation. cycle = %d, srcA = %h, srcB  = %h, result = %h, test %s", cycle, srcA ,  srcB , result, result == ( $unsigned(srcA) <   $unsigned(srcB) ) ? "Pass" : "Error" );
        endcase
        cycle ++;
    endtask : check

    // ALU_SLT
    // ALU_SLTU

    initial
    begin
        set_srcA(0);
        set_srcB(0);
        set_shift(0);
        set_ALU_code(ALU_ADD);
        repeat(repeat_cycles)
        begin
            set_srcA($random());
            set_srcB($random());
            set_shift($random());
            set_ALU_code($random());
            set_ALU_code(ALU_SLTU);
            #T;
            check();
            #T;
        end
        $stop;
    end

endmodule : nf_alu_tb
