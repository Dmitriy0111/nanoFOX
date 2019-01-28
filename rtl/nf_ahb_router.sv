/*
*  File            :   nf_ahb_router.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.28
*  Language        :   SystemVerilog
*  Description     :   This is AHB multiplexor module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_ahb_router
#(
    parameter                       slave_c = 4
)(
    // Master side
    input                                       hclk,
    input                                       hresetn,
    input   logic                               hwrite,
    input   logic   [1  :0]                     htrans,
    input   logic   [31 :0]                     haddr,
    output  logic   [31 :0]                     hrdata,
    input   logic   [31 :0]                     hwdata,
    output  logic                               hready,
    output  logic                               hresp,
    // Slaves side
    output  logic   [slave_c-1  : 0][31 : 0]    hwdata_s,
    output  logic   [slave_c-1  : 0][0  : 0]    hwrite_s,
    output  logic   [slave_c-1  : 0][1  : 0]    htrans_s
);

    logic   [slave_c-1  : 0]                    hsel_ff;
    logic   [slave_c-1  : 0]                    hsel;
    logic   [slave_c-1  : 0][31 : 0]            rdata;
    logic   [slave_c-1  : 0]                    resp;
    logic   [slave_c-1  : 0]                    hreadyout;

    genvar  gen_ahb_dec;
    generate
        for(gen_ahb_dec = 0 ; gen_ahb_dec < slave_c ; gen_ahb_dec++)
        begin : generate_hsel
            assign  hwdata_s[gen_ahb_dec] = hwdata;
            assign  hwrite_s[gen_ahb_dec] = hwrite;
            assign  htrans_s[gen_ahb_dec] = htrans;
        end
    endgenerate
    
    nf_ahb_dec nf_ahb_dec_0
    (   
        .haddr        ( haddr        ),
        .hsel         ( hsel         )
    );

    always_ff @(posedge hclk, negedge hresetn)
    begin
        if( !hresetn )
            hsel_ff <= '0;
        else
            hsel_ff <= hsel;
    end

    nf_ahb_mux nf_ahb_mux_0
    (
        .hsel_ff      ( hsel_ff      ),
        .rdata        (              ),
        .resp         ( resp         ),
        .hrdata       ( hrdata       ),
        .hresp        ( hresp        ),
        .hreadyout    ( hreadyout    ),
        .hready       ( hready       )
    );

endmodule : nf_ahb_router
