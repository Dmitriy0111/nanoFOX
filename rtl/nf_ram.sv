/*
*  File            :   nf_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.28
*  Language        :   SystemVerilog
*  Description     :   This is common ram memory
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_ram
#(
    parameter                   depth = 64
)(
    input   logic               clk,
    input   logic   [31 : 0]    addr,
    input   logic               we,
    input   logic   [31 : 0]    wd,
    output  logic   [31 : 0]    rd
);

    logic [31 : 0] ram [depth-1 : 0];

    assign rd = ram[addr];

    always_ff @(posedge clk)
    begin
        if( we )
            ram[addr] <= wd;  
    end

endmodule : nf_ram
