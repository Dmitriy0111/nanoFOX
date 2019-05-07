/*
*  File            :   nf_seven_seg_static.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.12.02
*  Language        :   SystemVerilog
*  Description     :   This is static seven seg converter
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_seven_seg_static
#(
    parameter                       hn = 8      // number of seven segments unit
)(
    input   logic   [31     : 0]    hex,        // hexadecimal value input
    input   logic   [0      : 0]    cc_ca,      // common cathode or common anode
    output  logic   [hn*8-1 : 0]    seven_seg   // seven segments output
);

    genvar hn_i;
    // generate seven segment convertors
    generate
        for ( hn_i = 0; hn_i<hn; hn_i++) 
        begin : gen_seven_seg_convertors
            // creating more nf_seven_seg_
            nf_seven_seg nf_seven_seg_
            (
                .hex        ( hex[hn_i*4 +: 4]          ),  // hexadecimal value input
                .cc_ca      ( cc_ca                     ),  // common cathode or common anode
                .seven_seg  ( seven_seg[hn_i*8 +: 8]    )   // seven segments output
            );
        end
    endgenerate

endmodule : nf_seven_seg_static
