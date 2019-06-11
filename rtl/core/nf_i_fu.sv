/*
*  File            :   nf_i_fu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is instruction fetch unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"

module nf_i_fu
(
    // clock and reset
    input   logic   [0  : 0]    clk,            // clock
    input   logic   [0  : 0]    resetn,         // reset
    // program counter inputs   
    input   logic   [31 : 0]    pc_branch,      // program counter branch value from decode stage
    input   logic   [0  : 0]    pc_src,         // next program counter source
    input   logic   [0  : 0]    stall_if,       // stalling instruction fetch stage
    output  logic   [31 : 0]    instr_if,       // instruction fetch
    output  logic   [31 : 0]    last_pc,        // last program_counter
    input   logic   [31 : 0]    mtvec_v,        // machine trap-handler base address
    input   logic   [0  : 0]    m_ret,          // m return
    input   logic   [31 : 0]    m_ret_pc,       // m return pc value
    output  logic   [0  : 0]    addr_misalign,  // address misaligned
    input   logic   [0  : 0]    lsu_err,        // load store unit error
    // memory inputs/outputs
    output  logic   [31 : 0]    addr_i,         // address instruction memory
    input   logic   [31 : 0]    rd_i,           // read instruction memory
    output  logic   [31 : 0]    wd_i,           // write instruction memory
    output  logic   [0  : 0]    we_i,           // write enable instruction memory signal
    output  logic   [1  : 0]    size_i,         // size for load/store instructions
    output  logic   [0  : 0]    req_i,          // request instruction memory signal
    input   logic   [0  : 0]    req_ack_i       // request acknowledge instruction memory signal
);

    logic   [0  : 0]    flush_id;               // for flushing instruction decode stage
    // instruction fetch stage
    logic   [0  : 0]    sel_if_instr;           // selected instruction 
    logic   [0  : 0]    we_if_stalled;          // write enable for stall ( fetch stage )
    logic   [31 : 0]    instr_if_stalled;       // stalled instruction ( fetch stage )
    // program counters values
    logic   [31 : 0]    pc_i;                   // program counter value
    logic   [31 : 0]    pc_not_branch;          // program counter not branch value
    // flush instruction decode 
    logic   [0  : 0]    flush_id_branch;        // flush id stage ( branch operation )
    logic   [0  : 0]    flush_id_ff;            // flush id stage after branch, reset, lsu error and address misaligned
    logic   [0  : 0]    flush_id_sw_instr;      // flush id stage ( store data instruction )
    // working with instruction fetch instruction (stalled and not stalled)
    assign instr_if      = flush_id ? '0 : ( sel_if_instr ? instr_if_stalled : rd_i );  // from fetch stage
    assign we_if_stalled = stall_if  && ( ~ sel_if_instr );  // for sw and branch stalls
    // finding pc not branch value
    assign pc_not_branch = addr_i + 4;
    // finding flush instruction decode signals
    assign flush_id_sw_instr = ~ req_ack_i;
    assign flush_id_branch = ( pc_src && ( ~ stall_if ) ) || m_ret;
    assign flush_id = flush_id_ff || flush_id_branch || flush_id_sw_instr || addr_misalign;
    // setting instruction interface signals
    assign req_i  = '1;
    assign we_i   = '0;
    assign wd_i   = '0;
    assign size_i = 2'b10;  // word
    
    assign addr_misalign = addr_i[1 : 0] != '0;
    // finding next program counter value
    always_comb
    begin
        pc_i = pc_not_branch;
        casex( {m_ret, addr_misalign || lsu_err , pc_src} )
            3'b000   :   pc_i = pc_not_branch;
            3'b001   :   pc_i = pc_branch;
            3'b01?   :   pc_i = mtvec_v;
            3'b1??   :   pc_i = m_ret_pc;
        endcase
    end
    //
    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            flush_id_ff <= '1; // flushing if-id after reset
        else
        begin
            flush_id_ff <= '0;
            if( flush_id_branch || addr_misalign || lsu_err )
                flush_id_ff <= '1; // set if branch and stall instruction fetch
        end
    // selecting instruction fetch stage instruction
    nf_register         #( 1  ) sel_id_ff               ( clk , resetn ,                 stall_if , sel_if_instr     );
    // stalled instruction fetch instruction
    nf_register_we      #( 32 ) instr_if_stall          ( clk , resetn , we_if_stalled , rd_i     , instr_if_stalled );
    // creating program counter and last pc
    nf_register_we      #( 32 ) last_pc_ff              ( clk , resetn , ~ stall_if    , addr_i   , last_pc          );
    nf_register_we_r    
    #( 
        .width      ( 32            ), 
        .rst_val    ( `PROG_START   ) 
    ) 
    PC
    ( 
        .clk        ( clk           ), 
        .resetn     ( resetn        ), 
        .we         ( ~ stall_if    ), 
        .datai      ( pc_i          ), 
        .datao      ( addr_i        )
    );

endmodule : nf_i_fu
