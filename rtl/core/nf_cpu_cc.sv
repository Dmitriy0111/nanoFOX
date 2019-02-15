/*
*  File            :   nf_cpu_cc.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.15
*  Language        :   SystemVerilog
*  Description     :   This is cpu cross connect unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_cpu_cc
(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    resetn,     // resetn
    // instruction memory (IF)
    input   logic   [31 : 0]    addr_i,     // address instruction memory
    output  logic   [31 : 0]    rd_i,       // read instruction memory
    input   logic   [31 : 0]    wd_i,       // write instruction memory
    input   logic   [0  : 0]    we_i,       // write enable instruction memory signal
    input   logic   [0  : 0]    req_i,      // request instruction memory signal
    output  logic   [0  : 0]    req_ack_i,  // request acknowledge instruction memory signal
    // data memory and other's
    input   logic   [31 : 0]    addr_dm,    // address data memory
    output  logic   [31 : 0]    rd_dm,      // read data memory
    input   logic   [31 : 0]    wd_dm,      // write data memory
    input   logic   [0  : 0]    we_dm,      // write enable data memory signal
    input   logic   [0  : 0]    req_dm,     // request data memory signal
    output  logic   [0  : 0]    req_ack_dm, // request acknowledge data memory signal
    // cross connect data
    output  logic   [31 : 0]    addr_cc,    // address cc_data memory
    input   logic   [31 : 0]    rd_cc,      // read cc_data memory
    output  logic   [31 : 0]    wd_cc,      // write cc_data memory
    output  logic   [0  : 0]    we_cc,      // write enable cc_data memory signal
    output  logic   [0  : 0]    req_cc,     // request cc_data memory signal
    input   logic   [0  : 0]    req_ack_cc  // request acknowledge cc_data memory signal
);

    assign addr_cc     = addr_i;
    assign rd_i        = rd_cc;
    assign wd_cc       = wd_i;
    assign we_cc       = we_i;
    assign req_cc      = req_i;
    assign req_ack_i   = req_ack_cc;

endmodule : nf_cpu_cc
