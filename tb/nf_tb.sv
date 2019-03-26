/*
*  File            :   nf_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is testbench for cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../tb/nf_pars.sv"

module nf_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 200;
    
    bit     [0  : 0]    clk;
    bit     [0  : 0]    resetn;
    bit     [4  : 0]    reg_addr;
    bit     [31 : 0]    reg_data;
    bit     [25 : 0]    div;
    bit     [31 : 0]    cycle_counter;

    integer             log;

    string              instruction;
    string              last_instr = "";
    string              instr_sep;
    string              log_str;
    string              reg_str;

    nf_top 
    nf_top_0
    (
        .*
    );

    // reset all register's in '0
    initial
        for(int i=0;i<32;i++)
            nf_top_0.nf_cpu_0.reg_file_0.reg_file[i] = '0;
    // generating clock
    initial
    begin
        $display("Clock generation start");
        forever #(T/2) clk = ~clk;
    end
    // generation reset
    initial
    begin
        $display("Reset is in active state");
        repeat(resetn_delay) @(posedge clk);
        resetn = '1;
        $display("Reset is in inactive state");
    end
    // creating pars_instruction class
    nf_pars nf_pars_0 = new();
    // parsing instruction
    initial
    begin
        div = 3;
        if( `log_html )
            nf_pars_0.build_html_loger("../log/log");
        if( `log_en )
        begin
            log = $fopen("../log/.log","w");
            if( !log )
                begin
                    $display("Error! File not open.");
                    $stop;
                end
        end
        forever
        begin
            @(posedge nf_top_0.nf_cpu_0.cpu_en);
            if( resetn )
            begin
                nf_pars_0.pars(nf_top_0.nf_cpu_0.instr, instruction, instr_sep);
                nf_pars_0.write_txt_table(nf_top_0.nf_cpu_0.reg_file_0.reg_file, reg_str);

                log_str = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";
                log_str = { log_str , $psprintf("cycle = %d, pc = %h, %t \n", cycle_counter, nf_top_0.nf_cpu_0.instr_addr, $time) };
                log_str = { log_str , $psprintf("               Current instruction : %s\n", instruction) };
                log_str = { log_str , $psprintf("               Last instruction    : %s\n", last_instr ) };
                if( `debug_lev0 )
                    log_str = { log_str , $psprintf("               %s\n", instr_sep) };
                if( `log_html )
                    nf_pars_0.write_html_log( nf_top_0.nf_cpu_0.reg_file_0.reg_file, log_str);
                log_str = { log_str , $psprintf("%s", reg_str) };
                $display(log_str);
                if( `log_en )
                    $fwrite(log,"%s",log_str);

                last_instr = instruction;
                cycle_counter++;
            end
            if( cycle_counter == repeat_cycles )
                $stop;
        end
    end

endmodule : nf_tb
