/*
*  File            :   nf_seven_seg.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.12.02
*  Language        :   SystemVerilog
*  Description     :   This is seven seg converter
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_seven_seg
(
    input   logic   [3 : 0]     hex,        // hexadecimal value input
    input   logic   [0 : 0]     cc_ca,      // common cathode or common anode
    output  logic   [7 : 0]     seven_seg   // seven segments output
);

    logic   [7 : 0]     sev_seg;    // seven segment internal
    
    assign seven_seg = cc_ca ? ~ sev_seg : sev_seg;

    always_comb
    begin
        sev_seg = 8'b0000_0000;
        case( hex )         //dp_a_b_c_d_e_f_g
        'h0     : sev_seg = 8'b1_1_0_0_0_0_0_0;
        'h1     : sev_seg = 8'b1_1_1_1_1_0_0_1;
        'h2     : sev_seg = 8'b1_0_1_0_0_1_0_0;
        'h3     : sev_seg = 8'b1_0_1_1_0_0_0_0;
        'h4     : sev_seg = 8'b1_0_0_1_1_0_0_1;
        'h5     : sev_seg = 8'b1_0_0_1_0_0_1_0;
        'h6     : sev_seg = 8'b1_0_0_0_0_0_1_0;
        'h7     : sev_seg = 8'b1_1_1_1_1_0_0_0;
        'h8     : sev_seg = 8'b1_0_0_0_0_0_0_0;
        'h9     : sev_seg = 8'b1_0_0_1_1_0_0_0;
        'ha     : sev_seg = 8'b1_0_0_0_1_0_0_0;
        'hb     : sev_seg = 8'b1_0_0_0_0_0_1_1;
        'hc     : sev_seg = 8'b1_1_0_0_0_1_1_0;
        'hd     : sev_seg = 8'b1_0_1_0_0_0_0_1;
        'he     : sev_seg = 8'b1_0_0_0_0_1_1_0;
        'hf     : sev_seg = 8'b1_0_0_0_1_1_1_0;
        default : ;
        endcase
    end

endmodule : nf_seven_seg
