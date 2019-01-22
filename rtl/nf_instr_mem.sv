/*
*  File            :   nf_instr_mem.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is instruction memory module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_instr_mem
#(
    parameter                               depth = 64
)(
    input   logic   [31 : 0]                addr,   // instruction address
    output  logic   [31 : 0]                instr   // instruction data
);

    logic   [31 : 0]    mem [depth-1 : 0];

    assign instr = mem[addr];

    initial
    begin
        $readmemh("../program_file/program.hex",mem);
    end

endmodule : nf_instr_mem
