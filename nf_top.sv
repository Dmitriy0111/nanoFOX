/*
*  File            :   nf_top.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.27
*  Language        :   SystemVerilog
*  Description     :   This is top unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_top
(
    input   logic               clk,
    input   logic               resetn,
    input   logic   [25 : 0]    div
`ifdef debug
    ,
    input   logic   [4  : 0]    reg_addr,
    output  logic   [31 : 0]    reg_data
`endif
);
    //instruction memory
    logic   [31 : 0]    instr_addr;
    logic   [31 : 0]    instr;
    //data memory and others's
    logic   [31 : 0]    addr_dm;
    logic               we_dm;
    logic   [31 : 0]    wd_dm;
    logic   [31 : 0]    rd_dm;

    nf_cpu nf_cpu_0
    (
        .clk            ( clk               ),
        .resetn         ( resetn            ),
        .div            ( div               ),
        .instr_addr     ( instr_addr        ),
        .instr          ( instr             ),
        .addr_dm        ( addr_dm           ),
        .we_dm          ( we_dm             ),
        .wd_dm          ( wd_dm             ),
        .rd_dm          ( rd_dm             )
    `ifdef debug
        ,
        .reg_addr       ( reg_addr          ),
        .reg_data       ( reg_data          )
    `endif
    );

    //creating instruction memory 
    nf_instr_mem 
    #( 
        .depth          ( 64                ) 
    )
    instr_mem_0
    (
        .addr           ( instr_addr >> 2   ),
        .instr          ( instr             )
    );

    nf_ram
    #(
        .depth          ( 64                )
    )
    nf_ram_0
    (
        .clk            ( clk               ),
        .addr           ( addr_dm >> 2      ),
        .we             ( we_dm             ),
        .wd             ( wd_dm             ),
        .rd             ( rd_dm             )
    );

endmodule : nf_top
