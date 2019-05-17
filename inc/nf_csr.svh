/*
*  File            :   nf_csr.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.16
*  Language        :   SystemVerilog
*  Description     :   This is CSR constants
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`define USTATUS_A   12'h000
`define UIE_A       12'h004
`define UTVEC_A     12'h005  
`define MCYCLE_A    12'hB00
`define PMPCFG0_A   12'h3A0
`define PMPCFG1_A   12'h3A1
`define PMPCFG2_A   12'h3A2
`define PMPCFG3_A   12'h3A3
`define PMPADDR0_A  12'h3B0
`define PMPADDR1_A  12'h3B1
`define PMPADDR2_A  12'h3B2
`define PMPADDR3_A  12'h3B3
`define PMPADDR4_A  12'h3B4
`define PMPADDR5_A  12'h3B5
`define PMPADDR6_A  12'h3B6
`define PMPADDR7_A  12'h3B7
`define PMPADDR8_A  12'h3B8
`define PMPADDR9_A  12'h3B9
`define PMPADDR10_A 12'h3BA
`define PMPADDR11_A 12'h3BB
`define PMPADDR12_A 12'h3BC
`define PMPADDR13_A 12'h3BD
`define PMPADDR14_A 12'h3BE
`define PMPADDR15_A 12'h3BF

typedef struct packed
{
    logic   [0  : 0]    L_WARL;
    logic   [2  : 0]    WIRI;  
    logic   [2  : 0]    A_WARL;
    logic   [0  : 0]    X_WARL;
    logic   [0  : 0]    W_WARL;
    logic   [0  : 0]    R_WARL;
} pmp_cfg_b;    // pmp_cfg_byte
