/*
*  File            :   nf_dp_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.28
*  Language        :   SystemVerilog
*  Description     :   This is dual port ram memory
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_dp_ram
#(
    parameter                   depth = 64
)(
    input   logic               clk,
    input   logic   [31 : 0]    addr_p1,
    input   logic               we_p1,
    input   logic   [31 : 0]    wd_p1,
    output  logic   [31 : 0]    rd_p1,
    input   logic   [31 : 0]    addr_p2,
    input   logic               we_p2,
    input   logic   [31 : 0]    wd_p2,
    output  logic   [31 : 0]    rd_p2
);

    logic [31 : 0] ram [depth-1 : 0];

    assign rd_p1 = ram[addr_p1];

    always_ff @(posedge clk)
    begin
        if( we_p1 )
            ram[addr_p1] <= wd_p1;  
    end

    assign rd_p2 = ram[addr_p2];

    always_ff @(posedge clk)
    begin
        if( we_p2 )
            ram[addr_p2] <= wd_p2;  
    end

    initial
    begin
        $readmemh("../program_file/program.hex",ram);
    end

endmodule : nf_dp_ram
