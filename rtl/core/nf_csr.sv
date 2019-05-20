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
    // pmp
    output  logic   [11 : 0]    pmp_addr,   // csr address
    input   logic   [31 : 0]    pmp_rd,     // csr read data
    output  logic   [31 : 0]    pmp_wd,     // csr write data
    output  logic   [0  : 0]    pmp_wreq,   // csr write request
    output  logic   [0  : 0]    pmp_rreq,   // csr read request
    // scan wires
    input   logic   [0  : 0]    pmp_err,    // pmp_error
    input   logic   [31 : 0]    scan_addr   // address for scan
);

    logic   [31 : 0]    ustatus;    // user status
    logic   [31 : 0]    uie;        // user interrupt-enable register
    logic   [31 : 0]    utvec;      // user trap handler base address
    logic   [31 : 0]    mcycle;     // Machine cycle counter
    logic   [31 : 0]    csr_rd_i;   // csr_rd internal
    logic   [31 : 0]    csr_wd_i;   // csr_wd internal
    logic   [31 : 0]    s_out;      // supervisor output
    logic   [31 : 0]    u_out;      // user output
    logic   [31 : 0]    sepc;       // supervisor exception program counter
    logic   [31 : 0]    scause;     // supervisor cause register
    
    assign csr_rd = csr_rd_i;

    assign pmp_addr = csr_addr;
    assign pmp_wd   = csr_wd_i;
    assign pmp_wreq = csr_wreq;
    assign pmp_rreq = csr_rreq;
    // loading data in supervisor cause register
    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            scause <= '0;
        else if( pmp_err )
            scause <= 32'h00000005;
    // loading data in supervisor exception program counter
    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            sepc <= '0;
        else if( pmp_err )
            sepc <= scan_addr;
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
    // find s_out read data
    always_comb
    begin
        s_out = '0;
        case( csr_addr )
            `SEPC_A         :   s_out = sepc;
            `SCAUSE_A       :   s_out = scause;
            default         :   ;
        endcase
    end
    // find u_out read data
    always_comb
    begin
        u_out = '0;
        case( csr_addr )
            `USTATUS_A      :   u_out = ustatus;
            `UIE_A          :   u_out = uie;
            `UTVEC_A        :   u_out = utvec;
            default         :   ;
        endcase
    end
    // find csr read data
    always_comb
    begin
        csr_rd_i = '0;
        case( csr_addr )
            `USTATUS_A,
            `UIE_A,
            `UTVEC_A        :   csr_rd_i = u_out;
            `MCYCLE_A       :   csr_rd_i = mcycle;
            `PMPCFG0_A,
            `PMPCFG1_A,
            `PMPCFG2_A,
            `PMPCFG3_A,
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
            `PMPADDR15_A    :   csr_rd_i = pmp_rd;
            `SEPC_A,
            `SCAUSE_A       :   csr_rd_i = s_out;
            `MISA_A         :   csr_rd_i = `MISA_V; // read only
            default         :   ;
        endcase
    end

endmodule : nf_csr
