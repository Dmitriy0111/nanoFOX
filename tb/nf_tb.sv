/*
*  File            :   nf_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is testbench for cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`include "../tb/nf_pars.sv"

module nf_tb();
    // simulation settings
    timeprecision       1ns;
    timeunit            1ns;
    // simulation constants
    parameter           T = 10,                 // 50 MHz (clock period)
                        resetn_delay = 7,       // delay for reset signal (posedge clk)
                        repeat_cycles = 200;    // number of repeat cycles before stop
    // clock and reset
    bit                 clk;            // clock
    bit                 resetn;         // reset
    bit     [25 : 0]    div;            // "clock divide" input
    // pwm side
    bit                 pwm;            // pwm output
    // gpid side
    logic   [7  : 0]    gpi;            // gpio input
    logic   [7  : 0]    gpo;            // gpio output
    logic   [7  : 0]    gpd;            // gpio direction
    logic   [7  : 0]    gpio;           // gpio
    // for debug
    bit     [4  : 0]    reg_addr;       // register address
    bit     [31 : 0]    reg_data;       // register data for reg_addr
    bit     [31 : 0]    cycle_counter;  // variable for cpu cycle

    integer             log;            // pointer to log file
    // instructions
    string              instruction;    // instruction string
    string              last_instr="";  // last execute instruction
    string              instr_sep;      // instruction string (debug level 0)
    string              log_str;        // log string
    string              reg_str;        // register file string

    genvar gpio_i;
    generate
        for( gpio_i='0 ; gpio_i<8 ; gpio_i=gpio_i+1'b1 )
        begin
            assign  gpio[gpio_i] = gpd[gpio_i] ? gpo[gpio_i] : 'z;
            // assign  gpi[gpio_i]  = gpio[gpio_i];
        end
    endgenerate

    // creating one nf_top_0 DUT
    nf_top 
    nf_top_0
    (
        // clock and reset
        .clk        ( clk       ),  // clock
        .resetn     ( resetn    ),  // reset
        .div        ( div       ),  // clock divide input
        // pwm side
        .pwm        ( pwm       ),  // PWM output
        // gpio side
        .gpi        ( gpi       ),  // GPIO input
        .gpo        ( gpo       ),  // GPIO output
        .gpd        ( gpd       ),  // GPIO direction
        // for debug
        .reg_addr   ( reg_addr  ),  // scan register address
        .reg_data   ( reg_data  )   // scan register data
    );

    /*
    or
    nf_top 
    nf_top_0
    (
        .*
    );
    */

    // reset all register's in '0
    initial
        for( int i=0 ; i<32 ; i++ )
            nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[i] = '0;
    // reset data memory
    initial
        for( int i=0 ; i<`RAM_DEPTH ; i++ )
            nf_top_0.nf_ram_0.ram[i]='0;
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
    //creating pars_instruction class
    nf_pars nf_pars_0 = new();
    //parsing instruction
    initial
    begin
        gpi = 8'b1;
        div = 3;
        if( `log_html )
            nf_pars_0.build_html_logger("../log/log");
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
                nf_pars_0.write_txt_table(nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file, reg_str);

                log_str = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";
                log_str = { log_str , $psprintf("cycle = %d, pc = %h, %t \n", cycle_counter, nf_top_0.nf_cpu_0.instr_addr, $time) };
                log_str = { log_str , $psprintf("               Current instruction : %s\n", instruction) };
                log_str = { log_str , $psprintf("               Last instruction    : %s\n", last_instr ) };
                if( `debug_lev0 )
                    log_str = { log_str , $psprintf("               %s\n", instr_sep) };
                if( `log_html )
                    nf_pars_0.write_html_log( nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file, log_str);
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
