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
    input   logic   [0  : 0]  hclk,         // hclock
    input   logic   [0  : 0]  hresetn,      // hresetn
    // AHB UART slave side
    input   logic   [31 : 0]  haddr_s,      // AHB - UART-slave HADDR
    input   logic   [31 : 0]  hwdata_s,     // AHB - UART-slave HWDATA
    output  logic   [31 : 0]  hrdata_s,     // AHB - UART-slave HRDATA
    input   logic   [0  : 0]  hwrite_s,     // AHB - UART-slave HWRITE
    input   logic   [1  : 0]  htrans_s,     // AHB - UART-slave HTRANS
    input   logic   [2  : 0]  hsize_s,      // AHB - UART-slave HSIZE
    input   logic   [2  : 0]  hburst_s,     // AHB - UART-slave HBURST
    output  logic   [1  : 0]  hresp_s,      // AHB - UART-slave HRESP
    output  logic   [0  : 0]  hready_s,     // AHB - UART-slave HREADYOUT
    input   logic   [0  : 0]  hsel_s,       // AHB - UART-slave HSEL
    // UART side
    output  logic   [0  : 0]  uart_tx,      // UART tx wire
    input   logic   [0  : 0]  uart_rx       // UART rx wire
);

    logic   [0  : 0]    uart_request;   // uart request
    logic   [0  : 0]    uart_wrequest;  // uart write request
    logic   [31 : 0]    uart_addr;      // uart address
    logic   [0  : 0]    uart_we;        // uart write enable

    logic   [31 : 0]    addr;           // address for uart module
    logic   [31 : 0]    rd;             // read data from uart module
    logic   [31 : 0]    wd;             // write data for uart module
    logic   [0  : 0]    we;             // write enable for uart module

    assign addr     = uart_addr;
    assign we       = uart_we;
    assign wd       = hwdata_s;
    assign hrdata_s = rd;
    assign hresp_s  = `AHB_HRESP_OKAY;
    assign uart_request  = hsel_s && ( htrans_s != `AHB_HTRANS_IDLE );
    assign uart_wrequest = uart_request && hwrite_s;
    // creating control and address registers
    nf_register_we  #( 32 ) uart_addr_ff    ( hclk, hresetn, uart_request, haddr_s, uart_addr );
    nf_register     #( 1  ) uart_wreq_ff    ( hclk, hresetn, uart_wrequest, uart_we  );
    nf_register     #( 1  ) hready_ff       ( hclk, hresetn, uart_request , hready_s );
    // creating one uart top module
    nf_uart_top 
    nf_uart_top_0
    (
        // reset and clock
        .clk        ( hclk      ),  // clk
        .resetn     ( hresetn   ),  // resetn
        // bus side
        .addr       ( addr      ),  // address
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        ),  // read data
        // UART side
        .uart_tx    ( uart_tx   ),  // UART tx wire
        .uart_rx    ( uart_rx   )   // UART rx wire
    );
    
endmodule : nf_ahb_uart
