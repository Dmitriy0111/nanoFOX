/*
*  File            :   nf_settings.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is file with common settings
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`define debug 1

`define RV32I

`ifdef RV32I
`define reg_number 32
`endif

`ifdef RV32E
`define reg_number 16
`endif

`ifndef reg_number
`define reg_number 32
`endif
