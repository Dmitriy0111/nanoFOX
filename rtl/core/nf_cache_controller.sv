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
    parameter                   addr_w = 6,         // actual address memory width
                                depth  = 2 ** 6,    // depth of cache memory
                                tag_w  = 6          // tag width field
)(
    input   logic   [0  :  0]   clk,                // clock
    input   logic   [31 :  0]   raddr,              // read address
    input   logic   [31 :  0]   waddr,              // write address
    input   logic   [0  :  0]   swe,                // store write enable
    input   logic   [0  :  0]   lwe,                // load write enable
    input   logic   [0  :  0]   req_l,              // requets load
    input   logic   [1  :  0]   size_d,             // data size
    input   logic   [1  :  0]   size_r,             // read data size
    input   logic   [31 :  0]   sd,                 // store data
    input   logic   [31 :  0]   ld,                 // load data
    output  logic   [31 :  0]   rd,                 // read data
    output  logic   [0  :  0]   hit                 // cache hit
);

    logic   [0       : 0]   we_ctv;     // write enable cache tag and valid
    logic   [3       : 0]   vld;        // valid signal
    logic   [tag_w-1 : 0]   wtag;       // write tag field
    logic   [3       : 0]   we_cb;      // write enable cache bank
    logic   [31      : 0]   wd_sl;      // write data store/load
    logic   [3       : 0]   hit_i;      // hit internal

    logic   [3       : 0]   byte_en_w;  // byte enable for write
    logic   [3       : 0]   byte_en_r;  // byte enable for read

    assign we_ctv   =   ( swe || ( lwe && req_l ) );                                        // finding write enable for tag and valid fields
    assign vld[0]   =   ( ( ( swe || ( lwe && req_l ) ) && byte_en_w[0] ) || hit_i[0] );    // finding valid value for bank 0
    assign vld[1]   =   ( ( ( swe || ( lwe && req_l ) ) && byte_en_w[1] ) || hit_i[1] );    // finding valid value for bank 1
    assign vld[2]   =   ( ( ( swe || ( lwe && req_l ) ) && byte_en_w[2] ) || hit_i[2] );    // finding valid value for bank 2
    assign vld[3]   =   ( ( ( swe || ( lwe && req_l ) ) && byte_en_w[3] ) || hit_i[3] );    // finding valid value for bank 3
    assign hit      =   ( ! byte_en_r[0] || hit_i[0] ) &&                                   // finding resulting hit for bank 0
                        ( ! byte_en_r[1] || hit_i[1] ) &&                                   // finding resulting hit for bank 1
                        ( ! byte_en_r[2] || hit_i[2] ) &&                                   // finding resulting hit for bank 2
                        ( ! byte_en_r[3] || hit_i[3] );                                     // finding resulting hit for bank 3
    // byte enable for write operations
    assign byte_en_w[0] =   ( ( size_d == 2'b10 ) ||                                    // word
                            ( ( size_d == 2'b01 ) && ( waddr[1 : 0] == 2'b00 ) ) ||     // half word
                            ( ( size_d == 2'b00 ) && ( waddr[1 : 0] == 2'b00 ) ) );     // byte

    assign byte_en_w[1] =   ( ( size_d == 2'b10 ) ||                                    // word
                            ( ( size_d == 2'b01 ) && ( waddr[1 : 0] == 2'b00 ) ) ||     // half word
                            ( ( size_d == 2'b00 ) && ( waddr[1 : 0] == 2'b01 ) ) );     // byte

    assign byte_en_w[2] =   ( ( size_d == 2'b10 ) ||                                    // word
                            ( ( size_d == 2'b01 ) && ( waddr[1 : 0] == 2'b10 ) ) ||     // half word
                            ( ( size_d == 2'b00 ) && ( waddr[1 : 0] == 2'b10 ) ) );     // byte

    assign byte_en_w[3] =   ( ( size_d == 2'b10 ) ||                                    // word
                            ( ( size_d == 2'b01 ) && ( waddr[1 : 0] == 2'b10 ) ) ||     // half word
                            ( ( size_d == 2'b00 ) && ( waddr[1 : 0] == 2'b11 ) ) );     // byte
    // byte enable for read operations
    assign byte_en_r[0] =   ( ( size_r == 2'b10 ) ||                                    // word
                            ( ( size_r == 2'b01 ) && ( raddr[1 : 0] == 2'b00 ) ) ||     // half word
                            ( ( size_r == 2'b00 ) && ( raddr[1 : 0] == 2'b00 ) ) );     // byte

    assign byte_en_r[1] =   ( ( size_r == 2'b10 ) ||                                    // word
                            ( ( size_r == 2'b01 ) && ( raddr[1 : 0] == 2'b00 ) ) ||     // half word
                            ( ( size_r == 2'b00 ) && ( raddr[1 : 0] == 2'b01 ) ) );     // byte

    assign byte_en_r[2] =   ( ( size_r == 2'b10 ) ||                                    // word
                            ( ( size_r == 2'b01 ) && ( raddr[1 : 0] == 2'b10 ) ) ||     // half word
                            ( ( size_r == 2'b00 ) && ( raddr[1 : 0] == 2'b10 ) ) );     // byte

    assign byte_en_r[3] =   ( ( size_r == 2'b10 ) ||                                    // word
                            ( ( size_r == 2'b01 ) && ( raddr[1 : 0] == 2'b10 ) ) ||     // half word
                            ( ( size_r == 2'b00 ) && ( raddr[1 : 0] == 2'b11 ) ) );     // byte

    // finding write enable cache bank 0
    assign we_cb[0] = ( byte_en_w[0] && ( swe || ( lwe && req_l ) ) );
    // finding write enable cache bank 1
    assign we_cb[1] = ( byte_en_w[1] && ( swe || ( lwe && req_l ) ) );
    // finding write enable cache bank 2
    assign we_cb[2] = ( byte_en_w[2] && ( swe || ( lwe && req_l ) ) );
    // finding write enable cache bank 3
    assign we_cb[3] = ( byte_en_w[3] && ( swe || ( lwe && req_l ) ) );

    assign wd_sl = ( lwe && req_l ) ? ld : sd;      // finding write data store/load
    assign wtag  = ( lwe && req_l ) ? raddr[tag_w-1+addr_w+2 : addr_w+2] : waddr[tag_w-1+addr_w+2 : addr_w+2];

    // creating one cache module
    nf_cache
    #(
        .addr_w     ( 6             ),      // actual address memory width
        .depth      ( 2 ** 6        ),      // depth of cache memory
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
