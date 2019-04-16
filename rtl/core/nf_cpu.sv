/*
*  File            :   nf_cpu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"
`include "../../inc/nf_cpu.svh"

module nf_cpu
#(
    parameter                   ver = "1.1"
)(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clk  
    input   logic   [0  : 0]    resetn,     // resetn
    // instruction memory (IF)
    output  logic   [31 : 0]    addr_i,     // address instruction memory
    input   logic   [31 : 0]    rd_i,       // read instruction memory
    output  logic   [31 : 0]    wd_i,       // write instruction memory
    output  logic   [0  : 0]    we_i,       // write enable instruction memory signal
    output  logic   [1  : 0]    size_i,     // size for load/store instructions
    output  logic   [0  : 0]    req_i,      // request instruction memory signal
    input   logic   [0  : 0]    req_ack_i,  // request acknowledge instruction memory signal
    // data memory and other's
    output  logic   [31 : 0]    addr_dm,    // address data memory
    input   logic   [31 : 0]    rd_dm,      // read data memory
    output  logic   [31 : 0]    wd_dm,      // write data memory
    output  logic   [0  : 0]    we_dm,      // write enable data memory signal
    output  logic   [1  : 0]    size_dm,    // size for load/store instructions
    output  logic   [0  : 0]    req_dm,     // request data memory signal
    input   logic   [0  : 0]    req_ack_dm  // request acknowledge data memory signal
);

    // program counter wires
    logic   [31 : 0]    pc_branch;          // program counter branch value
    logic   [0  : 0]    pc_src;             // program counter source
    logic   [3  : 0]    branch_type;        // branch type
    // register file wires
    logic   [4  : 0]    wa3;                // write address for register file
    logic   [31 : 0]    wd3;                // write data for register file
    logic   [0  : 0]    we_rf;              // write enable for register file
    //hazard's wires
    logic   [31 : 0]    cmp_d1;             // compare data 1 ( bypass unit )
    logic   [31 : 0]    cmp_d2;             // compare data 2 ( bypass unit )
    logic   [0  : 0]    stall_if;           // stall fetch stage
    logic   [0  : 0]    stall_id;           // stall decode stage
    logic   [0  : 0]    stall_iexe;         // stall execution stage
    logic   [0  : 0]    stall_imem;         // stall memory stage
    logic   [0  : 0]    stall_iwb;          // stall write back stage
    logic   [0  : 0]    flush_iexe;         // flush execution stage

    logic   [31 : 0]    rd1_i_exu;          // data for execution stage ( bypass unit )
    logic   [31 : 0]    rd2_i_exu;          // data for execution stage ( bypass unit )
    
    /*********************************************
    **         Instruction Fetch  stage         **
    *********************************************/
    logic   [31 : 0]    instr_if;           // instruction fetch
    // creating one instruction fetch unit
    nf_i_fu 
    nf_i_fu_0
    (
        // clock and reset
        .clk            ( clk               ),  // clock
        .resetn         ( resetn            ),  // reset
        // program counter inputs
        .pc_branch      ( pc_branch         ),  // program counter branch value from decode stage
        .pc_src         ( pc_src            ),  // next program counter source
        .branch_type    ( branch_type       ),  // branch type
        .stall_if       ( stall_if          ),  // stalling instruction fetch stage
        .instr_if       ( instr_if          ),  // instruction fetch
        // memory inputs/outputs
        .addr_i         ( addr_i            ),  // address instruction memory
        .rd_i           ( rd_i              ),  // read instruction memory
        .wd_i           ( wd_i              ),  // write instruction memory
        .we_i           ( we_i              ),  // write enable instruction memory signal
        .size_i         ( size_i            ),  // size for load/store instructions
        .req_i          ( req_i             ),  // request instruction memory signal
        .req_ack_i      ( req_ack_i         )   // request acknowledge instruction memory signal
    );

    logic   [31 : 0]    instr_id;           // instruction ( decode stage )
    logic   [31 : 0]    pc_id;              // program counter ( decode stage )

    nf_register_we  #( 32 ) instr_if_id     ( clk , resetn , ~ stall_id , instr_if , instr_id );
    nf_register_we  #( 32 ) pc_if_id        ( clk , resetn , ~ stall_id , addr_i   , pc_id    );

    /*********************************************
    **         Instruction Decode stage         **
    *********************************************/

    logic   [4  : 0]    wa3_id;             // write address for register file ( decode stage )
    logic   [4  : 0]    ra1_id;             // read address 1 from register file ( decode stage )
    logic   [4  : 0]    ra2_id;             // read address 2 from register file ( decode stage )
    logic   [31 : 0]    ext_data_id;        // extended immediate data ( decode stage )
    logic   [31 : 0]    rd1_id;             // read data 1 from register file ( decode stage )
    logic   [31 : 0]    rd2_id;             // read data 2 from register file ( decode stage )
    logic   [0  : 0]    srcB_sel_id;        // source B selection ( decode stage )
    logic   [0  : 0]    res_sel_id;         // result select ( decode stage )
    logic   [0  : 0]    we_rf_id;           // write enable register file ( decode stage )
    logic   [0  : 0]    we_dm_id;           // write enable data memory ( decode stage )
    logic   [0  : 0]    rf_src_id;          // register file source ( decode stage )
    logic   [31 : 0]    ALU_Code_id;        // code for execution unit ( decode stage )
    logic   [4  : 0]    shamt_id;           // shift value for execution unit ( decode stage )
    logic   [0  : 0]    branch_src;         // program counter selection
    logic   [1  : 0]    size_dm_id;         // size for load/store instructions ( decode stage )

    // next program counter value for branch command
    assign pc_branch  = ~ branch_src ? pc_id + ( ext_data_id << 1 ) - 4 : rd1_id + ( ext_data_id << 1 );

    // creating register file
    nf_reg_file 
    nf_reg_file_0
    (
        .clk            ( clk               ),  // clock
        .ra1            ( ra1_id            ),  // read address 1
        .rd1            ( rd1_id            ),  // read data 1
        .ra2            ( ra2_id            ),  // read address 2
        .rd2            ( rd2_id            ),  // read data 2
        .wa3            ( wa3               ),  // write address 
        .wd3            ( wd3               ),  // write data
        .we3            ( we_rf             )   // write enable signal
    );
    // creating instruction decode unit
    nf_i_du 
    nf_i_du_0
    (
        .instr          ( instr_id          ),  // Instruction input
        .ext_data       ( ext_data_id       ),  // decoded extended data
        .srcB_sel       ( srcB_sel_id       ),  // decoded source B selection for ALU
        .res_sel        ( res_sel_id        ),  // for selecting result
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
        .size_dm        ( size_dm_id        ),  // size for load/store instructions
        .branch_src     ( branch_src        ),  // for selecting branch source (JALR)
        .branch_type    ( branch_type       )   // branch type
    );

    // for verification
    // synthesis translate_off
    logic   [31 : 0]    instr_iexe;         // instruction ( execution stage )
    nf_register_we_clr  #( 32 ) instr_id_iexe       ( clk , resetn , ~ stall_iexe , flush_iexe , instr_id    , instr_iexe    );
    // synthesis translate_on

    logic   [4  : 0]    wa3_iexe;           // write address for register file ( execution stage )
    logic   [4  : 0]    ra1_iexe;           // read address 1 from register file ( execution stage )
    logic   [4  : 0]    ra2_iexe;           // read address 2 from register file ( execution stage )
    logic   [31 : 0]    ext_data_iexe;      // extended immediate data ( execution stage )
    logic   [31 : 0]    rd1_iexe;           // read data 1 from register file ( execution stage )
    logic   [31 : 0]    rd2_iexe;           // read data 2 from register file ( execution stage )
    logic   [31 : 0]    pc_iexe;            // program counter value ( execution stage )
    logic   [0  : 0]    srcB_sel_iexe;      // source B selection ( execution stage )
    logic   [0  : 0]    res_sel_iexe;       // result select ( execution stage )
    logic   [0  : 0]    we_rf_iexe;         // write enable register file ( execution stage )
    logic   [0  : 0]    we_dm_iexe;         // write enable data memory ( execution stage )
    logic   [0  : 0]    rf_src_iexe;        // register file source ( execution stage )
    logic   [31 : 0]    ALU_Code_iexe;      // code for execution unit ( execution stage )
    logic   [4  : 0]    shamt_iexe;         // shift value for execution unit ( execution stage )
    logic   [1  : 0]    size_dm_iexe;       // size for load/store instructions ( execution stage )
    logic   [31 : 0]    result_iexe;        // result from execution unit ( execution stage )
    logic   [31 : 0]    result_iexe_e;      // selected result ( execution stage )

    assign result_iexe_e = res_sel_iexe  == RES_ALU  ? result_iexe : pc_iexe;

    // data and address wires (flushed)
    nf_register_we_clr  #( 5  ) wa3_id_iexe         ( clk , resetn , ~ stall_iexe , flush_iexe , wa3_id      , wa3_iexe      );
    nf_register_we_clr  #( 5  ) ra1_id_iexe         ( clk , resetn , ~ stall_iexe , flush_iexe , ra1_id      , ra1_iexe      );
    nf_register_we_clr  #( 5  ) ra2_id_iexe         ( clk , resetn , ~ stall_iexe , flush_iexe , ra2_id      , ra2_iexe      );
    nf_register_we_clr  #( 5  ) shamt_id_iexe       ( clk , resetn , ~ stall_iexe , flush_iexe , shamt_id    , shamt_iexe    );
    nf_register_we_clr  #( 32 ) sign_ex_id_iexe     ( clk , resetn , ~ stall_iexe , flush_iexe , ext_data_id , ext_data_iexe );
    nf_register_we_clr  #( 32 ) rd1_id_iexe         ( clk , resetn , ~ stall_iexe , flush_iexe , rd1_id      , rd1_iexe      );
    nf_register_we_clr  #( 32 ) rd2_id_iexe         ( clk , resetn , ~ stall_iexe , flush_iexe , rd2_id      , rd2_iexe      );
    nf_register_we_clr  #( 32 ) pc_id_iexe          ( clk , resetn , ~ stall_iexe , flush_iexe , pc_id       , pc_iexe       );
    nf_register_we_clr  #( 2  ) size_dm_id_iexe     ( clk , resetn , ~ stall_iexe , flush_iexe , size_dm_id  , size_dm_iexe  );
    // control wires (flushed)
    nf_register_we_clr  #( 1  ) srcB_sel_id_iexe    ( clk , resetn , ~ stall_iexe , flush_iexe , srcB_sel_id , srcB_sel_iexe );
    nf_register_we_clr  #( 1  ) res_sel_id_iexe     ( clk , resetn , ~ stall_iexe , flush_iexe , res_sel_id  , res_sel_iexe  );
    nf_register_we_clr  #( 1  ) we_rf_id_iexe       ( clk , resetn , ~ stall_iexe , flush_iexe , we_rf_id    , we_rf_iexe    );
    nf_register_we_clr  #( 1  ) we_dm_id_iexe       ( clk , resetn , ~ stall_iexe , flush_iexe , we_dm_id    , we_dm_iexe    );
    nf_register_we_clr  #( 1  ) rf_src_id_iexe      ( clk , resetn , ~ stall_iexe , flush_iexe , rf_src_id   , rf_src_iexe   );
    nf_register_we_clr  #( 32 ) ALU_Code_id_iexe    ( clk , resetn , ~ stall_iexe , flush_iexe , ALU_Code_id , ALU_Code_iexe );

    /*********************************************
    **       Instruction execution stage        **
    *********************************************/
    // creating instruction execution unit
    nf_i_exu 
    nf_i_exu_0
    (
        .rd1            ( rd1_i_exu         ),  // read data from reg file (port1)
        .rd2            ( rd2_i_exu         ),  // read data from reg file (port2)
        .ext_data       ( ext_data_iexe     ),  // sign extended immediate data
        .srcB_sel       ( srcB_sel_iexe     ),  // source B enable signal for ALU
        .shamt          ( shamt_iexe        ),  // for shift operations
        .ALU_Code       ( ALU_Code_iexe     ),  // code for ALU
        .result         ( result_iexe       )   // result of ALU operation
    );

    /*********************************************
    **       Instruction memory stage           **
    *********************************************/
    // for verification
    // synthesis translate_off
    logic   [31 : 0]    instr_imem;         // instruction ( memory stage )
    nf_register_we  #( 32 ) instr_iexe_imem     ( clk , resetn , ~ stall_imem , instr_iexe , instr_imem  );
    // synthesis translate_on

    logic   [31 : 0]    result_imem;        // result operation ( memory stage )
    logic   [0  : 0]    we_dm_imem;         // write enable data memory ( memory stage )
    logic   [31 : 0]    rd2_imem;           // read data 2 from register file ( memory stage )
    logic   [0  : 0]    rf_src_imem;        // register file source ( memory stage )
    logic   [4  : 0]    wa3_imem;           // write address for register file ( memory stage )
    logic   [0  : 0]    we_rf_imem;         // write enable register file ( memory stage )
    logic   [1  : 0]    size_dm_imem;       // size for load/store instructions ( memory stage )

    nf_register_we  #( 1  ) we_dm_iexe_imem     ( clk , resetn , ~ stall_imem , we_dm_iexe    , we_dm_imem   );
    nf_register_we  #( 1  ) we_rf_iexe_imem     ( clk , resetn , ~ stall_imem , we_rf_iexe    , we_rf_imem   );
    nf_register_we  #( 1  ) rf_src_iexe_imem    ( clk , resetn , ~ stall_imem , rf_src_iexe   , rf_src_imem  );
    nf_register_we  #( 2  ) size_dm_iexe_imem   ( clk , resetn , ~ stall_imem , size_dm_iexe  , size_dm_imem );
    nf_register_we  #( 5  ) wa3_iexe_imem       ( clk , resetn , ~ stall_imem , wa3_iexe      , wa3_imem     );
    nf_register_we  #( 32 ) rd2_i_exu_imem      ( clk , resetn , ~ stall_imem , rd2_i_exu     , rd2_imem     );
    nf_register_we  #( 32 ) result_iexe_imem    ( clk , resetn , ~ stall_imem , result_iexe_e , result_imem  );

    /*********************************************
    **       Instruction write back stage       **
    *********************************************/

    // for verification
    // synthesis translate_off
    logic   [31 : 0]    instr_iwb;          // instruction ( write back stage )
    nf_register_we  #( 32 ) instr_imem_iwb  ( clk , resetn , ~ stall_iwb , instr_imem  , instr_iwb  );
    // synthesis translate_on

    logic   [4  : 0]    wa3_iwb;            // write address for register file ( write back stage )
    logic   [0  : 0]    we_rf_iwb;          // write enable for register file ( write back stage )
    logic   [0  : 0]    rf_src_iwb;         // register file source ( write back stage )
    logic   [31 : 0]    result_iwb;         // result operation ( write back stage )
    logic   [31 : 0]    wd_iwb;             // write data ( write back stage )
    logic   [31 : 0]    rd_dm_iwb;          // read data from data memory ( write back stage )

    nf_register_we  #( 1  ) we_rf_imem_iwb  ( clk , resetn , ~ stall_iwb , we_rf_imem  , we_rf_iwb  );
    nf_register_we  #( 1  ) rf_src_imem_iwb ( clk , resetn , ~ stall_iwb , rf_src_imem , rf_src_iwb );
    nf_register_we  #( 5  ) wa3_imem_iwb    ( clk , resetn , ~ stall_iwb , wa3_imem    , wa3_iwb    );
    nf_register_we  #( 32 ) result_imem_iwb ( clk , resetn , ~ stall_iwb , result_imem , result_iwb );
    logic   [0  : 0]     lsu_busy;          // load store unit busy

    assign wa3    = wa3_iwb;
    assign wd3    = wd_iwb;
    assign wd_iwb = rf_src_iwb ? rd_dm_iwb : result_iwb;
    assign we_rf  = we_rf_iwb;

    nf_i_lsu 
    nf_i_lsu_0
    (
        // clock and reset
        .clk            ( clk           ),      // clock
        .resetn         ( resetn        ),      // reset
        // pipeline wires
        .result_imem    ( result_imem   ),      // result from imem stage
        .rd2_imem       ( rd2_imem      ),      // read data 2 from imem stage
        .we_dm_imem     ( we_dm_imem    ),      // write enable data memory from imem stage
        .rf_src_imem    ( rf_src_imem   ),      // register file source enable from imem stage
        .size_dm_imem   ( size_dm_imem  ),      // size data memory from imem stage
        .rd_dm_iwb      ( rd_dm_iwb     ),      // read data for write back stage
        .lsu_busy       ( lsu_busy      ),      // load store unit busy
        // data memory and other's
        .addr_dm        ( addr_dm       ),      // address data memory
        .rd_dm          ( rd_dm         ),      // read data memory
        .wd_dm          ( wd_dm         ),      // write data memory
        .we_dm          ( we_dm         ),      // write enable data memory signal
        .size_dm        ( size_dm       ),      // size for load/store instructions
        .req_dm         ( req_dm        ),      // request data memory signal
        .req_ack_dm     ( req_ack_dm    )       // request acknowledge data memory signal
    );
    // creating stall and flush unit (hazard)
    nf_hz_stall_unit 
    nf_hz_stall_unit_0
    (   
        // scan wires
        .we_rf_imem     ( we_rf_imem    ),  // write enable register from memory stage
        .wa3_iexe       ( wa3_iexe      ),  // write address from execution stage
        .wa3_imem       ( wa3_imem      ),
        .we_rf_iexe     ( we_rf_iexe    ),  // write enable register from memory stage
        .rf_src_iexe    ( rf_src_iexe   ),  // register source from execution stage
        .ra1_id         ( ra1_id        ),  // read address 1 from decode stage
        .ra2_id         ( ra2_id        ),  // read address 2 from decode stage
        .branch_type    ( branch_type   ),  // branch type
        .we_dm_imem     ( we_dm_imem    ),  // write enable data memory from memory stage
        .req_ack_dm     ( req_ack_dm    ),  // request acknowledge data memory
        .req_ack_i      ( req_ack_i     ),  // request acknowledge instruction
        .rf_src_imem    ( rf_src_imem   ),  // register source from memory stage
        .lsu_busy       ( lsu_busy      ),  // load store unit busy
        // control wires
        .stall_if       ( stall_if      ),  // stall fetch stage
        .stall_id       ( stall_id      ),  // stall decode stage
        .stall_iexe     ( stall_iexe    ),  // stall execution stage
        .stall_imem     ( stall_imem    ),  // stall memory stage
        .stall_iwb      ( stall_iwb     ),  // stall write back stage
        .flush_iexe     ( flush_iexe    )   // flush execution stage
    );
    // creating bypass unit (hazard)
    nf_hz_bypass_unit 
    nf_hz_bypass_unit_0
    (
        // scan wires
        .wa3_imem       ( wa3_imem      ),  // write address from mem stage
        .we_rf_imem     ( we_rf_imem    ),  // write enable register from mem stage
        .wa3_iwb        ( wa3_iwb       ),  // write address from write back stage
        .we_rf_iwb      ( we_rf_iwb     ),  // write enable register from write back stage
        .ra1_id         ( ra1_id        ),  // read address 1 from decode stage
        .ra2_id         ( ra2_id        ),  // read address 2 from decode stage
        .ra1_iexe       ( ra1_iexe      ),  // read address 1 from execution stage
        .ra2_iexe       ( ra2_iexe      ),  // read address 2 from execution stage
        // bypass inputs
        .rd1_iexe       ( rd1_iexe      ),  // read data 1 from execution stage
        .rd2_iexe       ( rd2_iexe      ),  // read data 2 from execution stage
        .result_imem    ( result_imem   ),  // ALU result from mem stage
        .wd_iwb         ( wd_iwb        ),  // write data from iwb stage
        .rd1_id         ( rd1_id        ),  // read data 1 from decode stage
        .rd2_id         ( rd2_id        ),  // read data 2 from decode stage
        // bypass outputs
        .rd1_i_exu      ( rd1_i_exu     ),  // bypass data 1 for execution stage
        .rd2_i_exu      ( rd2_i_exu     ),  // bypass data 2 for execution stage
        .cmp_d1         ( cmp_d1        ),  // bypass data 1 for decode stage (branch)
        .cmp_d2         ( cmp_d2        )   // bypass data 2 for decode stage (branch)
    );
    
endmodule : nf_cpu
