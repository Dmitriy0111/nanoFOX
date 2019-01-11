/*
*  File            :   nf_cpu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_settings.svh"
`include "nf_hazard_unit.svh"

module nf_cpu
(
    // clock and reset
    input   logic               clk,
    input   logic               resetn,
    // instruction memory (IF)
    output  logic   [31 : 0]    instr_addr,
    input   logic   [31 : 0]    instr,
    // data memory and other's
    output  logic   [31 : 0]    addr_dm,
    output  logic               we_dm,
    output  logic   [31 : 0]    wd_dm,
    input   logic   [31 : 0]    rd_dm
`ifdef debug
    // for debug
    ,
    input   logic   [4  : 0]    reg_addr,
    output  logic   [31 : 0]    reg_data
`endif
);

    // program counter wires
    logic   [31 : 0]    pc_i;
    logic   [31 : 0]    pc_nb;
    logic   [31 : 0]    pc_b;
    logic               pc_b_en;
    // register file wires
    logic   [4  : 0]    wa3;
    logic   [31 : 0]    wd3;
    logic               we_rf;
    //hazard's wires
    logic   [1  : 0]    rd1_bypass;
    logic   [1  : 0]    rd2_bypass;
    logic   [0  : 0]    stall_if;
    logic   [0  : 0]    stall_id;
    logic   [0  : 0]    flush_iexe;
    logic   [0  : 0]    flush_id;

    logic   [31 : 0]    rd1_i_exu;
    logic   [31 : 0]    rd2_i_exu;
    // next program counter value for not branch command
    assign pc_nb = instr_addr + 4;
    // finding next program counter value
    assign pc_i  = pc_b_en ? pc_b : pc_nb;
    
    // creating program counter
    nf_register_we_r
    #(
        .width          ( 32                )
    )
    register_pc
    (
        .clk            ( clk               ),
        .resetn         ( resetn            ),
        .datai          ( pc_i              ),
        .datar          ( '0                ),
        .datao          ( instr_addr        ),
        .we             ( ~ stall_if        )
    );
    /*********************************************
    **          Instruction Fetch stage         **
    *********************************************/
    logic   [31 : 0]    instr_if;
    logic   [31 : 0]    pc_if;

    assign  instr_if = instr;
    assign  pc_if = instr_addr;
    assign  flush_id = pc_b_en;

    logic   [31 : 0]    instr_id;
    logic   [31 : 0]    pc_id;

    nf_register_we_clr #( 32 ) instr_if_id ( clk, resetn, ~ stall_id, flush_id, instr_if, instr_id );
    nf_register_we_clr #( 32 ) pc_if_id    ( clk, resetn, ~ stall_id, flush_id, pc_if,    pc_id    );

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
    assign pc_b  = pc_id + ( ext_data_id << 1 );

    // creating register file
    nf_reg_file reg_file_0
    (
        .clk            ( clk               ),
        .ra1            ( ra1_id            ),
        .rd1            ( rd1_id            ),
        .ra2            ( ra2_id            ),
        .rd2            ( rd2_id            ),
        .wa3            ( wa3               ),
        .wd3            ( wd3               ),
        .we3            ( we_rf             )
        `ifdef debug
        ,
        .ra0            ( reg_addr          ),
        .rd0            ( reg_data          )
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
        .rd1            ( rd1_id            ),  // read data 1 from register file
        .ra2            ( ra2_id            ),  // decoded read address 2 for register file
        .rd2            ( rd2_id            ),  // read data 2 from register file
        .wa3            ( wa3_id            ),  // decoded write address 2 for register file
        .pc_b_en        ( pc_b_en           ),  // decoded next program counter value enable
        .we_rf          ( we_rf_id          ),  // decoded write register file
        .we_dm_en       ( we_dm_id          ),  // decoded write data memory
        .rf_src         ( rf_src_id         )   // decoded source register file signal
    );

    // for debug
    logic   [31 : 0]    instr_iexe;
    nf_register_clr #( 32 ) instr_id_iexe ( clk, resetn, flush_iexe, instr_id, instr_iexe );

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

    nf_register_clr #( 5  ) wa3_id_iexe         ( clk, resetn, flush_iexe, wa3_id       , wa3_iexe      );
    nf_register_clr #( 5  ) ra1_id_iexe         ( clk, resetn, flush_iexe, ra1_id       , ra1_iexe      );
    nf_register_clr #( 5  ) ra2_id_iexe         ( clk, resetn, flush_iexe, ra2_id       , ra2_iexe      );
    nf_register_clr #( 32 ) sign_ex_id_iexe     ( clk, resetn, flush_iexe, ext_data_id  , ext_data_iexe );
    nf_register_clr #( 32 ) rd1_id_iexe         ( clk, resetn, flush_iexe, rd1_id       , rd1_iexe      );
    nf_register_clr #( 32 ) rd2_id_iexe         ( clk, resetn, flush_iexe, rd2_id       , rd2_iexe      );
    nf_register_clr #( 1  ) srcB_sel_id_iexe    ( clk, resetn, flush_iexe, srcB_sel_id  , srcB_sel_iexe );
    nf_register_clr #( 1  ) we_rf_id_iexe       ( clk, resetn, flush_iexe, we_rf_id     , we_rf_iexe    );
    nf_register_clr #( 1  ) we_dm_id_iexe       ( clk, resetn, flush_iexe, we_dm_id     , we_dm_iexe    );
    nf_register_clr #( 1  ) rf_src_id_iexe      ( clk, resetn, flush_iexe, rf_src_id    , rf_src_iexe   );
    nf_register_clr #( 32 ) ALU_Code_id_iexe    ( clk, resetn, flush_iexe, ALU_Code_id  , ALU_Code_iexe );
    nf_register_clr #( 5  ) shamt_id_iexe       ( clk, resetn, flush_iexe, shamt_id     , shamt_iexe    );

    /*********************************************
    **       Instruction execution stage        **
    *********************************************/
    // creating instruction execution unit
    nf_i_exu nf_i_exu_0
    (
        .rd1            ( rd1_i_exu         ),
        .rd2            ( rd2_i_exu         ),
        .ext_data       ( ext_data_iexe     ),
        .srcB_sel       ( srcB_sel_iexe     ),
        .shamt          ( shamt_iexe        ),
        .ALU_Code       ( ALU_Code_iexe     ),
        .result         ( result_iexe       )
    );

    /*********************************************
    **       Instruction memory stage           **
    *********************************************/
    //for debug
    logic   [31 : 0]    instr_imem;
    nf_register #( 32 ) instr_iexe_imem ( clk, resetn, instr_iexe, instr_imem );

    logic   [31 : 0]    result_imem;
    logic   [0  : 0]    we_dm_imem;
    logic   [31 : 0]    rd2_imem;
    logic   [0  : 0]    rf_src_imem;
    logic   [4  : 0]    wa3_imem;
    logic   [0  : 0]    we_rf_imem;

    nf_register #( 32 ) result_iexe_imem    ( clk, resetn, result_iexe, result_imem );
    nf_register #( 1  ) we_dm_iexe_imem     ( clk, resetn, we_dm_iexe,  we_dm_imem  );
    nf_register #( 32 ) rd2_iexe_imem       ( clk, resetn, rd2_iexe,    rd2_imem    );
    nf_register #( 1  ) rf_src_iexe_imem    ( clk, resetn, rf_src_iexe, rf_src_imem );
    nf_register #( 5  ) wa3_iexe_imem       ( clk, resetn, wa3_iexe,    wa3_imem    );
    nf_register #( 1  ) we_rf_iexe_imem     ( clk, resetn, we_rf_iexe,  we_rf_imem  );

    assign addr_dm  = result_imem;
    assign wd_dm    = rd2_imem;
    assign we_dm    = we_dm_imem;

    /*********************************************
    **       Instruction write back stage       **
    *********************************************/

    // for debug
    logic   [31 : 0]    instr_iwb;
    nf_register #( 32 ) instr_imem_iwb ( clk, resetn, instr_imem, instr_iwb );

    logic   [4  : 0]    wa3_iwb;
    logic   [0  : 0]    we_rf_iwb;
    logic   [0  : 0]    rf_src_iwb;
    logic   [31 : 0]    result_iwb;

    nf_register #( 5  ) wa3_imem_iwb    ( clk, resetn, wa3_imem,    wa3_iwb     );
    nf_register #( 1  ) we_rf_imem_iwb  ( clk, resetn, we_rf_imem,  we_rf_iwb   );
    nf_register #( 1  ) rf_src_imem_iwb ( clk, resetn, rf_src_imem, rf_src_iwb  );
    nf_register #( 32 ) result_imem_iwb ( clk, resetn, result_imem, result_iwb  );

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
        // lw hazard stall and flush
        .wa3_iexe       ( wa3_iexe      ),
        .we_rf_iexe     ( we_rf_iexe    ),
        .rf_src_iexe    ( rf_src_iexe   ),
        .ra1_id         ( ra1_id        ),
        .ra2_id         ( ra2_id        ),
        .stall_if       ( stall_if      ),
        .stall_id       ( stall_id      ),
        .flush_iexe     ( flush_iexe    )
    );

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
