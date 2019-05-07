/*
*  File            :   nf_clock_div.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is unit for creating clock enable strobe
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_clock_div
(
    // clock and reset
    input   logic   [0  : 0]    clk,    // clock
    input   logic   [0  : 0]    resetn, // reset
    // strobbing
    input   logic   [25 : 0]    div,    // div_number
    output  logic   [0  : 0]    en      // enable strobe
);

    logic   [25 : 0]    int_div;    // internal divider register
    logic   [25 : 0]    int_c;      // internal compare register
    // finding strobe value
    assign en = ( int_div == int_c );
    // other logic
    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
        begin
            int_div <= '0;
            int_c   <= '0;
        end
        else
        begin
            int_div <= int_div + 1'b1;
            if( int_div == int_c )
            begin
                int_div <= '0;
                int_c   <= div;
            end
        end 

endmodule : nf_clock_div
