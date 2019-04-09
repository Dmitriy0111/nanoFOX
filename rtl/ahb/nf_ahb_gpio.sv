/*
*  File            :   nf_ahb_gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.30
*  Language        :   SystemVerilog
*  Description     :   This is AHB GPIO module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"
`include "../../inc/nf_ahb.svh"

module nf_ahb_gpio
#(
    parameter                       gpio_w = `NF_GPIO_WIDTH
)(
    // clock and reset
    input   logic   [0        : 0]  hclk,       // hclock
    input   logic   [0        : 0]  hresetn,    // hresetn
    // AHB GPIO slave side
    input   logic   [31       : 0]  haddr_s,    // AHB - GPIO-slave HADDR
    input   logic   [31       : 0]  hwdata_s,   // AHB - GPIO-slave HWDATA
    output  logic   [31       : 0]  hrdata_s,   // AHB - GPIO-slave HRDATA
    input   logic   [0        : 0]  hwrite_s,   // AHB - GPIO-slave HWRITE
    input   logic   [1        : 0]  htrans_s,   // AHB - GPIO-slave HTRANS
    input   logic   [2        : 0]  hsize_s,    // AHB - GPIO-slave HSIZE
    input   logic   [2        : 0]  hburst_s,   // AHB - GPIO-slave HBURST
    output  logic   [1        : 0]  hresp_s,    // AHB - GPIO-slave HRESP
    output  logic   [0        : 0]  hready_s,   // AHB - GPIO-slave HREADYOUT
    input   logic   [0        : 0]  hsel_s,     // AHB - GPIO-slave HSEL
    // GPIO side
    input   logic   [gpio_w-1 : 0]  gpi,        // GPIO input
    output  logic   [gpio_w-1 : 0]  gpo,        // GPIO output
    output  logic   [gpio_w-1 : 0]  gpd         // GPIO direction
);

    logic   [0  : 0]    gpio_request;   // gpio request
    logic   [0  : 0]    gpio_wrequest;  // gpio write request
    logic   [31 : 0]    gpio_addr;      // gpio address
    logic   [0  : 0]    gpio_we;        // gpio write enable

    logic   [31 : 0]    addr;           // address for gpio module
    logic   [31 : 0]    rd;             // read data from gpio module
    logic   [31 : 0]    wd;             // write data for gpio module
    logic   [0  : 0]    we;             // write enable for gpio module

    assign addr     = gpio_addr;
    assign we       = gpio_we;
    assign wd       = hwdata_s;
    assign hrdata_s = rd;
    assign hresp_s  = `AHB_HRESP_OKAY;
    assign gpio_request  = hsel_s && ( htrans_s != `AHB_HTRANS_IDLE );
    assign gpio_wrequest = gpio_request && hwrite_s;
    // creating control and address registers
    nf_register_we  #( 32 ) gpio_addr_ff    ( hclk, hresetn, gpio_request , haddr_s, gpio_addr );
    nf_register     #( 1  ) gpio_wreq_ff    ( hclk, hresetn, gpio_wrequest, gpio_we  );
    nf_register     #( 1  ) hready_ff       ( hclk, hresetn, gpio_request , hready_s );
    // creating one nf_gpio unit
    nf_gpio
    #(
        .gpio_w     ( gpio_w            )
    )
    nf_gpio_0
    (
        // reset and clock
        .clk        ( hclk      ),  // clk
        .resetn     ( hresetn   ),  // resetn
        // bus side
        .addr       ( addr      ),  // address
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        ),  // read data
        // GPIO side
        .gpi        ( gpi       ),  // GPIO input
        .gpo        ( gpo       ),  // GPIO output
        .gpd        ( gpd       )   // GPIO direction
    );
    
endmodule : nf_ahb_gpio
