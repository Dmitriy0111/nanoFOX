/*
*  File            :   nf_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.28
*  Language        :   SystemVerilog
*  Description     :   This is common ram memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"

module nf_ram
#(
    parameter                   depth     = 64,
                                load      = '0,
                                path2file = "path to hex file"
)(
    input   logic   [0  : 0]    clk,    // clock
    input   logic   [31 : 0]    addr,   // address
    input   logic   [0  : 0]    we,     // write enable
    input   logic   [31 : 0]    wd,     // write data
    output  logic   [31 : 0]    rd      // read data
);

    logic [7  : 0] bank_0 [depth-1 : 0];
    logic [7  : 0] bank_1 [depth-1 : 0];
    logic [7  : 0] bank_2 [depth-1 : 0];
    logic [7  : 0] bank_3 [depth-1 : 0];

    assign  rd[24 +: 8] = bank_3[addr];
    assign  rd[16 +: 8] = bank_2[addr];
    assign  rd[8  +: 8] = bank_1[addr];
    assign  rd[0  +: 8] = bank_0[addr];

    always @(posedge clk)
    begin : write_to_bank_3
        if( we )
            bank_3[addr] <= wd[24 +: 8]; 
    end
    
    always @(posedge clk)
    begin : write_to_bank_2
        if( we )
            bank_2[addr] <= wd[16 +: 8]; 
    end
    
    always @(posedge clk)
    begin : write_to_bank_1
        if( we )
            bank_1[addr] <= wd[8  +: 8]; 
    end
    
    always @(posedge clk)
    begin : write_to_bank_0
        if( we )
            bank_0[addr] <= wd[0  +: 8]; 
    end

    initial
    begin
        if( load )
        begin
            $readmemh( { path2file , "_3" , ".hex" } , bank_3 );
            $readmemh( { path2file , "_2" , ".hex" } , bank_2 );
            $readmemh( { path2file , "_1" , ".hex" } , bank_1 );
            $readmemh( { path2file , "_0" , ".hex" } , bank_0 );
        end
    end

    // for verification
    // synthesis translate_off
    
    logic [31 : 0] ram  [depth-1 : 0];

    always @(posedge clk)
    begin
        if( we )
            ram[addr][24 +: 8] <= wd[24 +: 8];
        if( we )
            ram[addr][16 +: 8] <= wd[16 +: 8];
        if( we )
            ram[addr][8  +: 8] <= wd[8  +: 8];
        if( we )
            ram[addr][0  +: 8] <= wd[0  +: 8];
    end
    
    initial
        if( load )
            $readmemh( { path2file , ".hex" } , ram );
            
    // synthesis translate_on

endmodule : nf_ram
