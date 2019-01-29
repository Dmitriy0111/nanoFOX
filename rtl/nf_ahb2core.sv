/*
*  File            :   nf_ahb2core.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.29
*  Language        :   SystemVerilog
*  Description     :   This is AHB <-> core bridge
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_ahb2core
(
    input   logic               clk,
    input   logic               resetn,
    // AHB side
    output  logic   [31 : 0]    haddr,      // AHB HADDR
    output  logic   [31 : 0]    hwdata,     // AHB HWDATA
    input   logic   [31 : 0]    hrdata,     // AHB HRDATA
    output  logic   [0  : 0]    hwrite,     // AHB HWRITE
    output  logic   [1  : 0]    htrans,     // AHB HTRANS
    output  logic   [2  : 0]    hsize,      // AHB HSIZE
    output  logic   [2  : 0]    hburst,     // AHB HBURST
    input   logic   [1  : 0]    hresp,      // AHB HRESP
    input   logic   [0  : 0]    hready,     // AHB HREADY
    // core side
    input   logic   [31 : 0]    addr_dm,    // address data memory
    input   logic   [31 : 0]    wd_dm,      // write data memory
    output  logic   [31 : 0]    rd_dm,      // read data memory
    input   logic   [0  : 0]    we_dm,      // write enable signal
    input   logic   [0  : 0]    req_dm,     // request data memory signal
    output  logic   [0  : 0]    req_ack_dm  // request acknowledge data memory signal
);

    assign  haddr  = addr_dm;
    assign  hwrite = we_dm;
    assign  rd_dm  = hrdata;

    // creating one write data flip-flop
    nf_register_we  #( 32 ) wd_dm_ff    ( clk, resetn, we_dm, wd_dm, hwdata );

endmodule : nf_ahb2core
