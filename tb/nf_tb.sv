/*
*  File            :   nf_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is testbench for cpu unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"
module nf_tb();

    timeprecision   1ns ;
    timeunit        1ns ;
    
    bit             clk;
    bit             resetn;
    logic   [4:0]   reg_addr;
    logic   [31:0]  reg_data;

    nf_cpu nf_cpu_0
    (
        .*
    );

    initial
    for(int i=0;i<32;i++)
        nf_cpu_0.reg_file_0.int_reg_file[i] = '0;

    initial
    forever #(5) clk = ~clk;

    initial
    begin
        repeat(7) @(posedge clk);
        resetn = '1;
    end

endmodule : nf_tb
