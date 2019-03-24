/*
*  File            :   nf_register.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is file with registers modules
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

// simple register with reset and clock 
module nf_register
#(
    parameter                       width = 1
)(
    input   logic   [0       : 0]   clk,    // clock
    input   logic   [0       : 0]   resetn, // reset
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            datao <= '0;
        else
            datao <= datai;

endmodule : nf_register

// register with write enable input
module nf_register_we
#(
    parameter                       width = 1
)(
    input   logic   [0       : 0]   clk,    // clock
    input   logic   [0       : 0]   resetn, // reset
    input   logic   [0       : 0]   we,     // write enable
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            datao <= '0;
        else if( we )
            datao <= datai;

endmodule : nf_register_we
