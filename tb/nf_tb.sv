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

module nf_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 200;
    
    bit                 clk;
    bit                 resetn;
    bit     [25 : 0]    div;
    //pwm side
    bit                 pwm;
    //gpid side
    logic   [7  : 0]    gpi;
    logic   [7  : 0]    gpo;
    logic   [7  : 0]    gpd;
    logic   [7  : 0]    gpio;

    bit     [4  : 0]    reg_addr;
    bit     [31 : 0]    reg_data;
    bit     [31 : 0]    cycle_counter;

    integer             log;

    genvar gpio_i;
    generate
        for( gpio_i='0 ; gpio_i<8 ; gpio_i=gpio_i+1'b1 )
        begin
            assign  gpio[gpio_i] = gpd[gpio_i] ? gpo[gpio_i] : 'z;
            assign  gpi[gpio_i]  = gpio[gpio_i];
        end
    endgenerate

    string              instruction;
    string              instr_sep;

    nf_top nf_top_0
    (
        .*
    );

    //reset all register's in '0
    initial
        for( int i=0 ; i<32 ; i++ )
            nf_top_0.nf_cpu_0.reg_file_0.reg_file[i] = '0;
    //reset data memory
    initial
        for( int i=0 ; i<`ram_depth ; i++ )
            nf_top_0.nf_ram_0.ram[i]='0;
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
        div = 3;
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
            @(posedge nf_top_0.cpu_en);
            if( resetn )
            begin
                $display("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                $write("cycle = %d, pc = %h ", cycle_counter,nf_top_0.nf_cpu_0.instr_addr);
                pars_instr_0.pars(nf_top_0.nf_cpu_0.instr, instruction, instr_sep);
                if( `log_en )
                begin
                    $fwrite(log,"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
                    $fwrite(log,"cycle = %d, pc = 0x%h ", cycle_counter, nf_top_0.nf_cpu_0.instr_addr);
                    $fwrite(log,"\n                    ");
                    $fwrite(log,"%s\n", instruction);
                    if( `debug_lev0)
                        $fwrite(log,"                    %s\n", instr_sep);
                end
                cycle_counter++;
            end
            if( cycle_counter == repeat_cycles )
                $stop;
        end
    end

endmodule : nf_tb
