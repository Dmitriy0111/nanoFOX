/*
*  File            :   nf_register.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is file with registers modules
*  Copyright(c)    :   2018 Vlasov D.V.
*/

//simple register with reset and clock 
module nf_register
#(
    parameter                       width = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic   [width-1 : 0]   datai,
    output  logic   [width-1 : 0]   datao
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if(!resetn)
            datao <= '0;
        else
            datao <= datai;
    end

endmodule : nf_register

//register with write enable input
module nf_register_we
#(
    parameter                       width = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic                   we,
    input   logic   [width-1 : 0]   datai,
    output  logic   [width-1 : 0]   datao
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if(!resetn)
            datao <= '0;
        else if(we)
            datao <= datai;
    end

endmodule : nf_register_we
