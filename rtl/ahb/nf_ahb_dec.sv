/*
*  File            :   nf_ahb_dec.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.28
*  Language        :   SystemVerilog
*  Description     :   This is AHB decoder module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"

module nf_ahb_dec
#(
    parameter                           slave_c = `SLAVE_COUNT
)(
    input   logic   [31        : 0]     haddr,  // AHB address
    output  logic   [slave_c-1 : 0]     hsel    // hsel signal
);

    genvar  gen_ahb_dec;
    generate
        for(gen_ahb_dec = 0 ; gen_ahb_dec < slave_c ; gen_ahb_dec++)
        begin : generate_hsel
            always_comb
            begin
                hsel[gen_ahb_dec] = '0;
                casex( haddr )
                    ahb_vector[gen_ahb_dec] : hsel[gen_ahb_dec] = '1;
                    default                 : ;
                endcase
            end 
        end
    endgenerate

endmodule : nf_ahb_dec
