/*
*  File            :   nf_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is testbench for cpu unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"
`include "../tb/pars_instr.sv"

module nf_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    bit                 clk;
    bit                 resetn;
    bit     [4  : 0]    reg_addr;
    bit     [31 : 0]    reg_data;
    bit     [25 : 0]    div;

    nf_cpu nf_cpu_0
    (
        .*
    );

    initial
        for(int i=0;i<32;i++)
            nf_cpu_0.reg_file_0.reg_file[i] = '0;

    initial
        forever #(5) clk = ~clk;

    pars_instr pars_instr_0 = new();
    
    initial
    begin
        forever
        begin
            @(posedge nf_cpu_0.pc_en);
            if(resetn)
                pars_instr_0.pars(nf_cpu_0.instr);
            $stop;
        end
    end

    initial
    begin
        div = 3;
        repeat(7) @(posedge clk);
        resetn = '1;
    end

endmodule : nf_tb
