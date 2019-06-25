/* 
*  File            :   nf_param_mem.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.25
*  Language        :   SystemVerilog
*  Description     :   This is memory with parameter
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/ 

module nf_param_mem
#(
    parameter                       addr_w = 6,             // actual address memory width
                                    data_w = 32,            // actual data width
                                    depth  = 2 ** addr_w    // depth of memory array
)(
    input   logic   [0        : 0]  clk,                    // clock
    input   logic   [addr_w-1 : 0]  waddr,                  // write address
    input   logic   [addr_w-1 : 0]  raddr,                  // read address
    input   logic   [0        : 0]  we,                     // write enable
    input   logic   [data_w-1 : 0]  wd,                     // write data
    output  logic   [data_w-1 : 0]  rd                      // read data
);

    logic   [data_w-1 : 0]  mem [depth-1 : 0];

    assign rd = mem[raddr];

    always @(posedge clk)
        if( we )
            mem[waddr] <= wd;

endmodule : nf_param_mem
