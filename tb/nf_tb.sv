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
    logic               reg_list_changed [31 : 0];

    integer             log;
    integer             p_html;

    // instructions
    string  instruction_id_stage;
    string  instruction_iexe_stage;
    string  instruction_imem_stage;
    string  instruction_iwb_stage;

    string  instr_sep_s_id_stage;
    string  instr_sep_s_iexe_stage;
    string  instr_sep_s_imem_stage;
    string  instr_sep_s_iwb_stage;

    string  reg_list;

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

    defparam nf_top_0.nf_ram_i_d_0.path2file = "../program_file/program";

    // reset all register's in '0
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
                    $display("Error! File not open.");
                    $stop;
                end
        end
        if( `log_html )
            p_html = $fopen("../log/log.html","w");
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
                pars_reg_list();
                write_info_html();
                if( `log_html )
                    $fwrite(log,"register list :\n%s\n" , reg_list );
                cycle_counter++;
            end
            if( cycle_counter == repeat_cycles )
            begin
                $stop;
            end
        end
    end

    task pars_reg_list();

        automatic logic  [4  : 0] reg_addr  = '0;

        reg_list = "";
        do
        begin
            reg_list =  {    
                            reg_list , 
                            $psprintf( "%5s", pars_instr_0.reg_list[reg_addr] ) , 
                            $psprintf(" = 0x%h ", nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[reg_addr] ) , 
                            reg_addr[0 +: 2] == 3 ? "\n" : "" 
                        };
            reg_addr++;
        end
        while( reg_addr != '0 );

    endtask : pars_reg_list

    task write_info_html();

        integer tr_i;
        integer td_i;

        tr_i = 0;
        td_i = 0;
        $fwrite(p_html,"%s", "<font size = \"4\">");
        $fwrite(p_html,"<pre>");
        $fwrite(p_html,"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
        $fwrite(p_html,"cycle = %d, pc = 0x%h \n", cycle_counter, nf_top_0.nf_cpu_0.addr_i);
        $fwrite(p_html,"Instruction decode stage        : ");
        $fwrite(p_html,"%s\n", instruction_id_stage);
        if( `debug_lev0 )
            $fwrite(p_html,"                                  %s \n" , instr_sep_s_id_stage     );
        $fwrite(p_html,"Instruction execute stage       : ");
        $fwrite(p_html,"%s\n", instruction_iexe_stage);
        if( `debug_lev0 )
            $fwrite(p_html,"                                  %s \n" , instr_sep_s_iexe_stage   );
        $fwrite(p_html,"Instruction memory stage        : ");
        $fwrite(p_html,"%s\n", instruction_imem_stage);
        if( `debug_lev0 )
            $fwrite(p_html,"                                  %s \n" , instr_sep_s_imem_stage   );
        $fwrite(p_html,"Instruction write back stage    : ");
        $fwrite(p_html,"%s\n", instruction_iwb_stage);
        if( `debug_lev0 )
            $fwrite(p_html,"                                  %s \n" , instr_sep_s_iwb_stage    );
        $fwrite(p_html,"</pre>\n");
        $fwrite(p_html,"<table border=\"1\">\n");
        do
        begin
            $fwrite(p_html,"    <tr>\n");
            do
            begin
                reg_list_changed[ tr_i * 4 + td_i ] = reg_list_local[ tr_i * 4 + td_i ] == nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[tr_i * 4 + td_i];
                reg_list_local[ tr_i * 4 + td_i ]   = reg_list_local[ tr_i * 4 + td_i ] == nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[tr_i * 4 + td_i] ? 
                                                      reg_list_local[tr_i * 4 + td_i] : 
                                                      nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[tr_i * 4 + td_i];
                $fwrite(p_html,"        <td %s>", reg_list_changed[ tr_i * 4 + td_i ] ? "bgcolor = \"white\"":"bgcolor = \"green\"");
                $fwrite(p_html,"<pre>");
                //$fwrite(p_html,"%s", "<font size = \"4\">");
                $fwrite(p_html," %5s 0x%h ", pars_instr_0.reg_list[ tr_i * 4 + td_i ], reg_list_local[tr_i * 4 + td_i]);
                //$fwrite(p_html,"%s", "</font>" );
                $fwrite(p_html,"</pre>");
                $fwrite(p_html,"</td>\n");
                reg_list_changed[ tr_i * 4 + td_i ] = '0;
                td_i++;
            end
            while( td_i != 4);
            $fwrite(p_html,"    </tr>\n");
            tr_i++;
            td_i = 0;
        end
        while( tr_i != 8);
        $fwrite(p_html,"</table>\n");
        $fwrite(p_html,"%s", "</font>");

    endtask : write_info_html

endmodule : nf_tb
