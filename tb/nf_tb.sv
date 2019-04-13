/*
*  File            :   nf_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is testbench for cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`include "../tb/nf_pars_instr.sv"
`include "../tb/nf_log_writer.sv"
`include "../tb/nf_tb.svh"

module nf_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 20,                 // 50 MHz
                        resetn_delay = 7,
                        repeat_cycles = 200,
                        work_freq  = 50_000_000,
                        uart_speed = 115200,
                        uart_rec_example = 0;
    
    // clock and reset
    bit     [0  : 0]    clk;            // clock
    bit     [0  : 0]    resetn;         // reset
    // peryphery inputs/outputs
    logic   [7  : 0]    gpio_i_0;       // GPIO_0 input
    logic   [7  : 0]    gpio_o_0;       // GPIO_0 output
    logic   [7  : 0]    gpio_d_0;       // GPIO_0 direction
    logic   [0  : 0]    pwm;            // PWM output signal
    logic   [0  : 0]    uart_tx;        // UART tx wire
    logic   [0  : 0]    uart_rx;        // UART rx wire
    // help variables
    bit     [31 : 0]    cycle_counter;  // variable for cpu cycle
    // instructions
    string  instruction_if_stage;
    string  instruction_id_stage;
    string  instruction_iexe_stage;
    string  instruction_imem_stage;
    string  instruction_iwb_stage;
    // string for debug_lev0
    string  instr_sep_s_if_stage;
    string  instr_sep_s_id_stage;
    string  instr_sep_s_iexe_stage;
    string  instr_sep_s_imem_stage;
    string  instr_sep_s_iwb_stage;
    // string for txt, html and terminal logging
    string  log_str = "";

    assign  gpio_i_0 = 8'b1;

    nf_top 
    nf_top_0
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
    nf_top 
    nf_top_0
    (
        .*
    );
    */
    // overload path to program file
    defparam nf_top_0.nf_ram_i_d_0.path2file = "../program_file/program";
    initial
    begin
        uart_rx = '1;
        if( uart_rec_example )
        begin
            @(posedge resetn);
            repeat(200) @(posedge clk);
            send_uart_message( "Hello World!" , 100);
        end
    end
    // reset all registers to '0
    initial
        for( int i=0 ; i<32 ; i++ )
        begin
            nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[i] = '0;
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
    nf_pars_instr nf_pars_instr_0 = new();
    nf_log_writer nf_log_writer_0 = new();
    // parsing instruction
    initial
    begin
        nf_log_writer_0.build("../log/log");
        
        forever
        begin
            @( posedge nf_top_0.clk );
            if( resetn )
            begin
                if( `log_en )
                begin
                    #1ns;   // for current instructions
                    nf_pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_if   , instruction_if_stage   , instr_sep_s_if_stage   );
                    nf_pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_id   , instruction_id_stage   , instr_sep_s_id_stage   );
                    nf_pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_iexe , instruction_iexe_stage , instr_sep_s_iexe_stage );
                    nf_pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_imem , instruction_imem_stage , instr_sep_s_imem_stage );
                    nf_pars_instr_0.pars( nf_top_0.nf_cpu_0.instr_iwb  , instruction_iwb_stage  , instr_sep_s_iwb_stage  );
                    // form title
                    log_str = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";
                    log_str = { log_str , $psprintf("cycle = %d, pc = 0x%h ", cycle_counter, nf_top_0.nf_cpu_0.addr_i     ) };
                    log_str = { log_str , $psprintf("%t\n", $time                                                         ) };
                    // form instruction fetch stage output
                    log_str = { log_str , "Instruction decode stage        : "                                              };
                    log_str = { log_str , $psprintf("%s\n", instruction_if_stage                                          ) };
                    if( `debug_lev0 ) 
                        log_str = { log_str , $psprintf("                                  %s \n", instr_sep_s_if_stage   ) };
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
                    // write debug info in log file
                    nf_log_writer_0.write_log(nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file, log_str);
                end
                // increment cycle counter
                cycle_counter++;
                if( cycle_counter == repeat_cycles )
                    $stop;
            end
        end
    end

    // task for sending symbol over uart to receive module
    task send_uart_symbol( logic [7 : 0] symbol );
        // generate 'start'
        uart_rx = '0;
        repeat( work_freq / uart_speed ) @(posedge clk);
        // generate transaction
        for( integer i = 0 ; i < 8 ; i ++ )
        begin
            uart_rx = symbol[i];
            repeat( work_freq / uart_speed ) @(posedge clk);
        end
        // generate 'stop'
        uart_rx = '1;
        repeat( work_freq / uart_speed ) @(posedge clk);
    endtask : send_uart_symbol
    // task for sending message over uart to receive module
    task send_uart_message( string message , integer delay_v);
        for( int i=0; i<message.len(); i++ )
        begin
            send_uart_symbol(message[i]);
            #delay_v;
        end
    endtask : send_uart_message

endmodule : nf_tb
