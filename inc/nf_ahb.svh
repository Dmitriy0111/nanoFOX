/*
*  File            :   nf_ahb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.30
*  Language        :   SystemVerilog
*  Description     :   This is AHB constatnts
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

// response constants
`define     AHB_HRESP_OKAY      2'b00
`define     AHB_HRESP_ERROR     2'b01
`define     AHB_HRESP_RETRY     2'b10
`define     AHB_HRESP_SPLIT     2'b11

// transfer constants
`define     AHB_HTRANS_IDLE     2'b00
`define     AHB_HTRANS_BUSY     2'b01
`define     AHB_HTRANS_NONSEQ   2'b10
`define     AHB_HTRANS_SEQ      2'b11

// burst constants
`define     AHB_HBUSRT_SINGLE   3'b000
`define     AHB_HBUSRT_INCR     3'b001
`define     AHB_HBUSRT_WRAP4    3'b010
`define     AHB_HBUSRT_INCR4    3'b011
`define     AHB_HBUSRT_WRAP8    3'b100
`define     AHB_HBUSRT_INCR8    3'b101
`define     AHB_HBUSRT_WRAP16   3'b110
`define     AHB_HBUSRT_INCR16   3'b111

// size constants
`define     AHB_HSIZE_B         3'b000
`define     AHB_HSIZE_HW        3'b001
`define     AHB_HSIZE_W         3'b010
`define     AHB_HSIZE_NU1       3'b011
`define     AHB_HSIZE_4W        3'b100
`define     AHB_HSIZE_8W        3'b101
`define     AHB_HSIZE_NU2       3'b110
`define     AHB_HSIZE_NU3       3'b111
