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
    input   logic   [0  : 0]    csr_rreq,   // csr read request
    //
    output  logic   [31 : 0]    mtvec_v     // value of mtvec
);

    logic   [31 : 0]    csr_rd_i;   // csr_rd internal
    logic   [31 : 0]    csr_wd_i;   // csr_wd internal
    logic   [31 : 0]    mcycle;     // Machine cycle counter
    logic   [31 : 0]    mtvec;      // Machine trap-handler base address
    logic   [31 : 0]    mscratch;   // Scratch register for machine trap handlers
    logic   [31 : 0]    mepc;       // Machine exception program counter
    logic   [31 : 0]    mcause;     // Machine trap cause
    logic   [31 : 0]    mtval;      // Machine bad address or instruction

    logic   [31 : 0]    m_out0;     // Machine out
    logic   [31 : 0]    m_out1;     // Machine out

    assign mtvec_v = mtvec;         // value of mtvec
    
    assign csr_rd = csr_rd_i;

    // write mscratch data
    always_ff @(posedge clk, negedge resetn)
        if( ! resetn )
            mscratch <= '0;
        else 
            if( csr_wreq && ( csr_addr == `MSCRATCH_A ) )
                mscratch <= csr_wd_i;
    // write mtvec data
    always_ff @(posedge clk, negedge resetn)
        if( ! resetn )
            mtvec <= '0;
        else 
            if( csr_wreq && ( csr_addr == `MTVEC_A ) )
                mtvec <= csr_wd_i;
    // edit mcycle register
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            mcycle <= '0;
        else
            mcycle <= csr_wreq && ( csr_addr == `MCYCLE_A ) ? csr_wd_i : mcycle + 1'b1;
    end
    // finding csr write data with command
    always_comb
    begin
        csr_wd_i = '0;
        case( csr_cmd )
            CSR_NONE    :   csr_wd_i =   csr_wd;
            CSR_WR      :   csr_wd_i =   csr_wd;
            CSR_SET     :   csr_wd_i =   csr_wd | csr_rd_i;
            CSR_CLR     :   csr_wd_i = ~ csr_wd & csr_rd_i;
            default     :   ;
        endcase
    end
    // find csr read data
    always_comb
    begin
        m_out0 = '0;
        case( csr_addr )
            `MCYCLE_A       :   m_out0 = mcycle;
            `MISA_A         :   m_out0 = `MISA_V; // read only
            `MSCRATCH_A     :   m_out0 = mscratch;
            `MTVEC_A        :   m_out0 = mtvec_v;
            default         :   ;
        endcase
    end
    // find csr read data
    always_comb
    begin
        m_out1 = '0;
        case( csr_addr )
            `MEPC_A         :   m_out1 = mepc;
            `MCAUSE_A       :   m_out1 = mcause;
            `MTVAL_A        :   m_out1 = mtval;
            default         :   ;
        endcase
    end
    // find csr read data
    always_comb
    begin
        csr_rd_i = '0;
        case( csr_addr )
            `MCYCLE_A,
            `MISA_A,
            `MSCRATCH_A,
            `MTVEC_A        :   csr_rd_i = m_out0;
            `MEPC_A,
            `MCAUSE_A,
            `MTVAL_A        :   csr_rd_i = m_out1;
            default         :   ;
        endcase
    end

endmodule : nf_csr
