/* 
*  File            :   nf_cache_controller.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.25
*  Language        :   SystemVerilog
*  Description     :   This is cache memory controller
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/ 

module nf_cache_controller
#(
    parameter           addr_w = 6,         // actual address memory width
                        depth  = 2 ** 6,    // depth of memory array
                        tag_w  = 6          // tag width
)(
    input   logic   [0  :  0]   clk,        // clock
    input   logic   [31 :  0]   raddr,      // read address
    input   logic   [31 :  0]   waddr,      // write address
    input   logic   [0  :  0]   swe,        // store write enable
    input   logic   [0  :  0]   lwe,        // load write enable
    input   logic   [0  :  0]   req_l,      // requets load
    input   logic   [1  :  0]   size_d,     // data size
    input   logic   [1  :  0]   size_r,     // read data size
    input   logic   [31 :  0]   sd,         // store data
    input   logic   [31 :  0]   ld,         // load data
    output  logic   [31 :  0]   rd,         // read data
    output  logic   [0  :  0]   hit         // cache hit
);

    // creating one cache module
    nf_cache
    #(
        .addr_w     ( 6             ),      // actual address memory width
        .depth      ( 2 ** 6        ),      // depth of memory array
        .tag_w      ( 6             )       // tag width
    )
    nf_cache_0
    (
        .clk        ( clk           ),      // clock
        .raddr      ( raddr         ),      // read address
        .waddr      ( waddr         ),      // write address
        .we_cb      ( we_cb         ),      // write enable
        .we_ctv     ( we_ctv        ),      // write tag valid enable
        .wd         ( wd_sl         ),      // write data
        .vld        ( vld           ),      // write valid
        .wtag       ( wtag          ),      // write tag
        .rd         ( rd            ),      // read data
        .hit        ( hit_i         )       // cache hit
    );


endmodule : nf_cache_controller
