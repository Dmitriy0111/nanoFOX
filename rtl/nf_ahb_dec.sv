/*
*  File            :   nf_ahb_dec.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.28
*  Language        :   SystemVerilog
*  Description     :   This is AHB decoder module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_ahb_dec
#(
    parameter                           slave_c = 4
)(
    input   logic   [31         : 0]    haddr,
    output  logic   [slave_c-1  : 0]    hsel
);

    genvar  gen_ahb_dec;
    generate
        for(gen_ahb_dec = 0 ; gen_ahb_dec < slave_c ; gen_ahb_dec++)
        begin : generate_hsel
            assign  hsel[gen_ahb_dec] = haddr[31 -: 2] == gen_ahb_dec ? '1 : '0 ;
        end
    endgenerate

endmodule : nf_ahb_dec
