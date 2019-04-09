/*
*  File            :   nf_ahb2core.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.29
*  Language        :   SystemVerilog
*  Description     :   This is AHB <-> core bridge
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_ahb.svh"

module nf_ahb2core
(
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    resetn,     // resetn
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
    input   logic   [31 : 0]    addr,       // address memory
    input   logic   [31 : 0]    wd,         // write memory
    output  logic   [31 : 0]    rd,         // read memory
    input   logic   [0  : 0]    we,         // write enable signal
    input   logic   [1  : 0]    size,       // size for load/store instructions
    input   logic   [0  : 0]    req,        // request memory signal
    output  logic   [0  : 0]    req_ack     // request acknowledge memory signal
);

    assign haddr   = addr;
    assign hwrite  = we;
    assign rd      = hrdata;
    assign htrans  = req ? `AHB_HTRANS_NONSEQ : `AHB_HTRANS_IDLE;
    assign hsize   = { 1'b0 , size };
    assign hburst  = `AHB_HBUSRT_SINGLE;
    assign req_ack = hready && ( hresp != `AHB_HRESP_ERROR );

    // creating one write data flip-flop
    nf_register_we  #( 32 ) wd_dm_ff    ( clk, resetn, we, wd, hwdata );

endmodule : nf_ahb2core
