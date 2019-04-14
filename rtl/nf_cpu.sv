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
    input   logic   [0  : 0]    clk,        // clock
    input   logic   [0  : 0]    resetn,     // reset
    input   logic   [0  : 0]    cpu_en,     // cpu enable signal
    // instruction memory
    output  logic   [31 : 0]    instr_addr, // instruction address
    input   logic   [31 : 0]    instr,      // instruction data
    // data memory and other's
    output  logic   [31 : 0]    addr_dm,    // data memory address
    output  logic   [0  : 0]    we_dm,      // data memory write enable
    output  logic   [31 : 0]    wd_dm,      // data memory write data
    input   logic   [31 : 0]    rd_dm,      // data memory read data
    // for debug
    input   logic   [4  : 0]    reg_addr,   // scan register address
    output  logic   [31 : 0]    reg_data    // scan register data
);

    // program counter wires
    logic   [31 : 0]    pc_i;
    logic   [31 : 0]    pc_nb;
    logic   [31 : 0]    pc_b;
    logic   [0  : 0]    pc_src;
    // register file wires
    logic   [4  : 0]    ra1;
    logic   [31 : 0]    rd1;
    logic   [4  : 0]    ra2;
    logic   [31 : 0]    rd2;
    logic   [4  : 0]    wa3;
    logic   [31 : 0]    wd3;
    logic   [0  : 0]    we_rf;
    logic   [0  : 0]    rf_src;
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
    logic   [0  : 0]    branch_type;
    logic   [0  : 0]    branch_hf;
    logic   [1  : 0]    imm_src;
    logic   [0  : 0]    srcBsel;
    // data memory and other's
    logic   [0  : 0]    we_dm_en;

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
    assign imm_data_s = { instr[25 +: 7] , instr[7 +: 5] };
    // ALU assign's
    assign wd3  = rf_src ? rd_dm : result;
    assign srcA = rd1;
    assign srcB = srcBsel ? rd2 : ext_data;
    // data memory assign's and other's
    assign addr_dm  = result;
    assign wd_dm    = rd2;
    assign we_dm    = we_dm_en && cpu_en;
    // next program counter value for not branch command
    assign pc_nb = instr_addr + 4;
    // next program counter value for branch command
    assign pc_b  = instr_addr + ( ext_data << 1 );
    // finding next program counter value
    assign pc_i  = pc_src ? pc_b : pc_nb;

    // creating one program counter
    nf_register_we_r
    #(
        .width          ( 32                )
    )
    PC
    (
        .clk            ( clk               ),  // clock
        .resetn         ( resetn            ),  // reset
        .datai          ( pc_i              ),  // input data
        .datar          ( '0                ),  // output data
        .datao          ( instr_addr        ),  // instruction address 
        .we             ( cpu_en            )   // write enable
    );

    // creating one register file
    nf_reg_file 
    reg_file_0
    (
        .clk            ( clk               ),  // clock
        .ra1            ( ra1               ),  // read address 1
        .rd1            ( rd1               ),  // read data 1
        .ra2            ( ra2               ),  // read address 2
        .rd2            ( rd2               ),  // read data 2
        .wa3            ( wa3               ),  // write address 
        .wd3            ( wd3               ),  // write data
        .we3            ( we_rf && cpu_en   ),  // write enable signal
        .ra0            ( reg_addr          ),  // scan register address
        .rd0            ( reg_data          )   // scan register data
    );
    // creating one ALU unit
    nf_alu 
    alu_0
    (
        .srcA           ( srcA              ),  // source A for ALU unit
        .srcB           ( srcB              ),  // source B for ALU unit
        .shamt          ( shamt             ),  // for shift operation
        .ALU_Code       ( ALU_Code          ),  // ALU code from control unit
        .result         ( result            )   // result of ALU operation
    );
    // creating one control unit for cpu
    nf_control_unit 
    nf_control_unit_0
    (
        .opcode         ( opcode            ),  // operation code field in instruction code
        .funct3         ( funct3            ),  // funct 3 field in instruction code
        .funct7         ( funct7            ),  // funct 7 field in instruction code
        .imm_src        ( imm_src           ),  // for selecting immediate data
        .srcBsel        ( srcBsel           ),  // for selecting srcB ALU
        .branch_type    ( branch_type       ),  // for executing branch instructions
        .branch_hf      ( branch_hf         ),  // branch help field
        .we_rf          ( we_rf             ),  // write enable signal for register file
        .we_dm          ( we_dm_en          ),  // write enable signal for data memory and other's
        .rf_src         ( rf_src            ),  // write data select for register file
        .ALU_Code       ( ALU_Code          )   // output code for ALU unit
    );
    // creating one branch unit
    nf_branch_unit 
    nf_branch_unit_0
    (
        .branch_type    ( branch_type       ),  // from control unit, '1 if branch instruction
        .d1             ( rd1               ),  // from register file (rd1)
        .d2             ( rd2               ),  // from register file (rd2)
        .branch_hf      ( branch_hf         ),  // branch help field
        .pc_src         ( pc_src            )   // selecting next program counter
    );
    // creating one sign extending unit
    nf_sign_ex 
    nf_sign_ex_0
    (
        .imm_data_i     ( imm_data_i        ),  // immediate data in i-type instruction
        .imm_data_u     ( imm_data_u        ),  // immediate data in u-type instruction
        .imm_data_b     ( imm_data_b        ),  // immediate data in b-type instruction
        .imm_data_s     ( imm_data_s        ),  // immediate data in s-type instruction
        .imm_src        ( imm_src           ),  // selection immediate data input
        .imm_ex         ( ext_data          )   // extended immediate data
    );

endmodule : nf_cpu
