/*
*  File            :   nf_cpu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`include "../inc/nf_hazard_unit.svh"

module nf_cpu
(
    // clock and reset
    input   logic               clk,
    input   logic               resetn,
    // instruction memory (IF)
    output  logic   [31 : 0]    addr_i,     // instruction address
    input   logic   [31 : 0]    rd_i,       // read instruction
    // data memory and other's
    output  logic   [31 : 0]    addr_dm,    // address data memory
    input   logic   [31 : 0]    rd_dm,      // read data memory
    output  logic   [31 : 0]    wd_dm,      // write data memory
    output  logic   [0  : 0]    we_dm,      // write enable signal
    output  logic   [0  : 0]    req_dm,     // request data memory signal
    input   logic   [0  : 0]    req_ack_dm  // request acknowledge data memory signal
`ifdef debug
    // for debug
    ,
    input   logic   [4  : 0]    reg_addr,   // register address
    output  logic   [31 : 0]    reg_data    // register data
`endif
);

    // program counter wires
    logic   [31 : 0]    pc_branch;
    logic   [0  : 0]    pc_src;
    logic   [0  : 0]    branch_type;
    // register file wires
    logic   [4  : 0]    wa3;
    logic   [31 : 0]    wd3;
    logic   [0  : 0]    we_rf;
    //hazard's wires
    logic   [1  : 0]    rd1_bypass;
    logic   [1  : 0]    rd2_bypass;
    logic   [1  : 0]    cmp_d1_bypass;
    logic   [1  : 0]    cmp_d2_bypass;
    logic   [31 : 0]    cmp_d1;
    logic   [31 : 0]    cmp_d2;
    logic   [0  : 0]    stall_if;
    logic   [0  : 0]    stall_id;
    logic   [0  : 0]    stall_iexe;
    logic   [0  : 0]    stall_imem;
    logic   [0  : 0]    stall_iwb;
    logic   [0  : 0]    flush_iexe;
    logic   [0  : 0]    flush_id;

    logic   [31 : 0]    rd1_i_exu;
    logic   [31 : 0]    rd2_i_exu;
    
    /*********************************************
    **         Instruction Fetch  stage         **
    *********************************************/
    // instruction fetch 1 stage
    logic   [31 : 0]    pc_if1;
    // instruction fetch 2 stage
    logic   [31 : 0]    pc_if2;
    logic   [0  : 0]    sel_id_instr;
    logic   [31 : 0]    instr_if2;
    logic   [0  : 0]    we_if2_stalled;
    logic   [31 : 0]    instr_if2_stalled;
    // creating one instruction fetch unit
    nf_i_fu nf_i_fu_0
    (
        // clock and reset
        .clk            ( clk               ),
        .resetn         ( resetn            ),
        // instruction fetch 1 stage
        .pc_if1         ( pc_if1            ),  // program counter from fetch 1 stage
        // instruction fetch 2 stage
        .pc_if2         ( pc_if2            ),  // program counter from fetch 2 stage
        // program counter inputs
        .pc_branch      ( pc_branch         ),  // program counter branch value from decode stage
        .pc_src         ( pc_src            ),  // next program counter source
        .stall_if       ( stall_if          ),  // for stalling instruction fetch 1 and 2 stage
        .flush_id       ( flush_id          )   // for flushing instruction decode stage
    );

    assign  addr_i          = pc_if1;                                   // from fetch 1 stage
    assign  instr_if2       = sel_id_instr ? instr_if2_stalled : rd_i;  // from fetch 2 stage
    assign  we_if2_stalled  = stall_id  && ( ~ sel_id_instr );          // for sw and branch stalls

    logic   [31 : 0]    instr_id;
    logic   [31 : 0]    pc_id;

    nf_register        #(  1 ) sel_id_ff        ( clk , resetn ,                             stall_id  , sel_id_instr      );
    nf_register_we_clr #( 32 ) instr_if2_stall  ( clk , resetn , we_if2_stalled , flush_id , rd_i      , instr_if2_stalled );
    nf_register_we_clr #( 32 ) instr_if2_id     ( clk , resetn , ~ stall_id     , flush_id , instr_if2 , instr_id          );
    nf_register_we_clr #( 32 ) pc_if2_id        ( clk , resetn , ~ stall_id     , flush_id , pc_if2    , pc_id             );

    /*********************************************
    **         Instruction Decode stage         **
    *********************************************/

    logic   [4  : 0]    wa3_id;
    logic   [4  : 0]    ra1_id;
    logic   [4  : 0]    ra2_id;
    logic   [31 : 0]    ext_data_id;
    logic   [31 : 0]    rd1_id;
    logic   [31 : 0]    rd2_id;
    logic   [0  : 0]    srcB_sel_id;
    logic   [0  : 0]    we_rf_id;
    logic   [0  : 0]    we_dm_id;
    logic   [0  : 0]    rf_src_id;
    logic   [31 : 0]    ALU_Code_id;
    logic   [4  : 0]    shamt_id;

    // next program counter value for branch command
    assign pc_branch  = pc_id + ( ext_data_id << 1 );

    // creating register file
    nf_reg_file reg_file_0
    (
        .clk            ( clk               ),
        .ra1            ( ra1_id            ),  // read address 1
        .rd1            ( rd1_id            ),  // read data 1
        .ra2            ( ra2_id            ),  // read address 2
        .rd2            ( rd2_id            ),  // read data 2
        .wa3            ( wa3               ),  // write address 
        .wd3            ( wd3               ),  // write data
        .we3            ( we_rf             )   // write enable signal
        `ifdef debug
        ,
        .ra0            ( reg_addr          ),  // read address 0
        .rd0            ( reg_data          )   // read data 0
        `endif
    );
    // creating instruction decode unit
    nf_i_du nf_i_du_0
    (
        .instr          ( instr_id          ),  // Instruction input
        .ext_data       ( ext_data_id       ),  // decoded extended data
        .srcB_sel       ( srcB_sel_id       ),  // decoded source B selection for ALU
        .ALU_Code       ( ALU_Code_id       ),  // decoded ALU code
        .shamt          ( shamt_id          ),  // decoded for shift command's
        .ra1            ( ra1_id            ),  // decoded read address 1 for register file
        .rd1            ( cmp_d1            ),  // read data 1 from register file
        .ra2            ( ra2_id            ),  // decoded read address 2 for register file
        .rd2            ( cmp_d2            ),  // read data 2 from register file
        .wa3            ( wa3_id            ),  // decoded write address 2 for register file
        .pc_src         ( pc_src            ),  // decoded next program counter value enable
        .we_rf          ( we_rf_id          ),  // decoded write register file
        .we_dm_en       ( we_dm_id          ),  // decoded write data memory
        .rf_src         ( rf_src_id         ),  // decoded source register file signal
        .branch_type    ( branch_type       )
    );

    // for debug
    logic   [31 : 0]    instr_iexe;
    nf_register_we_clr  #( 32 ) instr_id_iexe       ( clk , resetn , ~ stall_iexe , flush_iexe , instr_id    , instr_iexe    );

    logic   [4  : 0]    wa3_iexe;
    logic   [4  : 0]    ra1_iexe;
    logic   [4  : 0]    ra2_iexe;
    logic   [31 : 0]    ext_data_iexe;
    logic   [31 : 0]    rd1_iexe;
    logic   [31 : 0]    rd2_iexe;
    logic   [0  : 0]    srcB_sel_iexe;
    logic   [0  : 0]    we_rf_iexe;
    logic   [0  : 0]    we_dm_iexe;
    logic   [0  : 0]    rf_src_iexe;
    logic   [31 : 0]    ALU_Code_iexe;
    logic   [4  : 0]    shamt_iexe;
    logic   [31 : 0]    result_iexe;

    // data and address wires (not flushed)
    nf_register_we_clr  #( 5  ) wa3_id_iexe         ( clk , resetn , ~ stall_iexe , '0         , wa3_id      , wa3_iexe      );
    nf_register_we_clr  #( 5  ) ra1_id_iexe         ( clk , resetn , ~ stall_iexe , '0         , ra1_id      , ra1_iexe      );
    nf_register_we_clr  #( 5  ) ra2_id_iexe         ( clk , resetn , ~ stall_iexe , '0         , ra2_id      , ra2_iexe      );
    nf_register_we_clr  #( 5  ) shamt_id_iexe       ( clk , resetn , ~ stall_iexe , '0         , shamt_id    , shamt_iexe    );
    nf_register_we_clr  #( 32 ) sign_ex_id_iexe     ( clk , resetn , ~ stall_iexe , '0         , ext_data_id , ext_data_iexe );
    nf_register_we_clr  #( 32 ) rd1_id_iexe         ( clk , resetn , ~ stall_iexe , '0         , rd1_id      , rd1_iexe      );
    nf_register_we_clr  #( 32 ) rd2_id_iexe         ( clk , resetn , ~ stall_iexe , '0         , rd2_id      , rd2_iexe      );
    // control wires (flushed)
    nf_register_we_clr  #( 1  ) srcB_sel_id_iexe    ( clk , resetn , ~ stall_iexe , flush_iexe , srcB_sel_id , srcB_sel_iexe );
    nf_register_we_clr  #( 1  ) we_rf_id_iexe       ( clk , resetn , ~ stall_iexe , flush_iexe , we_rf_id    , we_rf_iexe    );
    nf_register_we_clr  #( 1  ) we_dm_id_iexe       ( clk , resetn , ~ stall_iexe , flush_iexe , we_dm_id    , we_dm_iexe    );
    nf_register_we_clr  #( 1  ) rf_src_id_iexe      ( clk , resetn , ~ stall_iexe , flush_iexe , rf_src_id   , rf_src_iexe   );
    nf_register_we_clr  #( 32 ) ALU_Code_id_iexe    ( clk , resetn , ~ stall_iexe , flush_iexe , ALU_Code_id , ALU_Code_iexe );

    /*********************************************
    **       Instruction execution stage        **
    *********************************************/
    // creating instruction execution unit
    nf_i_exu nf_i_exu_0
    (
        .rd1            ( rd1_i_exu         ),  // read data from reg file (port1)
        .rd2            ( rd2_i_exu         ),  // read data from reg file (port2)
        .ext_data       ( ext_data_iexe     ),  // sign extended immediate data
        .srcB_sel       ( srcB_sel_iexe     ),  // source enable signal for ALU
        .shamt          ( shamt_iexe        ),  // for shift operations
        .ALU_Code       ( ALU_Code_iexe     ),  // code for ALU
        .result         ( result_iexe       )   // result of ALU operation
    );

    /*********************************************
    **       Instruction memory stage           **
    *********************************************/
    //for debug
    logic   [31 : 0]    instr_imem;
    nf_register_we  #( 32 ) instr_iexe_imem     ( clk , resetn , ~ stall_imem , instr_iexe , instr_imem  );

    logic   [31 : 0]    result_imem;
    logic   [0  : 0]    we_dm_imem;
    logic   [31 : 0]    rd2_imem;
    logic   [0  : 0]    rf_src_imem;
    logic   [4  : 0]    wa3_imem;
    logic   [0  : 0]    we_rf_imem;

    nf_register_we  #( 1  ) we_dm_iexe_imem     ( clk , resetn , ~ stall_imem , we_dm_iexe  , we_dm_imem  );
    nf_register_we  #( 1  ) we_rf_iexe_imem     ( clk , resetn , ~ stall_imem , we_rf_iexe  , we_rf_imem  );
    nf_register_we  #( 1  ) rf_src_iexe_imem    ( clk , resetn , ~ stall_imem , rf_src_iexe , rf_src_imem );
    nf_register_we  #( 5  ) wa3_iexe_imem       ( clk , resetn , ~ stall_imem , wa3_iexe    , wa3_imem    );
    nf_register_we  #( 32 ) rd2_i_exu_imem      ( clk , resetn , ~ stall_imem , rd2_i_exu   , rd2_imem    );
    nf_register_we  #( 32 ) result_iexe_imem    ( clk , resetn , ~ stall_imem , result_iexe , result_imem );

    assign addr_dm  = result_imem;
    assign wd_dm    = rd2_imem;
    assign we_dm    = we_dm_imem;
    assign req_dm   = we_dm_imem || rf_src_imem;

    /*********************************************
    **       Instruction write back stage       **
    *********************************************/

    // for debug
    logic   [31 : 0]    instr_iwb;
    nf_register_we  #( 32 ) instr_imem_iwb  ( clk , resetn , ~ stall_iwb , instr_imem  , instr_iwb  );

    logic   [4  : 0]    wa3_iwb;
    logic   [0  : 0]    we_rf_iwb;
    logic   [0  : 0]    rf_src_iwb;
    logic   [31 : 0]    result_iwb;

    nf_register_we  #( 1  ) we_rf_imem_iwb  ( clk , resetn , ~ stall_iwb , we_rf_imem  , we_rf_iwb  );
    nf_register_we  #( 1  ) rf_src_imem_iwb ( clk , resetn , ~ stall_iwb , rf_src_imem , rf_src_iwb );
    nf_register_we  #( 5  ) wa3_imem_iwb    ( clk , resetn , ~ stall_iwb , wa3_imem    , wa3_iwb    );
    nf_register_we  #( 32 ) result_imem_iwb ( clk , resetn , ~ stall_iwb , result_imem , result_iwb );

    assign wa3   = wa3_iwb;
    assign wd3   = rf_src_iwb ? rd_dm : result_iwb;
    assign we_rf = we_rf_iwb;
    // creating hazard unit
    nf_hazard_unit nf_hazard_unit_0
    (
        // forwarding/bypassing
        .wa3_imem       ( wa3_imem      ),
        .we_rf_imem     ( we_rf_imem    ),
        .wa3_iwb        ( wa3_iwb       ),
        .we_rf_iwb      ( we_rf_iwb     ),
        .ra1_iexe       ( ra1_iexe      ),
        .ra2_iexe       ( ra2_iexe      ),
        .rd1_bypass     ( rd1_bypass    ),
        .rd2_bypass     ( rd2_bypass    ),
        .cmp_d1_bypass  ( cmp_d1_bypass ),
        .cmp_d2_bypass  ( cmp_d2_bypass ),
        // lw hazard stall and flush
        .wa3_iexe       ( wa3_iexe      ),
        .we_rf_iexe     ( we_rf_iexe    ),
        .rf_src_iexe    ( rf_src_iexe   ),
        .ra1_id         ( ra1_id        ),
        .ra2_id         ( ra2_id        ),
        .stall_if       ( stall_if      ),
        .stall_id       ( stall_id      ),
        .stall_iexe     ( stall_iexe    ),
        .stall_imem     ( stall_imem    ),
        .stall_iwb      ( stall_iwb     ),
        .flush_iexe     ( flush_iexe    ),
        .branch_type    ( branch_type   ),
        .we_dm_imem     ( we_dm_imem    ),
        .req_ack_dm     ( req_ack_dm    ),
        .rf_src_imem    ( rf_src_imem   )
    );

    assign cmp_d1 = cmp_d1_bypass ? result_imem : rd1_id;
    assign cmp_d2 = cmp_d2_bypass ? result_imem : rd2_id;

    always_comb
    begin
        rd1_i_exu = rd1_iexe;
        rd2_i_exu = rd2_iexe;
        case( rd1_bypass )
            `HU_BP_NONE : rd1_i_exu = rd1_iexe;
            `HU_BP_MEM  : rd1_i_exu = result_imem;
            `HU_BP_WB   : rd1_i_exu = result_iwb;
            default     : ;
        endcase
        case( rd2_bypass )
            `HU_BP_NONE : rd2_i_exu = rd2_iexe;
            `HU_BP_MEM  : rd2_i_exu = result_imem;
            `HU_BP_WB   : rd2_i_exu = result_iwb;
            default     : ;
        endcase
    end
    
endmodule : nf_cpu
