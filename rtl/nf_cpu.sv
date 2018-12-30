/*
*  File            :   nf_cpu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_cpu
(
    // clock and reset
    input   logic               clk,
    input   logic               resetn,
    input   logic               cpu_en,
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
    logic   [4  : 0]    ra1;
    logic   [31 : 0]    rd1;
    logic   [4  : 0]    ra2;
    logic   [31 : 0]    rd2;
    logic   [4  : 0]    wa3;
    logic   [31 : 0]    wd3;
    logic               we_rf;
    logic               rf_src;
    // sign extend wires
    logic   [11 : 0]    imm_data_i;
    logic   [19 : 0]    imm_data_u;
    logic   [11 : 0]    imm_data_b;
    logic   [11 : 0]    imm_data_s;
    logic   [31 : 0]    ext_data;
    // ALU wires
    logic   [31 : 0]    srcA;
    logic   [31 : 0]    srcB;
    logic   [4  : 0]    shamt;
    logic   [31 : 0]    ALU_Code;
    logic   [31 : 0]    result;
    // control unit wires
    logic   [6  : 0]    opcode;
    logic   [2  : 0]    funct3;
    logic   [6  : 0]    funct7;
    logic               branch;
    logic               eq_neq;
    logic   [1  : 0]    imm_src;
    logic               srcBsel;
    // data memory and other's
    logic               we_dm_en;

    
    // next program counter value for not branch command
    assign pc_nb = instr_addr + 4;
    // finding next program counter value
    assign pc_i  = pc_b_en ? pc_b : pc_nb;


    
    // creating program counter
    nf_register_we_r
    #(
        .width          ( 32                    )
    )
    register_pc
    (
        .clk            ( clk                   ),
        .resetn         ( resetn                ),
        .datai          ( pc_i                  ),
        .datar          ( '0                    ),
        .datao          ( instr_addr            ),
        .we             ( cpu_en                )
    );
    /*********************************************
    **          Instruction Fetch stage         **
    *********************************************/
    logic   [31 : 0]    instr_if;
    logic   [31 : 0]    instr_id;
    assign  instr_if = instr;

    nf_register #( 32 ) instr_if_id ( clk, resetn, instr_if, instr_id );

    logic   [31 : 0]    pc_if;
    logic   [31 : 0]    pc_id;
    assign  pc_if = instr_addr;

    nf_register #( 32 ) pc_if_id ( clk, resetn, pc_if, pc_id );

    /*********************************************
    **         Instruction Decode stage         **
    *********************************************/

    // register's address finding from instruction
    assign ra1  = instr_id[15 +: 5];
    assign ra2  = instr_id[20 +: 5];
    // shamt value in instruction
    assign shamt = instr_id[20  +: 5];
    // operation code, funct3 and funct7 field's in instruction
    assign opcode = instr_id[0   +: 7];
    assign funct3 = instr_id[12  +: 3];
    assign funct7 = instr_id[25  +: 7];
    // immediate data in instruction
    assign imm_data_i = instr_id[20 +: 12];
    assign imm_data_u = instr_id[12 +: 20];
    assign imm_data_b = { instr_id[31] , instr_id[7] , instr_id[25 +: 6] , instr_id[8 +: 4] };
    assign imm_data_s = { instr_id[25 +: 7] , instr_id[7 +: 5] };
    // 
    logic   [0  : 0]    we_rf_iwb;

    // creating register file
    nf_reg_file reg_file_0
    (
        .clk            ( clk                   ),
        .ra1            ( ra1                   ),
        .rd1            ( rd1                   ),
        .ra2            ( ra2                   ),
        .rd2            ( rd2                   ),
        .wa3            ( wa3                   ),
        .wd3            ( wd3                   ),
        .we3            ( we_rf_iwb && cpu_en   )
        `ifdef debug
        ,
        .ra0            ( reg_addr              ),
        .rd0            ( reg_data              )
        `endif
    );

    // creating control unit for cpu
    nf_control_unit nf_control_unit_0
    (
        .opcode         ( opcode                ),
        .funct3         ( funct3                ),
        .funct7         ( funct7                ),
        .srcBsel        ( srcBsel               ),
        .branch         ( branch                ),
        .eq_neq         ( eq_neq                ),
        .we_rf          ( we_rf                 ),
        .we_dm          ( we_dm_en              ),
        .rf_src         ( rf_src                ),
        .imm_src        ( imm_src               ),
        .ALU_Code       ( ALU_Code              )
    );

    // creating sign extending unit
    nf_sign_ex nf_sign_ex_0
    (
        .imm_data_i     ( imm_data_i            ),
        .imm_data_u     ( imm_data_u            ),
        .imm_data_b     ( imm_data_b            ),
        .imm_data_s     ( imm_data_s            ),
        .imm_src        ( imm_src               ),
        .imm_ex         ( ext_data              )
    );

    // for debug
    logic   [31 : 0]    instr_iexe;
    nf_register #( 32 ) instr_id_iexe ( clk, resetn, instr_id, instr_iexe );

    logic   [31 : 0]    pc_iexe;
    nf_register #( 32 ) pc_id_iexe ( clk, resetn, pc_id, pc_iexe );

    logic   [31 : 0]    ext_data_id;
    logic   [31 : 0]    ext_data_iexe;
    assign  ext_data_id = ext_data;

    // next program counter value for branch command
    assign pc_b  = pc_iexe + ( ext_data_iexe << 1 );

    nf_register #( 32 ) sign_ex_id_iexe ( clk, resetn, ext_data_id, ext_data_iexe );

    logic   [31 : 0]    rd1_id;
    logic   [31 : 0]    rd1_iexe;
    assign  rd1_id = rd1;

    nf_register #( 32 ) rd1_id_iexe ( clk, resetn, rd1_id, rd1_iexe );

    logic   [31 : 0]    rd2_id;
    logic   [31 : 0]    rd2_iexe;
    assign  rd2_id = rd2;

    nf_register #( 32 ) rd2_id_iexe ( clk, resetn, rd2_id, rd2_iexe );

    logic   [4  : 0]    wa3_id;
    logic   [4  : 0]    wa3_iexe;
    assign  wa3_id = instr[7  +: 5];

    nf_register #( 5 )  wa3_id_iexe ( clk, resetn, wa3_id, wa3_iexe );

    logic   [0  : 0]    srcBsel_id;
    logic   [0  : 0]    srcBsel_iexe;
    assign  srcBsel_id = srcBsel;

    nf_register #( 1 )  srcBsel_id_iexe ( clk, resetn, srcBsel_id, srcBsel_iexe );

    logic   [0  : 0]    branch_id;
    logic   [0  : 0]    branch_iexe;
    assign  branch_id = branch;

    nf_register #( 1 )  branch_id_iexe ( clk, resetn, branch_id, branch_iexe );

    logic   [0  : 0]    eq_neq_id;
    logic   [0  : 0]    eq_neq_iexe;
    assign  eq_neq_id = eq_neq;

    nf_register #( 1 )  eq_neq_id_iexe ( clk, resetn, eq_neq_id, eq_neq_iexe );

    logic   [0  : 0]    we_rf_id;
    logic   [0  : 0]    we_rf_iexe;
    assign  we_rf_id = we_rf;

    nf_register #( 1 )  we_rf_id_iexe ( clk, resetn, we_rf_id, we_rf_iexe );

    logic   [0  : 0]    we_dm_id;
    logic   [0  : 0]    we_dm_iexe;
    assign  we_dm_id = we_dm_en;

    nf_register #( 1 )  we_dm_id_iexe ( clk, resetn, we_dm_id, we_dm_iexe );

    logic   [0  : 0]    rf_src_id;
    logic   [0  : 0]    rf_src_iexe;
    assign  rf_src_id = rf_src;

    nf_register #( 1 )  rf_src_id_iexe ( clk, resetn, rf_src_id, rf_src_iexe );

    logic   [31  : 0]    ALU_Code_id;
    logic   [31  : 0]    ALU_Code_iexe;
    assign  ALU_Code_id = ALU_Code;

    nf_register #( 32 ) ALU_Code_id_iexe ( clk, resetn, ALU_Code_id, ALU_Code_iexe );

    logic   [4  : 0]    shamt_id;
    logic   [4  : 0]    shamt_iexe;
    assign  shamt_id = shamt;

    nf_register #( 5 ) shamt_id_iexe ( clk, resetn, shamt_id, shamt_iexe );

    /*********************************************
    **       Instruction execution stage        **
    *********************************************/
    // ALU assign's
    
    assign srcA = rd1_iexe;
    assign srcB = srcBsel_iexe ? rd2_iexe : ext_data_iexe;
    // creating ALU unit
    nf_alu alu_0
    (
        .srcA           ( srcA                  ),
        .srcB           ( srcB                  ),
        .shamt          ( shamt_iexe            ),
        .ALU_Code       ( ALU_Code_iexe         ),
        .result         ( result                )
    );

    // creating branch unit
    nf_branch_unit nf_branch_unit_0
    (
        .branch         ( branch_iexe           ),
        .d0             ( rd1_iexe              ),
        .d1             ( rd2_iexe              ),
        .eq_neq         ( eq_neq_iexe           ),
        .pc_b_en        ( pc_b_en               )
    );

    /*********************************************
    **       Instruction memory stage           **
    *********************************************/
    // data memory assign's and other's

    // for debug
    logic   [31 : 0]    instr_imem;
    nf_register #( 32 ) instr_iexe_imem ( clk, resetn, instr_iexe, instr_imem );

    logic   [31  : 0]    result_iexe;
    logic   [31  : 0]    result_imem;
    assign  result_iexe = result;

    nf_register #( 32 ) result_iexe_imem ( clk, resetn, result_iexe, result_imem );

    logic   [0  : 0]    we_dm_imem;

    nf_register #( 1 )  we_dm_iexe_imem ( clk, resetn, we_dm_iexe, we_dm_imem );

    logic   [31  : 0]    rd2_imem;

    nf_register #( 32 ) rd2_iexe_imem ( clk, resetn, rd2_iexe, rd2_imem );

    logic   [0  : 0]    rf_src_imem;

    nf_register #( 1 )  rf_src_iexe_imem ( clk, resetn, rf_src_iexe, rf_src_imem );

    logic   [4  : 0]    wa3_imem;

    nf_register #( 5 )  wa3_iexe_imem ( clk, resetn, wa3_iexe, wa3_imem );

    logic   [0  : 0]    we_rf_imem;

    nf_register #( 1 )  we_rf_iexe_imem ( clk, resetn, we_rf_iexe, we_rf_imem );

    assign addr_dm  = result_imem;
    assign wd_dm    = rd2_imem;
    assign we_dm    = we_dm_imem && cpu_en;

    /*********************************************
    **       Instruction write back stage       **
    *********************************************/

    // for debug
    logic   [31 : 0]    instr_iwb;
    nf_register #( 32 ) instr_imem_iwb ( clk, resetn, instr_imem, instr_iwb );

    logic   [4  : 0]    wa3_iwb;
    assign  wa3  = wa3_iwb;
    nf_register #( 5 )  wa3_imem_iwb ( clk, resetn, wa3_imem, wa3_iwb );
    
    nf_register #( 1 )  we_rf_imem_iwb ( clk, resetn, we_rf_imem, we_rf_iwb );

    logic   [0  : 0]    rf_src_iwb;

    nf_register #( 1 )  rf_src_imem_iwb ( clk, resetn, rf_src_imem, rf_src_iwb );

    logic   [31  : 0]    result_iwb;
    nf_register #( 32 ) result_imem_iwb ( clk, resetn, result_imem, result_iwb );

    assign wd3  = rf_src_iwb ? rd_dm : result_iwb;
    
endmodule : nf_cpu
