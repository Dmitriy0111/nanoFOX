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

    localparam  MASTER_0    = 2'b01,
                MASTER_1    = 2'b10,
                MASTER_NONE = 2'b00;

    logic   [1 : 0]     master_sel_out;
    logic   [1 : 0]     master_sel_in;
    logic   [0 : 0]     last_master;
    enum 
    logic   [1 : 0]     {M0_s, M1_s, M_NONE_s} state;

    assign req_ack_i  = master_sel_in == MASTER_0 ? req_ack_cc : '0;
    assign rd_i       = master_sel_in == MASTER_0 ? rd_cc      : '0;

    assign req_ack_dm = master_sel_in == MASTER_1 ? req_ack_cc : '0;
    assign rd_dm      = master_sel_in == MASTER_1 ? rd_cc      : '0;

    always_comb
    begin 
        req_cc  = '0;
        wd_cc   = '0;
        we_cc   = '0;
        addr_cc = '0;
        case( master_sel_out )
            MASTER_0       :   begin req_cc = req_i  ; wd_cc = wd_i  ; we_cc = we_i  ; addr_cc = addr_i  ; end
            MASTER_1       :   begin req_cc = req_dm ; wd_cc = wd_dm ; we_cc = we_dm ; addr_cc = addr_dm ; end
            MASTER_NONE    :   begin req_cc = '0     ; wd_cc = '0    ; we_cc = '0    ; addr_cc = '0      ; end
            default         :   ;
        endcase
    end

    always_ff @(posedge clk, negedge resetn)
    if( !resetn )
    begin
        master_sel_out <= MASTER_0;
        master_sel_in  <= MASTER_0;
        state <= M0_s;
        last_master <= '0;
    end
    else
    begin
        case( state )
            M0_s:
            begin
                if( req_dm )
                begin
                    state <= M_NONE_s;
                    last_master <= '0;
                    master_sel_out <= MASTER_NONE;
                end
            end
            M1_s:
            begin
                if( req_i )
                begin
                    state <= M_NONE_s;
                    last_master <= '1;
                    master_sel_out <= MASTER_NONE;
                end
            end
            M_NONE_s:
            begin
                if( ( ! req_ack_cc ) && (! last_master ) )
                begin
                    state <= M1_s;
                    master_sel_out <= MASTER_1;
                    master_sel_in  <= MASTER_1;
                end
                if( ( ! req_ack_cc ) && (  last_master ) )
                begin
                    state <= M0_s;
                    master_sel_out <= MASTER_0;
                    master_sel_in  <= MASTER_0;
                end
            end
        endcase
    end

endmodule : nf_cpu_cc
