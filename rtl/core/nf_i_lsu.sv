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
    input   logic   [0  : 0]    sign_dm_imem,   // sign for load operations
    input   logic   [1  : 0]    size_dm_imem,   // size data memory from imem stage
    output  logic   [31 : 0]    rd_dm_iwb,      // read data for write back stage
    output  logic   [0  : 0]    lsu_busy,       // load store unit busy
    output  logic   [0  : 0]    lsu_err,        // load store error
    output  logic   [0  : 0]    s_misaligned,   // store misaligned
    output  logic   [0  : 0]    l_misaligned,   // load misaligned
    input   logic   [0  : 0]    stall_if,       // stall instruction fetch
    // data memory and other's
    output  logic   [31 : 0]    addr_dm,        // address data memory
    input   logic   [31 : 0]    rd_dm,          // read data memory
    output  logic   [31 : 0]    wd_dm,          // write data memory
    output  logic   [0  : 0]    we_dm,          // write enable data memory signal
    output  logic   [1  : 0]    size_dm,        // size for load/store instructions
    output  logic   [0  : 0]    req_dm,         // request data memory signal
    input   logic   [0  : 0]    req_ack_dm      // request acknowledge data memory signal
);

    // load data wires
    logic   [7  : 0]    l_data_3;   // load data 3
    logic   [7  : 0]    l_data_2;   // load data 2
    logic   [7  : 0]    l_data_1;   // load data 1
    logic   [7  : 0]    l_data_0;   // load data 0
    logic   [31 : 0]    l_data_f;   // full load data
    // store data wires
    logic   [7  : 0]    s_data_3;   // store data 3
    logic   [7  : 0]    s_data_2;   // store data 2
    logic   [7  : 0]    s_data_1;   // store data 1
    logic   [7  : 0]    s_data_0;   // store data 0
    logic   [31 : 0]    s_data_f;   // full store data
    logic   [0  : 0]    lsu_err_ff; // load store unit error sequential
    logic   [0  : 0]    lsu_err_c;  // load store unit error combinational

    logic   [0  : 0]    sign_dm;    // unsigned load data memory?
    logic   [0  : 0]    misaligned; // load or store address misaligned

    assign misaligned = ( ( ( size_dm_imem == 2'b10 ) && ( result_imem[1 : 0] != '0 ) ) || ( ( size_dm_imem == 2'b01 ) && ( result_imem[0 : 0] != '0 ) ) );
    assign s_misaligned = misaligned && we_dm_imem;
    assign l_misaligned = misaligned && rf_src_imem;
    assign lsu_err_c = s_misaligned || l_misaligned;
    assign lsu_err = lsu_err_c || lsu_err_ff;
    assign req_dm = lsu_busy;
    assign l_data_f = { l_data_3 , l_data_2 , l_data_1 , l_data_0 };
    assign s_data_f = { s_data_3 , s_data_2 , s_data_1 , s_data_0 };

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            lsu_err_ff <= '0;
        else
        begin
            if( lsu_err_c )
                lsu_err_ff <= '1;
            if( !stall_if )
                lsu_err_ff <= '0;
        end

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            lsu_busy <= '0;
        else 
        begin
            if( ( we_dm_imem || rf_src_imem ) && !lsu_err_c )
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
            sign_dm <= '0;
        end
        else if( ( we_dm_imem || rf_src_imem ) && !lsu_busy )
        begin
            addr_dm <= result_imem;
            wd_dm   <= s_data_f;
            we_dm   <= we_dm_imem;
            size_dm <= size_dm_imem;
            sign_dm <= sign_dm_imem;
        end
    end
    // form load data value
    always_comb
    begin
        l_data_3 = rd_dm[24 +: 8];
        l_data_2 = rd_dm[16 +: 8];
        l_data_1 = rd_dm[8  +: 8];
        l_data_0 = rd_dm[0  +: 8];
        case( addr_dm[0 +: 2])
            2'b00   : l_data_0 = rd_dm[0  +: 8];
            2'b01   : l_data_0 = rd_dm[8  +: 8];
            2'b10   : l_data_0 = rd_dm[16 +: 8];
            2'b11   : l_data_0 = rd_dm[24 +: 8];
            default : ;
        endcase
        case( addr_dm[0 +: 2])
            2'b00   : l_data_1 = rd_dm[8  +: 8];
            2'b01   : l_data_1 = rd_dm[8  +: 8];
            2'b10   : l_data_1 = rd_dm[24 +: 8];
            2'b11   : l_data_1 = rd_dm[24 +: 8];
            default : ;
        endcase
    end
    // form store data value
    always_comb
    begin
        s_data_3 = rd2_imem[24 +: 8];
        s_data_2 = rd2_imem[16 +: 8];
        s_data_1 = rd2_imem[8  +: 8];
        s_data_0 = rd2_imem[0  +: 8];
        case( result_imem[0 +: 2])
            2'b00   : s_data_1 = rd2_imem[8  +: 8];
            2'b01   : s_data_1 = rd2_imem[0  +: 8];
            default : ;
        endcase
        case( result_imem[0 +: 2])
            2'b00   : s_data_2 = rd2_imem[16 +: 8];
            2'b10   : s_data_2 = rd2_imem[0  +: 8];
            default : ;
        endcase
        case( result_imem[0 +: 2])
            2'b00   : s_data_3 = rd2_imem[24 +: 8];
            2'b10   : s_data_3 = rd2_imem[8  +: 8];
            2'b11   : s_data_3 = rd2_imem[0  +: 8];
            default : ;
        endcase
    end
    
    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            rd_dm_iwb <= '0;
        else if( req_ack_dm )
            case( size_dm )
                2'b00   : rd_dm_iwb <= { { 24 { l_data_f[ 7] && sign_dm } } , l_data_f[7  : 0] };
                2'b01   : rd_dm_iwb <= { { 16 { l_data_f[15] && sign_dm } } , l_data_f[15 : 0] };
                2'b10   : rd_dm_iwb <= l_data_f[31 : 0];
                default : rd_dm_iwb <= l_data_f[31 : 0];
            endcase
    end

endmodule : nf_i_lsu
