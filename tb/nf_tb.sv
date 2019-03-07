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

    logic   [7  : 0]    gpio_i_0;   // GPIO_0 input
    logic   [7  : 0]    gpio_o_0;   // GPIO_0 output
    logic   [7  : 0]    gpio_d_0;   // GPIO_0 direction
    logic   [0  : 0]    pwm;        // PWM output signal
    logic   [0  : 0]    uart_tx;    // UART tx wire
    logic   [0  : 0]    uart_rx;    // UART rx wire

    assign  gpio_i_0 = gpio_o_0 ^ gpio_d_0;

    bit     [31 : 0]    cycle_counter;

    logic   [31 : 0]    reg_list_local   [31 : 0];
    logic   [1  : 0]    reg_list_changed [31 : 0];

    integer             log;
    integer             p_html;

    // instructions
    string  instruction_id_stage;
    string  instruction_iexe_stage;
    string  instruction_imem_stage;
    string  instruction_iwb_stage;
    // string for debug_lev0
    string  instr_sep_s_id_stage;
    string  instr_sep_s_iexe_stage;
    string  instr_sep_s_imem_stage;
    string  instr_sep_s_iwb_stage;
    // string for txt logging
    string  reg_list;
    // string for txt, html and terminal logging
    string  log_str = "";

    nf_top nf_top_0
    (   
        // clock and reset
        .clk        ( clk       ),  // clock input
        .resetn     ( resetn    ),  // reset input
        // GPIO side
        .gpio_i_0   ( gpio_i_0  ),  // GPIO_0 input
        .gpio_o_0   ( gpio_o_0  ),  // GPIO_0 output
        .gpio_d_0   ( gpio_d_0  ),  // GPIO_0 direction
        // PWM side
        .pwm        ( pwm       ),  // PWM output signal
        // UART side
        .uart_tx    ( uart_tx   ),  // UART tx wire
        .uart_rx    ( uart_rx   )   // UART rx wire
    );

    /*
    or
    nf_top nf_top_0
    (
        .*
    );
    */
    // overload path to program file
    defparam nf_top_0.nf_ram_i_d_0.path2file = "../program_file/program";

    // reset all registers in '0
    initial
        for( int i=0 ; i<32 ; i++ )
        begin
            nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[i] = '0;
            reg_list_local[i] = '0;
            reg_list_changed[i] = '0;
        end
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
    pars_instr pars_instr_0 = new();
    // parsing instruction
    initial
    begin
        if( `log_en )
        begin
            log = $fopen("../log/.log","w");
            if( !log )
                begin
                    $display("Error! File .log not open.");
                    $stop;
                end
        end
        if( `log_html )
            p_html = $fopen("../log/log.html","w");
            if( !p_html )
                begin
                    $display("Error! File log.html not open.");
                    $stop;
                end
        forever
        begin
            @( posedge nf_top_0.clk );
            if( resetn )
            begin
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_id   , instruction_id_stage   , instr_sep_s_id_stage   );
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_iexe , instruction_iexe_stage , instr_sep_s_iexe_stage );
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_imem , instruction_imem_stage , instr_sep_s_imem_stage );
                pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_iwb  , instruction_iwb_stage  , instr_sep_s_iwb_stage  );
                // form title
                log_str = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";
                log_str = { log_str , $psprintf("cycle = %d, pc = 0x%h ", cycle_counter, nf_top_0.nf_cpu_0.addr_i     ) };
                log_str = { log_str , $psprintf("%t\n", $time                                                         ) };
                // form instruction decode stage output
                log_str = { log_str , "Instruction decode stage        : "                                              };
                log_str = { log_str , $psprintf("%s\n", instruction_id_stage                                          ) };
                if( `debug_lev0 ) 
                    log_str = { log_str , $psprintf("                                  %s \n", instr_sep_s_id_stage   ) };
                // form instruction execution stage output
                log_str = { log_str , "Instruction execute stage       : "                                              };
                log_str = { log_str , $psprintf("%s\n", instruction_iexe_stage                                        ) };
                if( `debug_lev0 ) 
                    log_str = { log_str , $psprintf("                                  %s \n", instr_sep_s_iexe_stage ) };
                // form instruction memory stage output
                log_str = { log_str , "Instruction memory stage        : "                                              };
                log_str = { log_str , $psprintf("%s\n", instruction_imem_stage                                        ) };
                if( `debug_lev0 ) 
                    log_str = { log_str , $psprintf("                                  %s \n", instr_sep_s_imem_stage ) };
                // form instruction write back stage output
                log_str = { log_str , "Instruction write back stage    : "                                              };
                log_str = { log_str , $psprintf("%s\n", instruction_iwb_stage                                         ) };
                if( `debug_lev0 ) 
                    log_str = { log_str , $psprintf("                                  %s \n", instr_sep_s_iwb_stage  ) };
                // write debug info in simulator terminal
                $write(log_str);
                // write debug info in txt log file
                if( `log_en )
                begin
                    $fwrite( log, log_str );
                    pars_reg_list();
                    $fwrite( log,"register list :\n%s\n" , reg_list );
                end
                // write debug info in html log file
                if( `log_html )
                    write_info_html();
                // increment cycle counter
                cycle_counter++;
                if( cycle_counter == repeat_cycles )
                    $stop;
            end
        end
    end

    task pars_reg_list();

        integer reg_addr;
        reg_addr = '0;

        reg_list = "";
        do
        begin
            reg_list =  {
                            reg_list , 
                            $psprintf("%5s", pars_instr_0.reg_list[reg_addr] ) , 
                            $psprintf(" = 0x%h ", nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[reg_addr] ) , 
                            reg_addr[0 +: 2] == 3 ? "\n" : "" 
                        };
            reg_addr++;
        end
        while( reg_addr != 32 );

    endtask : pars_reg_list

    task write_info_html();

        integer i;
        i = 0;

        for( i = 0 ; i < 32 ; i++ )
        begin
            reg_list_changed[i] =   reg_list_local[i] == nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[i] ? 2'b00 : 2'b01;
            if( $isunknown( | nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[i] ) )
                reg_list_changed[i] = 2'b10;
            reg_list_local[i]   =   reg_list_changed[i] == 2'b00 ? 
                                    reg_list_local[i] : 
                                    nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[i];
        end
        $fwrite(p_html,"%s", "<font size = \"4\">");
        $fwrite(p_html,"<pre>");
        $fwrite(p_html, log_str );
        $fwrite(p_html,"</pre>\n");

        print_html_table( 8 , 4 , pars_instr_0.reg_list , reg_list_local , reg_list_changed );

        $fwrite(p_html,"%s", "</font>");

    endtask : write_info_html
        
    task print_html_table( integer row, integer col, string reg_list_ [0 : 31], logic [31 : 0] table_[31 : 0], logic [1 : 0] table_c_[31 : 0] );

        integer tr_i;
        integer td_i;
        string  reg_value;
        reg_value = "";
        tr_i = 0;
        td_i = 0;

        $fwrite(p_html,"<table border=\"1\">\n");

        do
        begin
            $fwrite(p_html,"    <tr>\n");
            do
            begin
                $fwrite(p_html,"        <td %s>",   table_c_[ tr_i * col + td_i ] == 2'b00 ? "bgcolor = \"white\"" : ( 
                                                    table_c_[ tr_i * col + td_i ] == 2'b01 ? "bgcolor = \"green\"" : 
                                                                                             "bgcolor = \"red\"" ) );
                $fwrite(p_html,"<pre>");
                reg_value = $psprintf("%h",table_[ tr_i * col + td_i ]);
                $fwrite(p_html," %5s 0x%H ", reg_list_[ tr_i * col + td_i ], reg_value.toupper() );
                $fwrite(p_html,"</pre>");
                $fwrite(p_html,"</td>\n");
                td_i++;
            end
            while( td_i != col );
            $fwrite(p_html,"    </tr>\n");
            tr_i++;
            td_i = 0;
        end
        while( tr_i != row );

        $fwrite(p_html,"</table>\n");

    endtask : print_html_table

endmodule : nf_tb
