/*
*  File            :   nf_csr.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.16
*  Language        :   SystemVerilog
*  Description     :   This is CSR unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_csr.svh"
`include "../../inc/nf_cpu.svh"

module nf_csr
(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clk  
    input   logic   [0  : 0]    resetn,     // resetn
    // csr
    input   logic   [11 : 0]    csr_addr,   // csr address
    output  logic   [31 : 0]    csr_rd,     // csr read data
    input   logic   [31 : 0]    csr_wd,     // csr write data
    input   logic   [1  : 0]    csr_cmd,    // csr command
    input   logic   [0  : 0]    csr_wreq,   // csr write request
    input   logic   [0  : 0]    csr_rreq    // csr read request
);

    logic   [31 : 0]    ustatus;    // user status
    logic   [31 : 0]    uie;        // user interrupt-enable register
    logic   [31 : 0]    utvec;      // user trap handler base address
    logic   [31 : 0]    mcycle;     // Machine cycle counter
    logic   [31 : 0]    csr_rd_i;   // csr_rd internal
    logic   [31 : 0]    csr_wd_i;   // csr_wd internal

    logic   [31 : 0]    pmpaddr0;
    logic   [31 : 0]    pmpaddr1;
    logic   [31 : 0]    pmpaddr2;
    logic   [31 : 0]    pmpaddr3;
    logic   [31 : 0]    pmpaddr4;
    logic   [31 : 0]    pmpaddr5;
    logic   [31 : 0]    pmpaddr6;
    logic   [31 : 0]    pmpaddr7;
    logic   [31 : 0]    pmpaddr8;
    logic   [31 : 0]    pmpaddr9;
    logic   [31 : 0]    pmpaddr10;
    logic   [31 : 0]    pmpaddr11;
    logic   [31 : 0]    pmpaddr12;
    logic   [31 : 0]    pmpaddr13;
    logic   [31 : 0]    pmpaddr14;
    logic   [31 : 0]    pmpaddr15;

    pmp_cfg_b           pmp0cfg;
    pmp_cfg_b           pmp1cfg;
    pmp_cfg_b           pmp2cfg;
    pmp_cfg_b           pmp3cfg;
    pmp_cfg_b           pmp4cfg;
    pmp_cfg_b           pmp5cfg;
    pmp_cfg_b           pmp6cfg;
    pmp_cfg_b           pmp7cfg;
    pmp_cfg_b           pmp8cfg;
    pmp_cfg_b           pmp9cfg;
    pmp_cfg_b           pmp10cfg;
    pmp_cfg_b           pmp11cfg;
    pmp_cfg_b           pmp12cfg;
    pmp_cfg_b           pmp13cfg;
    pmp_cfg_b           pmp14cfg;
    pmp_cfg_b           pmp15cfg;
    
    assign csr_rd = csr_rd_i;

    // edit pmpcfg_0 register
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            { pmp0cfg , pmp1cfg , pmp2cfg , pmp3cfg } <= '0;
        else if( csr_wreq && ( csr_addr == `PMPCFG0_A ) )
            { pmp0cfg , pmp1cfg , pmp2cfg , pmp3cfg } <= csr_wd_i;
    end
    // edit pmpcfg_1 register
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            { pmp4cfg , pmp5cfg , pmp6cfg , pmp7cfg } <= '0;
        else if( csr_wreq && ( csr_addr == `PMPCFG1_A ) )
            { pmp4cfg , pmp5cfg , pmp6cfg , pmp7cfg } <= csr_wd_i;
    end
    // edit pmpcfg_2 register
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            { pmp8cfg , pmp9cfg , pmp10cfg , pmp11cfg } <= '0;
        else if( csr_wreq && ( csr_addr == `PMPCFG2_A ) )
            { pmp8cfg , pmp9cfg , pmp10cfg , pmp11cfg } <= csr_wd_i;
    end
    // edit pmpcfg_3 register
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            { pmp12cfg , pmp13cfg , pmp14cfg , pmp15cfg } <= '0;
        else if( csr_wreq && ( csr_addr == `PMPCFG3_A ) )
            { pmp12cfg , pmp13cfg , pmp14cfg , pmp15cfg } <= csr_wd_i;
    end
    // write csr data
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
        begin
            ustatus <= '0;
            uie     <= '0;
            utvec   <= '0;
        end
        else
        begin
            if( csr_wreq )
            begin
                case( csr_addr )
                    `USTATUS_A  :   ustatus <= csr_wd_i;
                    `UIE_A      :   uie     <= csr_wd_i;
                    `UTVEC_A    :   utvec   <= csr_wd_i;
                    default     :   ;
                endcase
            end
        end
    end
    // finding csr write data with command
    always_comb
    begin
        csr_wd_i = csr_wd;
        case( csr_cmd )
            CSR_NONE    :   csr_wd_i =   csr_wd;
            CSR_WR      :   csr_wd_i =   csr_wd;
            CSR_SET     :   csr_wd_i =   csr_wd | csr_rd_i;
            CSR_CLR     :   csr_wd_i = ~ csr_wd & csr_rd_i;
            default     :   ;
        endcase
    end
    // edit mcycle register
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            mcycle <= '0;
        else
            mcycle <= csr_wreq && ( csr_addr == `MCYCLE_A ) ? csr_wd_i : mcycle + 1'b1;
    end
    // find csr read data
    always_comb
    begin
        csr_rd_i = '0;
        case( csr_addr )
            `USTATUS_A  :   csr_rd_i = ustatus;
            `UIE_A      :   csr_rd_i = uie;
            `UTVEC_A    :   csr_rd_i = utvec;
            `MCYCLE_A   :   csr_rd_i = mcycle;
            default     :   ;
        endcase
    end

endmodule : nf_csr
