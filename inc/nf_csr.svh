/*
*  File            :   nf_csr.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.16
*  Language        :   SystemVerilog
*  Description     :   This is CSR constants
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`define MISA_A      12'h301
`define MTVEC_A     12'h305     // Machine trap-handler base address
`define MSCRATCH_A  12'h340     // Scratch register for machine trap handlers
`define MEPC_A      12'h341     // Machine exception program counter
`define MCAUSE_A    12'h342     // Machine trap cause
`define MTVAL_A     12'h343     // Machine bad address or instruction
`define MCYCLE_A    12'hB00     // Machine cycle counter
                    // MXL_WIRI_Extensions
`define MISA_V      32'b01_0000_00000000000000000100000000  // RV32I
