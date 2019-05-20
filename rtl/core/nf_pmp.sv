/*
*  File            :   nf_pmp.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.20
*  Language        :   SystemVerilog
*  Description     :   This is physical memory protection unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_csr.svh"
`include "../../inc/nf_cpu.svh"

module nf_pmp
(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clk  
    input   logic   [0  : 0]    resetn,     // resetn
    // pmp if
    input   logic   [11 : 0]    pmp_addr,   // pmp address
    output  logic   [31 : 0]    pmp_rd,     // pmp read data
    input   logic   [31 : 0]    pmp_wd,     // pmp write data
    input   logic   [0  : 0]    pmp_wreq,   // pmp write request
    input   logic   [0  : 0]    pmp_rreq,   // pmp read request
    // protect side
    input   logic   [31 : 0]    scan_addr,  // address for scan
    input   logic   [0  : 0]    scan_we,    // write enable for scan
    output  logic   [0  : 0]    pmp_ex      // pmp_exception
);


    logic           [3  : 0]    error_i;
    // pmp address regs
    logic   [3  : 0][31 : 0]    pmpaddr_i;
    logic           [31 : 0]    pmpaddr_out;
    // pmp config regs
    logic           [31 : 0]    pmp_cfg_out;
    pmp_cfg_b                   pmp0cfg;
    pmp_cfg_b                   pmp1cfg;
    pmp_cfg_b                   pmp2cfg;
    pmp_cfg_b                   pmp3cfg;

    assign error_i[0] = pmp0cfg.WIRI == `TOR ? ( ( pmpaddr_i[0] > scan_addr ) && ( pmpaddr_i[3] < scan_addr ) ) && ( ( ~ pmp0cfg.W_WARL ) && scan_we ) : '0;
    assign error_i[1] = pmp1cfg.WIRI == `TOR ? ( ( pmpaddr_i[1] > scan_addr ) && ( pmpaddr_i[0] < scan_addr ) ) && ( ( ~ pmp1cfg.W_WARL ) && scan_we ) : '0;
    assign error_i[2] = pmp2cfg.WIRI == `TOR ? ( ( pmpaddr_i[2] > scan_addr ) && ( pmpaddr_i[1] < scan_addr ) ) && ( ( ~ pmp2cfg.W_WARL ) && scan_we ) : '0;
    assign error_i[3] = pmp3cfg.WIRI == `TOR ? ( ( pmpaddr_i[3] > scan_addr ) && ( pmpaddr_i[2] < scan_addr ) ) && ( ( ~ pmp3cfg.W_WARL ) && scan_we ) : '0;
    assign pmp_ex = | error_i;

    // edit pmpcfg_0 register
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            { pmp3cfg , pmp2cfg , pmp1cfg , pmp0cfg } <= '0;
        else if( pmp_wreq && ( pmp_addr == `PMPCFG0_A ) )
            { pmp3cfg , pmp2cfg , pmp1cfg , pmp0cfg } <= pmp_wd;
    end
    // edit pmp address
    genvar  pmpaddr_reg;
    generate
        for(pmpaddr_reg = 0 ; pmpaddr_reg < 4 ; pmpaddr_reg++)
        begin : gen_pmpaddr_reg
            always_ff @(posedge clk, negedge resetn)
            begin
                if( ! resetn )
                    pmpaddr_i[pmpaddr_reg] <= '0;
                else if( pmp_wreq && ( pmp_addr == ( `PMPADDR0_A + pmpaddr_reg ) ) )
                    pmpaddr_i[pmpaddr_reg] <= pmp_wd;
            end
        end
    endgenerate
    // find pmp_address
    always_comb
    begin
        pmpaddr_out = pmpaddr_i[0];
        case( pmp_addr[3 : 0] )
            `PMPADDR0_A     :   pmpaddr_out = pmpaddr_i[ 0];
            `PMPADDR1_A     :   pmpaddr_out = pmpaddr_i[ 1];
            `PMPADDR2_A     :   pmpaddr_out = pmpaddr_i[ 2];
            `PMPADDR3_A     :   pmpaddr_out = pmpaddr_i[ 3];
            default         :   ;
        endcase
    end
    // find pmp_cfg read data
    always_comb
    begin
        pmp_cfg_out = { pmp3cfg , pmp2cfg , pmp1cfg , pmp0cfg };
        case( pmp_addr[1 : 0] )
            `PMPCFG0_A  :   pmp_cfg_out = { pmp3cfg  , pmp2cfg  , pmp1cfg  , pmp0cfg  };
            default     :   ;
        endcase
    end
    // find csr read data
    always_comb
    begin
        pmp_rd = pmp_cfg_out;
        case( pmp_addr )
            `PMPCFG0_A,
            `PMPCFG1_A,
            `PMPCFG2_A,
            `PMPCFG3_A      :   pmp_rd = pmp_cfg_out;
            `PMPADDR0_A,
            `PMPADDR1_A,
            `PMPADDR2_A,
            `PMPADDR3_A,
            `PMPADDR4_A,
            `PMPADDR5_A,
            `PMPADDR6_A,
            `PMPADDR7_A,
            `PMPADDR8_A,
            `PMPADDR9_A, 
            `PMPADDR10_A,
            `PMPADDR11_A,
            `PMPADDR12_A,
            `PMPADDR13_A,
            `PMPADDR14_A,
            `PMPADDR15_A    :   pmp_rd = pmpaddr_out;
            default     :   ;
        endcase
    end

endmodule : nf_pmp
