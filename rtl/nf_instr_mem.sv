/*
*  File            :   nf_instr_mem.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is instraction memory module
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_instr_mem
#(
    parameter                               depth = 64
)(
    input   logic   [31 : 0]                addr,
    output  logic   [31 : 0]                instr
);

    logic   [31 : 0]    mem [depth-1 : 0];

    assign instr = mem[addr];

    initial
    begin
        $readmemh("../rtl/program.hex",mem);
    end

endmodule : nf_instr_mem
