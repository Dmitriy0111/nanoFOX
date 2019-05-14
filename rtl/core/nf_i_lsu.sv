/*
*  File            :   nf_i_lsu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is instruction load store unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"
`include "../../inc/nf_cpu.svh"

module nf_i_lsu
(
    // clock and reset
    input   logic   [0  : 0]    clk,            // clock
    input   logic   [0  : 0]    resetn,         // reset
    // pipeline wires
    input   logic   [31 : 0]    result_imem,    // result from imem stage
    input   logic   [31 : 0]    rd2_imem,       // read data 2 from imem stage
    input   logic   [0  : 0]    we_dm_imem,     // write enable data memory from imem stage
    input   logic   [0  : 0]    rf_src_imem,    // register file source enable from imem stage
    input   logic   [0  : 0]    sign_dm_imem,
    input   logic   [1  : 0]    size_dm_imem,   // size data memory from imem stage
    output  logic   [31 : 0]    rd_dm_iwb,      // read data for write back stage
    output  logic   [0  : 0]    lsu_busy,       // load store unit busy
    // data memory and other's
    output  logic   [31 : 0]    addr_dm,        // address data memory
    input   logic   [31 : 0]    rd_dm,          // read data memory
    output  logic   [31 : 0]    wd_dm,          // write data memory
    output  logic   [0  : 0]    we_dm,          // write enable data memory signal
    output  logic   [1  : 0]    size_dm,        // size for load/store instructions
    output  logic   [0  : 0]    req_dm,         // request data memory signal
    input   logic   [0  : 0]    req_ack_dm      // request acknowledge data memory signal
);

    assign req_dm = lsu_busy;

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            lsu_busy <= '0;
        else 
        begin
            if( we_dm_imem || rf_src_imem )
                lsu_busy <= '1;
            if( req_ack_dm )
                lsu_busy <= '0;
        end
    end

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
        begin
            addr_dm <= '0;
            wd_dm   <= '0;
            we_dm   <= '0;
            size_dm <= '0;
        end
        else if( ( we_dm_imem || rf_src_imem ) && !lsu_busy )
        begin
            addr_dm <= result_imem;
            wd_dm   <= rd2_imem;
            we_dm   <= we_dm_imem;
            size_dm <= size_dm_imem;
        end
    end
    
    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            rd_dm_iwb <= '0;
        else if( req_ack_dm )
            case( size_dm )
                2'b00   : rd_dm_iwb <= { { 24 { rd_dm[ 7] && sign_dm_imem } } , rd_dm[7  : 0] };
                2'b01   : rd_dm_iwb <= { { 16 { rd_dm[15] && sign_dm_imem } } , rd_dm[15 : 0] };
                2'b10   : rd_dm_iwb <= rd_dm[31 : 0];
                default : rd_dm_iwb <= rd_dm[31 : 0];
            endcase
    end

endmodule : nf_i_lsu
