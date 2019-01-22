/*
*  File            :   nf_cpu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_cpu
(
    // clock and reset
    input   logic               clk,
    input   logic               resetn,
    input   logic               cpu_en,         // cpu enable signal
    // instruction memory
    output  logic   [31 : 0]    instr_addr,     // instruction address
    input   logic   [31 : 0]    instr           // instruction data
`ifdef debug
    // for debug
    ,
    input   logic   [4  : 0]    reg_addr,       // register address
    output  logic   [31 : 0]    reg_data        // register data
`endif
);

    // program counter wires
    logic   [31 : 0]    pc_i;
    logic   [31 : 0]    pc_nb;
    logic   [31 : 0]    pc_b;
    logic               next_pc_sel;
    // register file wires
    logic   [4  : 0]    ra1;
    logic   [31 : 0]    rd1;
    logic   [4  : 0]    ra2;
    logic   [31 : 0]    rd2;
    logic   [4  : 0]    wa3;
    logic   [31 : 0]    wd3;
    logic               we3;
    // sign extend wires
    logic   [11 : 0]    imm_data_i;
    logic   [19 : 0]    imm_data_u;
    logic   [11 : 0]    imm_data_b;
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
    logic               branch_type;
    logic               eq_neq;
    logic   [1  : 0]    imm_src;
    logic               srcBsel;
    logic               pc_src;

    // register's address finding from instruction
    assign ra1  = instr[15 +: 5];
    assign ra2  = instr[20 +: 5];
    assign wa3  = instr[7  +: 5];
    // shamt value in instruction
    assign shamt = instr[20  +: 5];
    // operation code, funct3 and funct7 field's in instruction
    assign opcode = instr[0   +: 7];
    assign funct3 = instr[12  +: 3];
    assign funct7 = instr[25  +: 7];
    // immediate data in instruction
    assign imm_data_i = instr[20 +: 12];
    assign imm_data_u = instr[12 +: 20];
    assign imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };
    // ALU wire's
    assign wd3  = result;
    assign srcA = rd1;
    assign srcB = srcBsel ? rd2 : ext_data;
    // next program counter value for not branch command
    assign pc_nb = instr_addr + 4;
    // next program counter value for branch command
    assign pc_b  = instr_addr + ( ext_data << 1 );
    // finding next program counter value
    assign pc_i  = pc_src ? pc_b : pc_nb;

    // creating program counter
    nf_register_we
    #(
        .width          ( 32            )
    )
    register_pc
    (
        .clk            ( clk           ),
        .resetn         ( resetn        ),
        .datai          ( pc_i          ),
        .datao          ( instr_addr    ),
        .we             ( cpu_en        )
    );
    // creating register file
    nf_reg_file reg_file_0
    (
        .clk            ( clk           ),
        .ra1            ( ra1           ),  // read address 1
        .rd1            ( rd1           ),  // read data 1
        .ra2            ( ra2           ),  // read address 2
        .rd2            ( rd2           ),  // read data 2
        .wa3            ( wa3           ),  // write address 
        .wd3            ( wd3           ),  // write data
        .we3            ( we3 && cpu_en )   // write enable signal
        `ifdef debug
        ,
        .ra0            ( reg_addr      ),  // read address 0
        .rd0            ( reg_data      )   // read data 0
        `endif
    );
    // creating ALU unit
    nf_alu alu_0
    (
        .srcA           ( srcA          ),  // source A for ALU unit
        .srcB           ( srcB          ),  // source B for ALU unit
        .shamt          ( shamt         ),  // for shift operation
        .ALU_Code       ( ALU_Code      ),  // ALU code from control unit
        .result         ( result        )   // result of ALU operation
    );
    // creating control unit for cpu
    nf_control_unit nf_control_unit_0
    (
        .opcode         ( opcode        ),  // operation code field in instruction code
        .funct3         ( funct3        ),  // funct 3 field in instruction code
        .funct7         ( funct7        ),  // funct 7 field in instruction code
        .srcBsel        ( srcBsel       ),  // for enable immediate data
        .branch_type    ( branch_type   ),  // for selecting srcB ALU
        .eq_neq         ( eq_neq        ),  // for executing branch instructions
        .we             ( we3           ),  // equal and not equal control
        .imm_src        ( imm_src       ),  // write enable signal for register file
        .ALU_Code       ( ALU_Code      )   // output code for ALU unit
    );
    // creating branch unit
    nf_branch_unit nf_branch_unit_0
    (
        .branch_type    ( branch_type   ),  // from control unit, '1 if branch instruction
        .d0             ( rd1           ),  // from control unit for beq and bne commands (equal and not equal)
        .d1             ( rd2           ),  // from register file (rd1)
        .eq_neq         ( eq_neq        ),  // from register file (rd2)
        .pc_src         ( pc_src        )   // next program counter
    );
    // creating sign extending unit
    nf_sign_ex nf_sign_ex_0
    (
        .imm_data_i     ( imm_data_i    ),  // from control unit, '1 if branch instruction
        .imm_data_u     ( imm_data_u    ),  // from control unit for beq and bne commands (equal and not equal)
        .imm_data_b     ( imm_data_b    ),  // from register file (rd1)
        .imm_src        ( imm_src       ),  // from register file (rd2)
        .imm_ex         ( ext_data      )   // next program counter
    );

endmodule : nf_cpu
