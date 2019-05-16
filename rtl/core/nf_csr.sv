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
    // 
    always_ff @(posedge clk, negedge resetn)
    begin
        if( ! resetn )
            csr_rd <= '0;
        else if( csr_rreq )
            csr_rd <= csr_rd_i;
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
