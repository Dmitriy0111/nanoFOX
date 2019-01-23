/*
*  File            :   nf_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is testbench for cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`include "../tb/pars_instr.sv"
`include "../tb/nf_tb.svh"

module nf_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 200;
    
    bit                 clk;
    bit                 resetn;

    bit     [4  : 0]    reg_addr;
    bit     [31 : 0]    reg_data;
    bit     [31 : 0]    cycle_counter;

    integer             log;

    //instructions
    string  instruction_id_stage;
    string  instruction_iexe_stage;
    string  instruction_imem_stage;
    string  instruction_iwb_stage;

    string  instr_sep_s_id_stage;
    string  instr_sep_s_iexe_stage;
    string  instr_sep_s_imem_stage;
    string  instr_sep_s_iwb_stage;

    nf_top nf_top_0
    (
        .*
    );

    //reset all register's in '0
    initial
        for( int i=0 ; i<32 ; i++ )
            nf_top_0.nf_cpu_0.reg_file_0.reg_file[i] = '0;
    //generating clock
    initial
    begin
        $display("Clock generation start");
        forever #(T/2) clk = ~clk;
    end
    //generation reset
    initial
    begin
        $display("Reset is in active state");
        repeat(resetn_delay) @(posedge clk);
        resetn = '1;
        $display("Reset is in inactive state");
    end
    //creating pars_instruction class
    pars_instr pars_instr_0 = new();
    //parsing instruction
    initial
    begin
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
            @( posedge nf_top_0.clk );
            if( resetn )
            begin
                $display("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                $write("cycle = %d, pc = %h ", cycle_counter,nf_top_0.nf_cpu_0.addr_i );
                $display("%t", $time);
                $write("Instruction decode stage        : ");
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_id   , instruction_id_stage   , instr_sep_s_id_stage     );
                if( `debug_lev0 )
                    $write("                                  %s \n" , instr_sep_s_id_stage     );
                $write("Instruction execute stage       : ");
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_iexe , instruction_iexe_stage , instr_sep_s_iexe_stage   );
                if( `debug_lev0 )
                    $write("                                  %s \n" , instr_sep_s_iexe_stage   );
                $write("Instruction memory stage        : ");
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_imem , instruction_imem_stage , instr_sep_s_imem_stage   );
                if( `debug_lev0 )
                    $write("                                  %s \n" , instr_sep_s_imem_stage   );
                $write("Instruction write back stage    : ");
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_iwb  , instruction_iwb_stage  , instr_sep_s_iwb_stage    );
                if( `debug_lev0 )
                    $write("                                  %s \n" , instr_sep_s_iwb_stage    );
                if( `log_en )
                begin
                    $fwrite(log,"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
                    $fwrite(log,"cycle = %d, pc = 0x%h \n", cycle_counter, nf_top_0.nf_cpu_0.addr_i);
                    $fwrite(log,"Instruction decode stage        : ");
                    $fwrite(log,"%s\n", instruction_id_stage);
                    if( `debug_lev0 )
                    $fwrite(log,"                                  %s \n" , instr_sep_s_id_stage     );
                    $fwrite(log,"Instruction execute stage       : ");
                    $fwrite(log,"%s\n", instruction_iexe_stage);
                    if( `debug_lev0 )
                    $fwrite(log,"                                  %s \n" , instr_sep_s_iexe_stage   );
                    $fwrite(log,"Instruction memory stage        : ");
                    $fwrite(log,"%s\n", instruction_imem_stage);
                    if( `debug_lev0 )
                    $fwrite(log,"                                  %s \n" , instr_sep_s_imem_stage   );
                    $fwrite(log,"Instruction write back stage    : ");
                    $fwrite(log,"%s\n", instruction_iwb_stage);
                    if( `debug_lev0 )
                    $fwrite(log,"                                  %s \n" , instr_sep_s_iwb_stage    );
                end
                cycle_counter++;
            end
            if( cycle_counter == repeat_cycles )
                $stop;
        end
    end

endmodule : nf_tb
