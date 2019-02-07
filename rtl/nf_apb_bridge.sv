/*
*  File            :   nf_apb_bridge.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.07
*  Language        :   SystemVerilog
*  Description     :   This is APB bridge module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_apb_bridge
#(
    parameter                                   slave_c = `SLAVE_COUNT
)(
    input   logic                               pclk,
    input   logic                               presetn,
    // APB slaves side
    output  logic   [slave_c-1 : 0][31 : 0]     paddr_s,        // APB - Slave PADDR 
    output  logic   [slave_c-1 : 0][31 : 0]     pwdata_s,       // APB - Slave PWDATA 
    input   logic   [slave_c-1 : 0][31 : 0]     prdata_s,       // APB - Slave PRDATA 
    output  logic   [slave_c-1 : 0][0  : 0]     pwrite_s,       // APB - Slave PWRITE 
    output  logic   [slave_c-1 : 0][0  : 0]     penable_s,      // APB - Slave PENABLE
    output  logic   [slave_c-1 : 0]             psel_s          // APB - Slave PSEL
);

endmodule : nf_apb_bridge
