/*
*  File            :   nf_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.28
*  Language        :   SystemVerilog
*  Description     :   This is common ram memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_ram
#(
    parameter                   depth = 64
)(
    input   logic   [0  : 0]    clk,    // clock
    input   logic   [31 : 0]    addr,   // address
    input   logic   [0  : 0]    we,     // write enable
    input   logic   [31 : 0]    wd,     // write data
    output  logic   [31 : 0]    rd      // read data
);

    logic   [31 : 0]    ram     [depth-1 : 0];  // creating memory array
    // reading data memory
    assign rd = ram[addr];
    // writing data memory
    always_ff @(posedge clk)
        if( we )
            ram[addr] <= wd;  

endmodule : nf_ram
