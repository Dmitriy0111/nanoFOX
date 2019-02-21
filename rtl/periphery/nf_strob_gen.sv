/*
*  File            :   nf_strob_gen.sv
*  Autor           :   Vlasov D.V. 63030
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Description     :   This is strob generator
*  Copyright(c)    :   2018 Vlasov D.V. 63030
*/

module nf_strob_gen
(
    input   logic               clk,
    input   logic               resetn,
    input   logic   [15 : 0]    comp,
    output  logic               en
);

    logic [15 : 0] counter;

    assign  en = counter == ( comp >> 1 ) ? '1 : '0;

    always_ff @(posedge clk, negedge resetn)
    begin
        if ( !resetn )
            counter <= '0;
        else
        begin
            if( counter < comp - 1 )
                counter <= counter + 1'b1;
            else
                counter <= '0;
        end
    end

endmodule : nf_strob_gen
