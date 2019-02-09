/*
*  File            :   nf_ahb_mux.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.28
*  Language        :   SystemVerilog
*  Description     :   This is AHB multiplexer module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`include "../inc/nf_ahb.svh"

module nf_ahb_mux
#(
    parameter                                   slave_c = `SLAVE_COUNT
)(
    input   logic   [slave_c-1 : 0]             hsel_ff,        // hsel after flip-flop
    // slave side
    input   logic   [slave_c-1 : 0][31 : 0]     hrdata_s,   // AHB read data slaves 
    input   logic   [slave_c-1 : 0][1  : 0]     hresp_s,    // AHB response slaves
    input   logic   [slave_c-1 : 0][0  : 0]     hready_s,   // AHB ready slaves
    // master side
    output  logic                  [31 : 0]     hrdata,     // AHB read data master 
    output  logic                  [1  : 0]     hresp,      // AHB response master
    output  logic                  [0  : 0]     hready      // AHB ready master
);

    always_comb
    begin
        hrdata  = '0; 
        hresp   = `AHB_HRESP_ERROR; 
        hready  = '1;
        casex( hsel_ff )
            3'b??1  : begin hrdata = hrdata_s[0] ; hresp = hresp_s[0] ; hready = hready_s[0] ;   end
            3'b?10  : begin hrdata = hrdata_s[1] ; hresp = hresp_s[1] ; hready = hready_s[1] ;   end
            3'b100  : begin hrdata = hrdata_s[2] ; hresp = hresp_s[2] ; hready = hready_s[2] ;   end
            default : ;
        endcase
    end

endmodule : nf_ahb_mux
