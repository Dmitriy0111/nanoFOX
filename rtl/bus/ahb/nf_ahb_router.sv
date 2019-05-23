/*
*  File            :   nf_ahb_router.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.28
*  Language        :   SystemVerilog
*  Description     :   This is AHB router module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../../inc/nf_settings.svh"

module nf_ahb_router
#(
    parameter                                   slave_c = `SLAVE_COUNT
)(
    input   logic                  [0  : 0]     hclk,           // hclk
    input   logic                  [0  : 0]     hresetn,        // hresetn
    // Master side
    input   logic                  [31 : 0]     haddr,          // AHB - Master HADDR
    input   logic                  [31 : 0]     hwdata,         // AHB - Master HWDATA
    output  logic                  [31 : 0]     hrdata,         // AHB - Master HRDATA
    input   logic                  [0  : 0]     hwrite,         // AHB - Master HWRITE
    input   logic                  [1  : 0]     htrans,         // AHB - Master HTRANS
    input   logic                  [2  : 0]     hsize,          // AHB - Master HSIZE
    input   logic                  [2  : 0]     hburst,         // AHB - Master HBURST
    output  logic                  [1  : 0]     hresp,          // AHB - Master HRESP
    output  logic                  [0  : 0]     hready,         // AHB - Master HREADY
    // Slaves side
    output  logic   [slave_c-1 : 0][31 : 0]     haddr_s,        // AHB - Slave HADDR
    output  logic   [slave_c-1 : 0][31 : 0]     hwdata_s,       // AHB - Slave HWDATA
    input   logic   [slave_c-1 : 0][31 : 0]     hrdata_s,       // AHB - Slave HRDATA
    output  logic   [slave_c-1 : 0][0  : 0]     hwrite_s,       // AHB - Slave HWRITE
    output  logic   [slave_c-1 : 0][1  : 0]     htrans_s,       // AHB - Slave HTRANS
    output  logic   [slave_c-1 : 0][2  : 0]     hsize_s,        // AHB - Slave HSIZE
    output  logic   [slave_c-1 : 0][2  : 0]     hburst_s,       // AHB - Slave HBURST
    input   logic   [slave_c-1 : 0][1  : 0]     hresp_s,        // AHB - Slave HRESP
    input   logic   [slave_c-1 : 0][0  : 0]     hready_s,       // AHB - Slave HREADY
    output  logic   [slave_c-1 : 0][0  : 0]     hsel_s          // AHB - Slave HSEL
);
    // hsel signals
    logic   [slave_c-1 : 0]     hsel_ff;
    logic   [slave_c-1 : 0]     hsel;
    
    assign hsel_s = hsel;
    // generating wires for all slaves
    genvar  gen_ahb_dec;
    generate
        for( gen_ahb_dec = 0 ; gen_ahb_dec < slave_c ; gen_ahb_dec++ )
        begin : generate_slaves_wires
            assign  haddr_s [gen_ahb_dec] = haddr;
            assign  hwdata_s[gen_ahb_dec] = hwdata;
            assign  hwrite_s[gen_ahb_dec] = hwrite;
            assign  htrans_s[gen_ahb_dec] = htrans;
            assign  hsize_s [gen_ahb_dec] = hsize;
            assign  hburst_s[gen_ahb_dec] = hburst;
        end
    endgenerate
    // creating one AHB decoder module
    nf_ahb_dec
    #(
        .slave_c        ( slave_c       )
    )
    nf_ahb_dec_0
    (   
        .haddr          ( haddr         ),  // AHB address
        .hsel           ( hsel          )   // hsel signal
    );
    // creating one hsel flip-flop
    nf_register #( slave_c ) slave_sel_ff   ( hclk, hresetn, hsel, hsel_ff );
    // creating one AHB multiplexer module
    nf_ahb_mux
    #(
        .slave_c        ( slave_c       )
    )
    nf_ahb_mux_0
    (
        .hsel_ff        ( hsel_ff       ),  // hsel after flip-flop
        // slave side
        .hrdata_s       ( hrdata_s      ),  // AHB read data slaves 
        .hresp_s        ( hresp_s       ),  // AHB response slaves
        .hready_s       ( hready_s      ),  // AHB ready slaves
        // master side
        .hrdata         ( hrdata        ),  // AHB read data master 
        .hresp          ( hresp         ),  // AHB response master
        .hready         ( hready        )   // AHB ready master
    );

    // synthesis translate_off
    /***************************************************
    **                   Assertions                   **
    ***************************************************/

    // creating propertis

    property HSEL_ID_CHECK;
        @(posedge hclk) disable iff(hresetn) ( hsel != '0 );
    endproperty

    // assertions

    NF_HSEL_ID_CHECK : assert property ( HSEL_ID_CHECK ) else begin $error("nf_ahb_router error! hsel = 0"); $stop; end

    // synthesis translate_on

endmodule : nf_ahb_router
