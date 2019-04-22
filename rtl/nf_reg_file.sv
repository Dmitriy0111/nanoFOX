/*
*  File            :   nf_reg_file.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is register file
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_reg_file
(
    input   logic   [0  : 0]    clk,    // clock
    input   logic   [4  : 0]    ra1,    // read address 1
    output  logic   [31 : 0]    rd1,    // read data 1
    input   logic   [4  : 0]    ra2,    // read address 2
    output  logic   [31 : 0]    rd2,    // read data 2
    input   logic   [4  : 0]    wa3,    // write address 
    input   logic   [31 : 0]    wd3,    // write data
    input   logic   [0  : 0]    we3,    // write enable signal
    input   logic   [4  : 0]    ra0,    // scan register address
    output  logic   [31 : 0]    rd0     // scan register data
);
    // creating register file
    logic   [31 : 0]    reg_file    [31 : 0];
    // getting read data 1 from register file
    assign  rd1 = ( ra1 == '0 ) ? '0 : reg_file[ra1];
    // getting read data 2 from register file
    assign  rd2 = ( ra2 == '0 ) ? '0 : reg_file[ra2];
    // for debug
    assign  rd0 = ( ra0 == '0 ) ? '0 : reg_file[ra0];
    // writing value in register file
    always_ff @(posedge clk)
        if( we3 )
            reg_file[wa3] <= wd3;

endmodule : nf_reg_file
