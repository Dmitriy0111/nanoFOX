/*
*  File            :   nf_register.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is file with registers modules
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_register
#(
    parameter                       WIDTH = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic   [WIDTH-1 : 0]   datai,
    output  logic   [WIDTH-1 : 0]   datao
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            datao <= '0;
        else
            datao <= datai;
    end

endmodule : nf_register
