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

    logic   [1 : 0] master_sel;

    `define MASTER_0    2'b01
    `define MASTER_1    2'b10
    `define MASTER_NONE 2'b00

    always_comb
    begin 
        req_cc  = '0;
        wd_cc   = '0;
        we_cc   = '0;
        addr_cc = '0;
        case( master_sel )
            `MASTER_0       :   begin req_cc = req_i  ; wd_cc = wd_i  ; we_cc = we_i  ; addr_cc = addr_i  ; end
            `MASTER_1       :   begin req_cc = req_dm ; wd_cc = wd_dm ; we_cc = we_dm ; addr_cc = addr_dm ; end
            `MASTER_NONE    :   begin req_cc = '0     ; wd_cc = '0    ; we_cc = '0    ; addr_cc = '0      ; end
            default         :   ;
        endcase
    end

    assign req_ack_i  = master_sel == `MASTER_0 || master_sel == `MASTER_NONE ? req_ack_cc : '0;
    assign rd_i       = master_sel == `MASTER_0 || master_sel == `MASTER_NONE ? rd_cc      : '0;

    assign req_ack_dm = master_sel == `MASTER_1 ? req_ack_cc : '0;
    assign rd_dm      = master_sel == `MASTER_1 ? rd_cc      : '0;

    always_ff @(posedge clk, negedge resetn)
    if( !resetn )
    begin
        master_sel <= `MASTER_0;
    end
    else
    begin
        if( req_dm == '1 && master_sel != `MASTER_1 )
            master_sel <= `MASTER_NONE;
        if( master_sel == `MASTER_NONE && req_ack_i == '0 )
            master_sel <= `MASTER_1;
        if( req_dm == '0 )
            master_sel <= `MASTER_0;
    end

endmodule : nf_cpu_cc
