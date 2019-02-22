/*
*  File            :   nf_apb_bridge.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.07
*  Language        :   SystemVerilog
*  Description     :   This is APB bridge module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`define  P_SLAVE_COUNT 3

module nf_apb_bridge
#(
    parameter                                   p_slave_c = `P_SLAVE_COUNT
)(
    // AHB clock and reset
    input   logic                    [0  : 0]   hclk,           // hclock
    input   logic                    [0  : 0]   hresetn,        // hresetn
    // AHB slave side
    input   logic                    [31 : 0]   haddr_s,        // AHB - Slave HADDR
    input   logic                    [31 : 0]   hwdata_s,       // AHB - Slave HWDATA
    output  logic                    [31 : 0]   hrdata_s,       // AHB - Slave HRDATA
    input   logic                    [0  : 0]   hwrite_s,       // AHB - Slave HWRITE
    input   logic                    [1  : 0]   htrans_s,       // AHB - Slave HTRANS
    input   logic                    [2  : 0]   hsize_s,        // AHB - Slave HSIZE
    input   logic                    [2  : 0]   hburst_s,       // AHB - Slave HBURST
    output  logic                    [1  : 0]   hresp_s,        // AHB - Slave HRESP
    output  logic                    [0  : 0]   hready_s,       // AHB - Slave HREADYOUT
    input   logic                    [0  : 0]   hsel_s,         // AHB - Slave HSEL
    // APB clock and reset
    input   logic                    [0  : 0]   pclk,           // pclock
    input   logic                    [0  : 0]   presetn,        // presetn
    // APB master side
    output  logic   [p_slave_c-1 : 0][31 : 0]   paddr_m,        // APB - Master PADDR 
    output  logic   [p_slave_c-1 : 0][31 : 0]   pwdata_m,       // APB - Master PWDATA 
    input   logic   [p_slave_c-1 : 0][31 : 0]   prdata_m,       // APB - Master PRDATA 
    output  logic   [p_slave_c-1 : 0][0  : 0]   pwrite_m,       // APB - Master PWRITE 
    output  logic   [p_slave_c-1 : 0][0  : 0]   penable_m,      // APB - Master PENABLE
    output  logic   [p_slave_c-1 : 0][0  : 0]   psel_m          // APB - Master PSEL
);

endmodule : nf_apb_bridge
