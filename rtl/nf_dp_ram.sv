/*
*  File            :   nf_dp_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.28
*  Language        :   SystemVerilog
*  Description     :   This is dual port ram memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_dp_ram
#(
    parameter                   depth = 64
)(
    input   logic               clk,
    // Port 1
    input   logic   [31 : 0]    addr_p1,    // Port-1 addr
    input   logic   [0  : 0]    we_p1,      // Port-1 write enable
    input   logic   [31 : 0]    wd_p1,      // Port-1 write data
    output  logic   [31 : 0]    rd_p1,      // Port-1 read data
    // Port 2
    input   logic   [31 : 0]    addr_p2,    // Port-2 addr
    input   logic   [0  : 0]    we_p2,      // Port-2 write enable
    input   logic   [31 : 0]    wd_p2,      // Port-2 write data
    output  logic   [31 : 0]    rd_p2       // Port-2 read data
);

    logic [31 : 0] ram [depth-1 : 0];

    always_ff @(posedge clk)
    begin : read_from_mem_p1
            rd_p1 = ram[addr_p1];  
    end

    always_ff @(posedge clk)
    begin : write_in_mem_p1
        if( we_p1 )
            ram[addr_p1] <= wd_p1;  
    end

    always_ff @(posedge clk)
    begin : read_from_mem_p2
            rd_p2 = ram[addr_p2];  
    end

    always_ff @(posedge clk)
    begin : write_in_mem_p2
        if( we_p2 )
            ram[addr_p2] <= wd_p2;  
    end

    initial
    begin
        $readmemh("../program_file/program.hex",ram);
    end

endmodule : nf_dp_ram
