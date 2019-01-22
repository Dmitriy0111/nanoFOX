/*
*  File            :   nf_top.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.27
*  Language        :   SystemVerilog
*  Description     :   This is top unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_top
(
    input   logic                           clk,
    input   logic                           resetn
`ifdef debug
    ,
    input   logic   [4  : 0]                reg_addr,
    output  logic   [31 : 0]                reg_data
`endif
);
    //instruction memory
    logic   [31 : 0]    addr_i;     // instruction address
    logic   [31 : 0]    rd_i;       // read instruction
    //data memory and others's
    logic   [31 : 0]    addr_dm;    // address data memory
    logic   [0  : 0]    we_dm;      // write enable signal
    logic   [31 : 0]    wd_dm;      // write data memory
    logic   [31 : 0]    rd_dm;      // read data memory
    logic   [0  : 0]    req_dm;     // request data memory signal
    logic   [0  : 0]    req_ack_dm; // request acknowledge data memory signal
    assign              req_ack_dm = '1;
    //creating one cpu unit
    nf_cpu nf_cpu_0
    (
        .clk        ( clk               ),
        .resetn     ( resetn            ),
        .addr_i     ( addr_i            ),  // instruction address
        .rd_i       ( rd_i              ),  // read instruction
        .addr_dm    ( addr_dm           ),  // address data memory
        .we_dm      ( we_dm             ),  // write enable signal
        .wd_dm      ( wd_dm             ),  // write data memory
        .rd_dm      ( rd_dm             ),  // read data memory
        .req_dm     ( req_dm            ),  // request data memory signal
        .req_ack_dm ( req_ack_dm        )   // request acknowledge data memory signal
    `ifdef debug
        ,
        .reg_addr   ( reg_addr          ),  // register address
        .reg_data   ( reg_data          )   // register data
    `endif
    );
    //creating one instruction/data memory
    nf_dp_ram
    #(
        .depth      ( 256               ) 
    )
    nf_dp_ram_0
    (
        .clk        ( clk               ),
        // Port 1
        .addr_p1    ( addr_i >> 2       ),  // Port-1 addr
        .we_p1      ( '0                ),  // Port-1 write enable
        .wd_p1      ( '0                ),  // Port-1 write data
        .rd_p1      ( rd_i              ),  // Port-1 read data
        // Port 2
        .addr_p2    ( addr_dm >> 2      ),  // Port-2 addr
        .we_p2      ( we_dm             ),  // Port-2 write enable
        .wd_p2      ( wd_dm             ),  // Port-2 write data
        .rd_p2      ( rd_dm             )   // Port-2 read data
    );

endmodule : nf_top
