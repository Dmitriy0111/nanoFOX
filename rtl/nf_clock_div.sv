/*
*  File            :   nf_clock_div.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is unit for creating clock enable strobe
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_clock_div
(
    input   logic               clk,
    input   logic               resetn, 
    input   logic   [25:0]      div,    // div_number
    output  logic               en      // enable strobe
);

    logic   [25:0]  int_div;    //internal divider register
    logic   [25:0]  int_c;      //internal compare register

    assign en = (int_div == int_c);

    always_ff @(posedge clk, negedge resetn)
    begin : name
        if( !resetn )
        begin
            int_div <= '0;
            int_c   <= div;
        end
        else
        begin
            int_div <= int_div + 1'b1;
            if(int_div == int_c)
            begin
                int_div <= '0;
                int_c   <= div;
            end
        end 
    end

endmodule : nf_clock_div
