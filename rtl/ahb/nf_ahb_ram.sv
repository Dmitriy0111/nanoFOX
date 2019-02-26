/*
*  File            :   nf_ahb_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.30
*  Language        :   SystemVerilog
*  Description     :   This is AHB RAM module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_ahb.svh"

module nf_ahb_ram
(
    // clock and reset
    input   logic   [0  : 0]    hclk,       // hclk
    input   logic   [0  : 0]    hresetn,    // hresetn
    // AHB RAM slave side
    input   logic   [31 : 0]    haddr_s,    // AHB - RAM-slave HADDR
    input   logic   [31 : 0]    hwdata_s,   // AHB - RAM-slave HWDATA
    output  logic   [31 : 0]    hrdata_s,   // AHB - RAM-slave HRDATA
    input   logic   [0  : 0]    hwrite_s,   // AHB - RAM-slave HWRITE
    input   logic   [1  : 0]    htrans_s,   // AHB - RAM-slave HTRANS
    input   logic   [2  : 0]    hsize_s,    // AHB - RAM-slave HSIZE
    input   logic   [2  : 0]    hburst_s,   // AHB - RAM-slave HBURST
    output  logic   [1  : 0]    hresp_s,    // AHB - RAM-slave HRESP
    output  logic   [0  : 0]    hready_s,   // AHB - RAM-slave HREADYOUT
    input   logic   [0  : 0]    hsel_s,     // AHB - RAM-slave HSEL
    // RAM side
    output  logic   [31 : 0]    ram_addr,   // addr memory
    output  logic   [31 : 0]    ram_wd,     // write data
    input   logic   [31 : 0]    ram_rd,     // read data
    output  logic   [0  : 0]    ram_we      // write enable
);

    logic   [0  : 0]    ram_request;
    logic   [0  : 0]    ram_wrequest;
    logic   [31 : 0]    ram_addr_;
    logic   [0  : 0]    ram_we_;

    assign  ram_request  = hsel_s && ( htrans_s != `AHB_HTRANS_IDLE);
    assign  ram_wrequest = ram_request && hwrite_s; 

    nf_register_we  #( 32 ) ram_addr_ff ( hclk, hresetn, ram_request , haddr_s, ram_addr_ );
    nf_register     #( 1  ) ram_wreq_ff ( hclk, hresetn, ram_wrequest, ram_we_  );
    nf_register     #( 1  ) hready_ff   ( hclk, hresetn, ram_request , hready_s );

    assign  ram_addr  = ram_addr_;
    assign  ram_we    = ram_we_;
    assign  ram_wd    = hwdata_s;
    assign  hrdata_s  = ram_rd;

    assign  hresp_s   = `AHB_HRESP_OKAY;

endmodule : nf_ahb_ram
