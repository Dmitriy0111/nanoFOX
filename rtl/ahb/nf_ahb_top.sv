/*
*  File            :   nf_ahb_top.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.29
*  Language        :   SystemVerilog
*  Description     :   This is AHB top module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"

module nf_ahb_top
#(
    parameter                                   slave_c = `SLAVE_COUNT
)(
    input   logic                  [0  : 0]     clk,            // clk
    input   logic                  [0  : 0]     resetn,         // resetn
    // AHB slaves side
    output  logic   [slave_c-1 : 0][31 : 0]     haddr_s,        // AHB - Slave HADDR 
    output  logic   [slave_c-1 : 0][31 : 0]     hwdata_s,       // AHB - Slave HWDATA 
    input   logic   [slave_c-1 : 0][31 : 0]     hrdata_s,       // AHB - Slave HRDATA 
    output  logic   [slave_c-1 : 0][0  : 0]     hwrite_s,       // AHB - Slave HWRITE 
    output  logic   [slave_c-1 : 0][1  : 0]     htrans_s,       // AHB - Slave HTRANS 
    output  logic   [slave_c-1 : 0][2  : 0]     hsize_s,        // AHB - Slave HSIZE 
    output  logic   [slave_c-1 : 0][2  : 0]     hburst_s,       // AHB - Slave HBURST 
    input   logic   [slave_c-1 : 0][1  : 0]     hresp_s,        // AHB - Slave HRESP 
    input   logic   [slave_c-1 : 0][0  : 0]     hready_s,       // AHB - Slave HREADYOUT 
    output  logic   [slave_c-1 : 0][0  : 0]     hsel_s,         // AHB - Slave HSEL
    // core side
    input   logic                  [31 : 0]     addr,           // address memory
    output  logic                  [31 : 0]     rd,             // read memory
    input   logic                  [31 : 0]     wd,             // write memory
    input   logic                  [0  : 0]     we,             // write enable signal
    input   logic                  [0  : 0]     req,            // request memory signal
    output  logic                  [0  : 0]     req_ack         // request acknowledge memory signal
);

    logic   [31 : 0]    haddr;
    logic   [31 : 0]    hwdata;
    logic   [31 : 0]    hrdata;
    logic   [0  : 0]    hwrite;
    logic   [1  : 0]    htrans;
    logic   [2  : 0]    hsize;
    logic   [2  : 0]    hburst;
    logic   [1  : 0]    hresp;
    logic   [0  : 0]    hready;

    nf_ahb2core nf_ahb2core_0
    (
        .clk            ( clk           ),
        .resetn         ( resetn        ),
        // AHB side
        .haddr          ( haddr         ),  // AHB HADDR
        .hwdata         ( hwdata        ),  // AHB HWDATA
        .hrdata         ( hrdata        ),  // AHB HRDATA
        .hwrite         ( hwrite        ),  // AHB HWRITE
        .htrans         ( htrans        ),  // AHB HTRANS
        .hsize          ( hsize         ),  // AHB HSIZE
        .hburst         ( hburst        ),  // AHB HBURST
        .hresp          ( hresp         ),  // AHB HRESP
        .hready         ( hready        ),  // AHB HREADY
        // core side
        .addr           ( addr          ),  // address memory
        .we             ( we            ),  // write enable signal
        .wd             ( wd            ),  // write memory
        .rd             ( rd            ),  // read memory
        .req            ( req           ),  // request memory signal
        .req_ack        ( req_ack       )   // request acknowledge memory signal
    );

    nf_ahb_router 
    #(
        .slave_c        ( slave_c       )
    )
    nf_ahb_router_0
    (
        .hclk           ( clk           ),
        .hresetn        ( resetn        ),
        // Master side
        .haddr          ( haddr         ),  // AHB - Master HADDR
        .hwdata         ( hwdata        ),  // AHB - Master HWDATA
        .hrdata         ( hrdata        ),  // AHB - Master HRDATA
        .hwrite         ( hwrite        ),  // AHB - Master HWRITE
        .htrans         ( htrans        ),  // AHB - Master HTRANS 
        .hsize          ( hsize         ),  // AHB - Master HSIZE
        .hburst         ( hburst        ),  // AHB - Master HBURST
        .hresp          ( hresp         ),  // AHB - Master HRESP
        .hready         ( hready        ),  // AHB - Master HREADY
        // Slaves side
        .haddr_s        ( haddr_s       ),  // AHB - Slave HADDR 
        .hwdata_s       ( hwdata_s      ),  // AHB - Slave HWDATA 
        .hrdata_s       ( hrdata_s      ),  // AHB - Slave HRDATA 
        .hwrite_s       ( hwrite_s      ),  // AHB - Slave HWRITE 
        .htrans_s       ( htrans_s      ),  // AHB - Slave HTRANS 
        .hsize_s        ( hsize_s       ),  // AHB - Slave HSIZE 
        .hburst_s       ( hburst_s      ),  // AHB - Slave HBURST 
        .hresp_s        ( hresp_s       ),  // AHB - Slave HRESP 
        .hready_s       ( hready_s      ),  // AHB - Slave HREADY 
        .hsel_s         ( hsel_s        )   // AHB - Slave HSEL
    );

endmodule : nf_ahb_top
