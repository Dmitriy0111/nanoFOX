/*
*  File            :   nf_instr_mem.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is instruction memory module
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_instr_mem
#(
    parameter                               depth = 64
)(
    input                                   clk,
    input   logic   [31 : 0]                addr,
    output  logic   [31 : 0]                instr,
    input   logic   [31 : 0]                load_addr,
    input   logic   [31 : 0]                load_data,
    input   logic                           load
);

    logic   [31 : 0]    mem [depth-1 : 0];

    assign instr = mem[addr];
    /*always_ff @(posedge clk)
    begin
        if(load)
            mem[load_addr]<=load_data;
    end*/

    initial
    begin
        $readmemh("../program_file/program.hex",mem);
    end

endmodule : nf_instr_mem
