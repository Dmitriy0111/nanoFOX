/*
*  File            :   nf_seven_seg_dynamic.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.12.02
*  Language        :   SystemVerilog
*  Description     :   This is dynamic seven seg converter
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_seven_seg_dynamic
(
    input   logic               clk,        // clock
    input   logic               resetn,     // reset
    input   logic   [31 : 0]    hex,        // hexadecimal value input
    input   logic               cc_ca,      // common cathode or common anode
    output  logic   [7  : 0]    seven_seg,  // seven segments output
    output  logic   [3  : 0]    dig         // digital tube selector
);
    
    logic   [17 : 0]    counter;
    logic   [1  : 0]    digit_enable;

    always_comb
    begin
        dig = '0;
        case( digit_enable )
            'h0     :   dig = 'hE;
            'h1     :   dig = 'hD;
            'h2     :   dig = 'hB;
            'h3     :   dig = 'h7;
            default : ;
        endcase
    end

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            counter <= '0;
        else
        begin
            counter <= counter + 1'b1;
            if( counter[17] )
                counter <= '0;
        end
    
    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            digit_enable <= '0;
        else
        begin
            if( counter[17] )
                digit_enable <= digit_enable + 1'b1;
        end

    nf_seven_seg nf_seven_seg_0
    (
        .hex        ( hex[digit_enable*4 +: 4]  ),  // hexadecimal value input
        .cc_ca      ( cc_ca                     ),  // common cathode or common anode
        .seven_seg  ( seven_seg                 )   // seven segments output
    );

endmodule : nf_seven_seg_dynamic
