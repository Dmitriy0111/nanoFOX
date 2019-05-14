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
                        repeat_cycles = 2000;

    logic   [0  : 0]    clk;        // clock
    logic   [31 : 0]    srcA;       // source A for ALU unit
    logic   [31 : 0]    srcB;       // source B for ALU unit
    logic   [4  : 0]    shift;      // for shift operation
    logic   [3  : 0]    ALU_Code;   // ALU code from control unit
    logic   [31 : 0]    result;     // result of ALU operation

    logic   [31 : 0]    exp_res = '0;
    integer             cycle = 0;
    integer             error = 0;
    bit     [0  : 0]    error_f = '0;


    nf_alu 
    nf_alu_0
    (
        .clk        ( clk       ),  // clock
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
            ALU_ADD     :   begin exp_res = ( srcA  +  srcB  );                                         error_f = result == exp_res; $display("ADD  operation. cycle = %d, srcA = %8h, srcB  = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA ,  srcB , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_SUB     :   begin exp_res = ( srcA  -  srcB  );                                         error_f = result == exp_res; $display("SUB  operation. cycle = %d, srcA = %8h, srcB  = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA ,  srcB , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_AND     :   begin exp_res = ( srcA  &  srcB  );                                         error_f = result == exp_res; $display("AND  operation. cycle = %d, srcA = %8h, srcB  = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA ,  srcB , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_OR      :   begin exp_res = ( srcA  |  srcB  );                                         error_f = result == exp_res; $display("OR   operation. cycle = %d, srcA = %8h, srcB  = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA ,  srcB , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_XOR     :   begin exp_res = ( srcA  ^  srcB  );                                         error_f = result == exp_res; $display("XOR  operation. cycle = %d, srcA = %8h, srcB  = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA ,  srcB , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_SLL     :   begin exp_res = ( srcA << shift  );                                         error_f = result == exp_res; $display("SLL  operation. cycle = %d, srcA = %8h, shift = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA , shift , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_SRL     :   begin exp_res = ( srcA >> shift  );                                         error_f = result == exp_res; $display("SRL  operation. cycle = %d, srcA = %8h, shift = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA , shift , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_SRA     :   begin exp_res = ( { 32 { srcA[31] } } << (31 - shift) | srcA >> shift );    error_f = result == exp_res; $display("SRA  operation. cycle = %d, srcA = %8h, shift = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA , shift , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_SLT     :   begin exp_res = ( $signed(srcA)   < $signed(srcB) );                        error_f = result == exp_res; $display("SLT  operation. cycle = %d, srcA = %8h, srcB  = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA ,  srcB , result, exp_res , error_f ? "Pass" : "Error" ); end
            ALU_SLTU    :   begin exp_res = ( $unsigned(srcA) < $unsigned(srcB) );                      error_f = result == exp_res; $display("SLTU operation. cycle = %d, srcA = %8h, srcB  = %8h, result = %8h, expected result = %8h, test %s", cycle, srcA ,  srcB , result, exp_res , error_f ? "Pass" : "Error" ); end
        endcase
        error = error + ( error_f ? 0 : 1 );
        cycle ++;
    endtask : check

    // ALU_SLT
    // ALU_SLTU

    initial 
    begin
        clk = '0;
        forever
            #(T/2) clk = ! clk;    
    end

    initial
    begin
        set_srcA(0);
        set_srcB(0);
        set_shift(0);
        set_ALU_code(ALU_ADD);
        repeat(repeat_cycles)
        begin
            set_srcA($random());
            //if($random()>10000)
            //    set_srcA('x);
            set_srcB($random());
            set_shift($random());
            set_ALU_code($random());
            //set_ALU_code(ALU_SLTU);
            @(posedge clk);
            check();
        end
        $display("Test finished with %d errors", error);
        $stop;
    end

endmodule : nf_alu_tb
