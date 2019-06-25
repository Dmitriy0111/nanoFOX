/* 
*  File            :   nf_cache.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.25
*  Language        :   SystemVerilog
*  Description     :   This is cache memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/ 

module nf_cache
#
(
    parameter                       addr_w = 6,             // actual address memory width
                                    depth  = 2 ** addr_w,   // depth of memory array
                                    tag_w  = 6              // tag width
)(
    input   logic   [0       : 0]   clk,                    // clock
    input   logic   [31      : 0]   raddr,                  // read address
    input   logic   [31      : 0]   waddr,                  // write address
    input   logic   [3       : 0]   we_cb,                  // write cache enable
    input   logic   [0       : 0]   we_ctv,                 // write tag valid enable
    input   logic   [31      : 0]   wd,                     // write data
    input   logic   [3       : 0]   vld,                    // write valid
    input   logic   [tag_w-1 : 0]   wtag,                   // write tag
    output  logic   [31      : 0]   rd,                     // read data
    output  logic   [3       : 0]   hit                     // cache hit
);

    logic   [31-(addr_w+2) : 0]     addr_tag;       // tag address for comparing
    logic   [addr_w-1      : 0]     raddr_cache;    // read cache address
    logic   [addr_w-1      : 0]     waddr_cache;    // write cache address
    logic   [tag_w-1       : 0]     cache_tag;      // cache tag field
    logic   [3             : 0]     cache_v;        // cache valid field
    logic   [tag_w-1+4     : 0]     cache_tv_r;     // cache tag valid fields read data
    logic   [tag_w-1+4     : 0]     cache_tv_w;     // cache tag valid fields write data
    logic   [0             : 0]     addr_eq;        // address equal
    logic   [31            : 0]     rd_i;       


    assign waddr_cache = waddr[addr_w+2-1 : 2];             // finding write cache address
    assign raddr_cache = raddr[addr_w+2-1 : 2];             // finding read cache address
    assign addr_tag    = raddr[31 : addr_w+2];              // finding read address tag field
    assign cache_tag   = cache_tv_r[tag_w-1   : 0];         // finding cache tag field
    assign cache_v     = cache_tv_r[tag_w+4-1 : tag_w];     // finding cache valid field
    assign cache_tv_w  = { vld , wtag };                    // finding value write data for tag and valid cache fields

    assign addr_eq = ( cache_tag == addr_tag ); // finding address equality

    assign hit[0] = ( cache_v[0] && addr_eq );  // finding hit value for bank 0
    assign hit[1] = ( cache_v[1] && addr_eq );  // finding hit value for bank 1
    assign hit[2] = ( cache_v[2] && addr_eq );  // finding hit value for bank 2
    assign hit[3] = ( cache_v[3] && addr_eq );  // finding hit value for bank 3

    assign rd[7  :  0] = ( ( waddr == raddr ) && we_cb[0] ) ? wd[7  :  0] : rd_i[7  :  0];
    assign rd[15 :  8] = ( ( waddr == raddr ) && we_cb[1] ) ? wd[15 :  8] : rd_i[15 :  8];
    assign rd[23 : 16] = ( ( waddr == raddr ) && we_cb[2] ) ? wd[23 : 16] : rd_i[23 : 16];
    assign rd[31 : 24] = ( ( waddr == raddr ) && we_cb[3] ) ? wd[31 : 24] : rd_i[31 : 24];

    // creating cache bank 0
    nf_param_mem
    #(
        .addr_w     ( addr_w            ),      // actual address memory width
        .data_w     ( 8                 ),      // actual data width
        .depth      ( depth             )       // depth of memory array
    )
    cache_b0
    (
        .clk        ( clk               ),      // clock
        .waddr      ( waddr_cache       ),      // write address
        .raddr      ( raddr_cache       ),      // read address
        .we         ( we_cb[0]          ),      // write enable
        .wd         ( wd  [0  +:  8]    ),      // write data
        .rd         ( rd_i[0  +:  8]    )       // read data
    );
    // creating cache bank 1
    nf_param_mem
    #(
        .addr_w     ( addr_w            ),      // actual address memory width
        .data_w     ( 8                 ),      // actual data width
        .depth      ( depth             )       // depth of memory array
    )
    cache_b1
    (
        .clk        ( clk               ),      // clock
        .waddr      ( waddr_cache       ),      // write address
        .raddr      ( raddr_cache       ),      // read address
        .we         ( we_cb[1]          ),      // write enable
        .wd         ( wd  [8  +:  8]    ),      // write data
        .rd         ( rd_i[8  +:  8]    )       // read data
    );
    // creating cache bank 2
    nf_param_mem
    #(
        .addr_w     ( addr_w            ),      // actual address memory width
        .data_w     ( 8                 ),      // actual data width
        .depth      ( depth             )       // depth of memory array
    )
    cache_b2
    (
        .clk        ( clk               ),      // clock
        .waddr      ( waddr_cache       ),      // write address
        .raddr      ( raddr_cache       ),      // read address
        .we         ( we_cb[2]          ),      // write enable
        .wd         ( wd  [16 +:  8]    ),      // write data
        .rd         ( rd_i[16 +:  8]    )       // read data
    );
    // creating cache bank 3
    nf_param_mem
    #(
        .addr_w     ( addr_w            ),      // actual address memory width
        .data_w     ( 8                 ),      // actual data width
        .depth      ( depth             )       // depth of memory array
    )
    cache_b3
    (
        .clk        ( clk               ),      // clock
        .waddr      ( waddr_cache       ),      // write address
        .raddr      ( raddr_cache       ),      // read address
        .we         ( we_cb[3]          ),      // write enable
        .wd         ( wd  [24 +:  8]    ),      // write data
        .rd         ( rd_i[24 +:  8]    )       // read data
    );
    // creating cache tag and valid bank
    nf_param_mem
    #(
        .addr_w     ( addr_w            ),      // actual address memory width
        .data_w     ( tag_w+4           ),      // actual data width
        .depth      ( depth             )       // depth of memory array
    )
    cache_tag_valid
    (
        .clk        ( clk               ),      // clock
        .waddr      ( waddr_cache       ),      // write address
        .raddr      ( raddr_cache       ),      // read address
        .we         ( we_ctv            ),      // write enable
        .wd         ( cache_tv_w        ),      // write data
        .rd         ( cache_tv_r        )       // read data
    );

    // for verification
    // synthesis translate_off

    logic   [7 : 0]     cache_f [2**(addr_w+2)-1 : 0];

    always @(posedge clk)
    begin
        if( we_cb[3] )
            cache_f( { waddr_cache , 2'b00 } + 3 ) <= wd[24 +: 8];
        if( we_cb[2] )
            cache_f( { waddr_cache , 2'b00 } + 2 ) <= wd[16 +: 8];
        if( we_cb[1] )
            cache_f( { waddr_cache , 2'b00 } + 1 ) <= wd[8  +: 8];
        if( we_cb[0] )
            cache_f( { waddr_cache , 2'b00 } + 0 ) <= wd[0  +: 8];
    end

    // synthesis translate_on

endmodule : nf_cache
