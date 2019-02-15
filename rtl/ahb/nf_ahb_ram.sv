/*
*  File            :   nf_ahb_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.30
*  Language        :   SystemVerilog
*  Description     :   This is AHB RAM module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

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
    input   logic   [0  : 0]    hsel_s      // AHB - RAM-slave HSEL
);

endmodule : nf_ahb_ram
