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
    // simulation settings
    timeprecision       1ns;
    timeunit            1ns;
    // simulation constants
    parameter           T = 20,                                 // 50 MHz (clock period)
                        resetn_delay = 7,                       // delay for reset signal (posedge clk)
                        repeat_cycles = 200,                    // number of repeat cycles before stop
                        work_freq  = 50_000_000,                // core work frequency
                        uart_speed = 115200,                    // setting uart speed
                        uart_rec_example = 0,                   // for working with uart receive example
                        stop_loop = 1,                          // stop with loop 0000_006f
                        stop_cycle = 0,                         // stop with cycle variable
                        path2file = "../program_file/program";  // path to program file
    
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
    bit     [31 : 0]    loop_c;         
    // instructions
    string  instruction_if_stage;       // instruction fetch stage string
    string  instruction_id_stage;       // instruction decode stage string
    string  instruction_iexe_stage;     // instruction execution stage string
    string  instruction_imem_stage;     // instruction memory stage string
    string  instruction_iwb_stage;      // instruction write back stage string
    // string for debug_lev0
    string  instr_sep_s_if_stage;       // instruction fetch stage string (debug level 0)
    string  instr_sep_s_id_stage;       // instruction decode stage string (debug level 0)
    string  instr_sep_s_iexe_stage;     // instruction execution stage string (debug level 0)
    string  instr_sep_s_imem_stage;     // instruction memory stage string (debug level 0)
    string  instr_sep_s_iwb_stage;      // instruction write back stage string (debug level 0)
    // string for txt, html and terminal logging
    string  log_str = "";  

    `define nf_top  nf_top_ahb             

    `nf_top 
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
    `nf_top
    nf_top_0
    (
        .*
    );
    */
    // overload path to program file
    defparam nf_top_0.nf_ram_i_d_0.path2file = path2file;
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
    // reset zero register to '0
    initial
        nf_top_0.nf_cpu_0.nf_reg_file_0.reg_file[0] = '0;
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
        // set gpio input value
        gpio_i_0 = 8'b1;
        // build log wtiter
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
                    log_str = { log_str , "Instruction fetch stage         : "                                              };
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
                if( ( nf_top_0.nf_cpu_0.instr_id == 32'h0000006f ) && stop_loop )
                    loop_c++;
                if( loop_c == 3 )
                    $stop;
                if( ( cycle_counter == repeat_cycles ) && stop_cycle )
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
        for( integer i = 0 ; i < 8 ; i++ )
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
        for( int i = 0 ; i < message.len() ; i++ )
        begin
            send_uart_symbol(message[i]);
            #delay_v;
        end
    endtask : send_uart_message

    `ifdef cov_en
    // creating coverpoint
    covergroup instr_cov @(posedge clk);

        instr_p : coverpoint { nf_top_0.nf_cpu_0.instr_iwb[31 : 25] , nf_top_0.nf_cpu_0.instr_iwb[14 : 12] , nf_top_0.nf_cpu_0.instr_iwb[6 : 0] , nf_top_0.nf_cpu_0.stall_iwb } iff ( resetn )
        {
            wildcard bins lui_p    = { { LUI.F7    , LUI.F3    , LUI.OP    , LUI.IT     , 1'b0 } }; // LUI command
            wildcard bins auipc_p  = { { AUIPC.F7  , AUIPC.F3  , AUIPC.OP  , AUIPC.IT   , 1'b0 } }; // AUIPC command
            wildcard bins jal_p    = { { JAL.F7    , JAL.F3    , JAL.OP    , JAL.IT     , 1'b0 } }; // JAL command
            wildcard bins jalr_p   = { { JALR.F7   , JALR.F3   , JALR.OP   , JALR.IT    , 1'b0 } }; // JALR command
            wildcard bins beq_p    = { { BEQ.F7    , BEQ.F3    , BEQ.OP    , BEQ.IT     , 1'b0 } }; // BEQ command
            wildcard bins bne_p    = { { BNE.F7    , BNE.F3    , BNE.OP    , BNE.IT     , 1'b0 } }; // BNE command
            wildcard bins blt_p    = { { BLT.F7    , BLT.F3    , BLT.OP    , BLT.IT     , 1'b0 } }; // BLT command
            wildcard bins bge_p    = { { BGE.F7    , BGE.F3    , BGE.OP    , BGE.IT     , 1'b0 } }; // BGE command
            wildcard bins bltu_p   = { { BLTU.F7   , BLTU.F3   , BLTU.OP   , BLTU.IT    , 1'b0 } }; // BLTU command
            wildcard bins bgeu_p   = { { BGEU.F7   , BGEU.F3   , BGEU.OP   , BGEU.IT    , 1'b0 } }; // BGEU command
            wildcard bins lb_p     = { { LB.F7     , LB.F3     , LB.OP     , LB.IT      , 1'b0 } }; // LB command
            wildcard bins lh_p     = { { LH.F7     , LH.F3     , LH.OP     , LH.IT      , 1'b0 } }; // LH command
            wildcard bins lw_p     = { { LW.F7     , LW.F3     , LW.OP     , LW.IT      , 1'b0 } }; // LW command
            wildcard bins lbu_p    = { { LBU.F7    , LBU.F3    , LBU.OP    , LBU.IT     , 1'b0 } }; // LBU command
            wildcard bins lhu_p    = { { LHU.F7    , LHU.F3    , LHU.OP    , LHU.IT     , 1'b0 } }; // LHU command
            wildcard bins sb_p     = { { SB.F7     , SB.F3     , SB.OP     , SB.IT      , 1'b0 } }; // SB command
            wildcard bins sh_p     = { { SH.F7     , SH.F3     , SH.OP     , SH.IT      , 1'b0 } }; // SH command
            wildcard bins sw_p     = { { SW.F7     , SW.F3     , SW.OP     , SW.IT      , 1'b0 } }; // SW command
            wildcard bins addi_p   = { { ADDI.F7   , ADDI.F3   , ADDI.OP   , ADDI.IT    , 1'b0 } }; // ADDI command
            wildcard bins slti_p   = { { SLTI.F7   , SLTI.F3   , SLTI.OP   , SLTI.IT    , 1'b0 } }; // SLTI command
            wildcard bins sltiu_p  = { { SLTIU.F7  , SLTIU.F3  , SLTIU.OP  , SLTIU.IT   , 1'b0 } }; // SLTIU command
            wildcard bins xori_p   = { { XORI.F7   , XORI.F3   , XORI.OP   , XORI.IT    , 1'b0 } }; // XORI command
            wildcard bins ori_p    = { { ORI.F7    , ORI.F3    , ORI.OP    , ORI.IT     , 1'b0 } }; // ORI command
            wildcard bins andi_p   = { { ANDI.F7   , ANDI.F3   , ANDI.OP   , ANDI.IT    , 1'b0 } }; // ANDI command
            wildcard bins slli_p   = { { SLLI.F7   , SLLI.F3   , SLLI.OP   , SLLI.IT    , 1'b0 } }; // SLLI command
            wildcard bins srli_p   = { { SRLI.F7   , SRLI.F3   , SRLI.OP   , SRLI.IT    , 1'b0 } }; // SRLI command
            wildcard bins srai_p   = { { SRAI.F7   , SRAI.F3   , SRAI.OP   , SRAI.IT    , 1'b0 } }; // SRAI command
            wildcard bins add_p    = { { ADD.F7    , ADD.F3    , ADD.OP    , ADD.IT     , 1'b0 } }; // ADD command
            wildcard bins sub_p    = { { SUB.F7    , SUB.F3    , SUB.OP    , SUB.IT     , 1'b0 } }; // SUB command
            wildcard bins sll_p    = { { SLL.F7    , SLL.F3    , SLL.OP    , SLL.IT     , 1'b0 } }; // SLL command
            wildcard bins slt_p    = { { SLT.F7    , SLT.F3    , SLT.OP    , SLT.IT     , 1'b0 } }; // SLT command
            wildcard bins sltu_p   = { { SLTU.F7   , SLTU.F3   , SLTU.OP   , SLTU.IT    , 1'b0 } }; // SLTU command
            wildcard bins xor_p    = { { XOR.F7    , XOR.F3    , XOR.OP    , XOR.IT     , 1'b0 } }; // XOR command
            wildcard bins srl_p    = { { SRL.F7    , SRL.F3    , SRL.OP    , SRL.IT     , 1'b0 } }; // SRL command
            wildcard bins sra_p    = { { SRA.F7    , SRA.F3    , SRA.OP    , SRA.IT     , 1'b0 } }; // SRA command
            wildcard bins or_p     = { { OR.F7     , OR.F3     , OR.OP     , OR.IT      , 1'b0 } }; // OR command
            wildcard bins and_p    = { { AND.F7    , AND.F3    , AND.OP    , AND.IT     , 1'b0 } }; // AND command
            wildcard bins csrrw_p  = { { CSRRW.F7  , CSRRW.F3  , CSRRW.OP  , CSRRW.IT   , 1'b0 } }; // CSRRW command
            wildcard bins csrrs_p  = { { CSRRS.F7  , CSRRS.F3  , CSRRS.OP  , CSRRS.IT   , 1'b0 } }; // CSRRS command
            wildcard bins csrrc_p  = { { CSRRC.F7  , CSRRC.F3  , CSRRC.OP  , CSRRC.IT   , 1'b0 } }; // CSRRC command
            wildcard bins csrrwi_p = { { CSRRWI.F7 , CSRRWI.F3 , CSRRWI.OP , CSRRWI.IT  , 1'b0 } }; // CSRRWI command
            wildcard bins csrrsi_p = { { CSRRSI.F7 , CSRRSI.F3 , CSRRSI.OP , CSRRSI.IT  , 1'b0 } }; // CSRRSI command
            wildcard bins csrrci_p = { { CSRRCI.F7 , CSRRCI.F3 , CSRRCI.OP , CSRRCI.IT  , 1'b0 } }; // CSRRCI command
        }

    endgroup

    instr_cov i_c = new;

    `endif

endmodule : nf_tb
