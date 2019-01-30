/*
*  File            :   nf_ahb_gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.30
*  Language        :   SystemVerilog
*  Description     :   This is AHB GPIO module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`include "../inc/nf_ahb.svh"

module nf_ahb_gpio
#(
    parameter                           gpio_w = `NF_GPIO_WIDTH
)(
    input   logic                       hclk,
    input   logic                       hresetn,
    // Slaves side
    input   logic   [31       : 0]      haddr_s,    // AHB - Slave HADDR
    input   logic   [31       : 0]      hwdata_s,   // AHB - Slave HWDATA
    output  logic   [31       : 0]      hrdata_s,   // AHB - Slave HRDATA
    input   logic   [0        : 0]      hwrite_s,   // AHB - Slave HWRITE
    input   logic   [1        : 0]      htrans_s,   // AHB - Slave HTRANS
    input   logic   [2        : 0]      hsize_s,    // AHB - Slave HSIZE
    input   logic   [2        : 0]      hburst_s,   // AHB - Slave HBURST
    output  logic   [1        : 0]      hresp_s,    // AHB - Slave HRESP
    output  logic   [0        : 0]      hready_s,   // AHB - Slave HREADYOUT
    input   logic   [0        : 0]      hsel_s,     // AHB - Slave HBURST
    //gpio_side
    input   logic   [gpio_w-1 : 0]      gpi,        // GPIO input
    output  logic   [gpio_w-1 : 0]      gpo,        // GPIO output
    output  logic   [gpio_w-1 : 0]      gpd         // GPIO direction
);

    logic               gpio_request;
    logic               gpio_wrequest;
    logic   [31 : 0]    gpio_work_addr;

    assign  gpio_request  = hsel_s && ( htrans_s != `AHB_HTRANS_IDLE);

    nf_register_we #( 32 ) gpio_waddr_ff   ( hclk, hresetn, gpio_request, haddr_s, gpio_work_addr );
    nf_register    #(  1 ) gpio_wreq_ff    ( hclk, hresetn, gpio_request && hwrite_s, gpio_wrequest );
    nf_register    #(  1 ) hready_ff       ( hclk, hresetn, gpio_request, hready_s );

    logic   [31 : 0]    gpio_addr;
    logic   [31 : 0]    gpio_rd;
    logic   [31 : 0]    gpio_wd;
    logic   [0  : 0]    gpio_we;

    assign  gpio_addr = gpio_work_addr;
    assign  gpio_we   = gpio_wrequest;
    assign  gpio_wd   = hwdata_s;
    assign  hrdata_s  = gpio_rd;

    assign  hresp_s   = `AHB_HRESP_OKAY;

    nf_gpio
    #(
        .gpio_w     ( gpio_w            )
    )
    nf_gpio_0
    (
        .clk        ( hclk              ),
        .resetn     ( hresetn           ),
        // bus side
        .addr       ( gpio_addr         ),  // address
        .we         ( gpio_we           ),  // write enable
        .wd         ( gpio_wd           ),  // write data
        .rd         ( gpio_rd           ),  // read data
        // GPIO side
        .gpi        ( gpi               ),  // GPIO input
        .gpo        ( gpo               ),  // GPIO output
        .gpd        ( gpd               )   // GPIO direction
    );
    
endmodule : nf_ahb_gpio
