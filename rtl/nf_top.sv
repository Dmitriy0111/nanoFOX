/*
*  File            :   nf_top.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.27
*  Language        :   SystemVerilog
*  Description     :   This is top unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_top
(
    input   logic   [0  : 0]    clk,        // clock
    input   logic   [0  : 0]    resetn,     // reset
    input   logic   [25 : 0]    div,        // clock divide input
    input   logic   [4  : 0]    reg_addr,   // scan register address
    output  logic   [31 : 0]    reg_data    // scan register data
);

    logic   [31 : 0]    instr_addr;
    logic   [31 : 0]    instr;
    logic   [0  : 0]    cpu_en;

    nf_cpu nf_cpu_0
    (
        .clk            ( clk               ),  // clock
        .resetn         ( resetn            ),  // reset
        .instr_addr     ( instr_addr        ),  // cpu enable signal
        .instr          ( instr             ),  // instruction address
        .cpu_en         ( cpu_en            ),  // instruction data
        .reg_addr       ( reg_addr          ),  // register address
        .reg_data       ( reg_data          )   // register data
    );

    // creating instruction memory 
    nf_instr_mem 
    #( 
        .depth          ( 64                ) 
    )
    instr_mem_0
    (
        .addr           ( instr_addr >> 2   ),  // instruction address
        .instr          ( instr             )   // instruction data
    );

    // creating strob generating unit for "dividing" clock
    nf_clock_div nf_clock_div_0
    (
        .clk            ( clk               ),  // clock
        .resetn         ( resetn            ),  // reset
        .div            ( div               ),  // div_number
        .en             ( cpu_en            )   // enable strobe
    );

endmodule : nf_top
