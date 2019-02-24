/*
*  File            :   nf_ahb_uart.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.24
*  Language        :   SystemVerilog
*  Description     :   This is AHB UART module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"
`include "../../inc/nf_ahb.svh"

module nf_ahb_uart
(
    // clock and reset
    input   logic   [0        : 0]  hclk,       // hclock
    input   logic   [0        : 0]  hresetn,    // hresetn
    // AHB UART slave side
    input   logic   [31       : 0]  haddr_s,    // AHB - UART-slave HADDR
    input   logic   [31       : 0]  hwdata_s,   // AHB - UART-slave HWDATA
    output  logic   [31       : 0]  hrdata_s,   // AHB - UART-slave HRDATA
    input   logic   [0        : 0]  hwrite_s,   // AHB - UART-slave HWRITE
    input   logic   [1        : 0]  htrans_s,   // AHB - UART-slave HTRANS
    input   logic   [2        : 0]  hsize_s,    // AHB - UART-slave HSIZE
    input   logic   [2        : 0]  hburst_s,   // AHB - UART-slave HBURST
    output  logic   [1        : 0]  hresp_s,    // AHB - UART-slave HRESP
    output  logic   [0        : 0]  hready_s,   // AHB - UART-slave HREADYOUT
    input   logic   [0        : 0]  hsel_s,     // AHB - UART-slave HSEL
    // UART side
    output  logic   [0        : 0]  uart_tx,    // UART tx wire
    input   logic   [0        : 0]  uart_rx     // UART rx wire
);

    logic               uart_request;
    logic               uart_wrequest;
    logic   [31 : 0]    uart_work_addr;

    assign  uart_request  = hsel_s && ( htrans_s != `AHB_HTRANS_IDLE );

    nf_register_we #( 32 ) uart_waddr_ff   ( hclk, hresetn, uart_request, haddr_s, uart_work_addr );
    nf_register    #( 1  ) uart_wreq_ff    ( hclk, hresetn, uart_request && hwrite_s, uart_wrequest );
    nf_register    #( 1  ) hready_ff       ( hclk, hresetn, uart_request, hready_s );

    logic   [31 : 0]    uart_addr;
    logic   [31 : 0]    uart_rd;
    logic   [31 : 0]    uart_wd;
    logic   [0  : 0]    uart_we;

    assign  uart_addr = uart_work_addr;
    assign  uart_we   = uart_wrequest;
    assign  uart_wd   = hwdata_s;
    assign  hrdata_s  = uart_rd;

    assign  hresp_s   = `AHB_HRESP_OKAY;

    nf_uart_top nf_uart_top_0
    (
        // reset and clock
        .clk        ( hclk      ),  // clk
        .resetn     ( hresetn   ),  // resetn
        // bus side
        .addr       ( uart_addr ),  // address
        .we         ( uart_we   ),  // write enable
        .wd         ( uart_wd   ),  // write data
        .rd         ( uart_rd   ),  // read data
        // UART side
        .uart_tx    ( uart_tx   ),  // UART tx wire
        .uart_rx    ( uart_rx   )   // UART rx wire
    );
    
endmodule : nf_ahb_uart
