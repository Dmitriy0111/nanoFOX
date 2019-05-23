/*
*  File            :   nf_i_du.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is instruction decode unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"

module nf_i_du
(
    input   logic   [31 : 0]    instr,      // Instruction input
    output  logic   [31 : 0]    ext_data,   // decoded extended data
    output  logic   [1  : 0]    srcB_sel,   // decoded source B selection for ALU
    output  logic   [1  : 0]    srcA_sel,   // decoded source A selection for ALU
    output  logic   [1  : 0]    shift_sel,  // for selecting shift input
    output  logic   [0  : 0]    res_sel,    // for selecting result
    output  logic   [3  : 0]    ALU_Code,   // decoded ALU code
    output  logic   [4  : 0]    shamt,      // decoded for shift command's
    output  logic   [4  : 0]    ra1,        // decoded read address 1 for register file
    input   logic   [31 : 0]    rd1,        // read data 1 from register file
    output  logic   [4  : 0]    ra2,        // decoded read address 2 for register file
    input   logic   [31 : 0]    rd2,        // read data 2 from register file
    output  logic   [4  : 0]    wa3,        // decoded write address 2 for register file
    output  logic   [11 : 0]    csr_addr,   // csr address
    output  logic   [1  : 0]    csr_cmd,    // csr command
    output  logic   [0  : 0]    csr_rreq,   // read request to csr
    output  logic   [0  : 0]    csr_wreq,   // write request to csr
    output  logic   [0  : 0]    csr_sel,    // csr select ( zimm or rd1 )
    output  logic   [0  : 0]    pc_src,     // decoded next program counter value enable
    output  logic   [0  : 0]    we_rf,      // decoded write register file
    output  logic   [0  : 0]    we_dm_en,   // decoded write data memory
    output  logic   [0  : 0]    rf_src,     // decoded source register file signal
    output  logic   [1  : 0]    size_dm,    // size for load/store instructions
    output  logic   [0  : 0]    sign_dm,    // sign extended data memory for load instructions
    output  logic   [0  : 0]    branch_src, // for selecting branch source (JALR)
    output  logic   [3  : 0]    branch_type // branch type
);  

    // sign extend wires
    logic   [11 : 0]    imm_data_i;     // for I-type command's
    logic   [19 : 0]    imm_data_u;     // for U-type command's
    logic   [11 : 0]    imm_data_b;     // for B-type command's
    logic   [11 : 0]    imm_data_s;     // for S-type command's
    logic   [19 : 0]    imm_data_j;     // for J-type command's
    // control unit wires
    logic   [1  : 0]    instr_type;     // instruction type
    logic   [4  : 0]    opcode;         // instruction operation code
    logic   [2  : 0]    funct3;         // instruction function 3 field
    logic   [6  : 0]    funct7;         // instruction function 7 field
    logic   [0  : 0]    branch_hf;      // branch help field
    logic   [4  : 0]    imm_src;        // immediate source selecting
    // immediate data in instruction
    assign imm_data_i = instr[20 +: 12];
    assign imm_data_u = instr[12 +: 20];
    assign imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };
    assign imm_data_s = { instr[25 +: 7] , instr[7 +: 5] };
    assign imm_data_j = { instr[31] , instr[12 +: 8] , instr[20] , instr[21 +: 10] };
    // shamt value in instruction
    assign shamt = instr[20  +: 5];
    // register file wires
    assign ra1 = instr[15 +: 5];
    assign ra2 = instr[20 +: 5];
    assign wa3 = instr[7  +: 5];
    // findind csr address
    assign csr_addr = instr[20 +: 12];
    // operation code, funct3 and funct7 field's in instruction
    assign instr_type = instr[0   +: 2];
    assign opcode     = instr[2   +: 5];
    assign funct3     = instr[12  +: 3];
    assign funct7     = instr[25  +: 7];
    // creating control unit for cpu
    nf_control_unit 
    nf_control_unit_0
    (
        .instr_type     ( instr_type    ),  // instruction type
        .opcode         ( opcode        ),  // operation code field in instruction code
        .funct3         ( funct3        ),  // funct 3 field in instruction code
        .funct7         ( funct7        ),  // funct 7 field in instruction code
        .wa3            ( wa3           ),  // wa3 field
        .srcB_sel       ( srcB_sel      ),  // for selecting srcB ALU
        .srcA_sel       ( srcA_sel      ),  // decoded source A selection for ALU
        .shift_sel      ( shift_sel     ),  // for selecting shift input
        .res_sel        ( res_sel       ),  // for selecting result
        .branch_type    ( branch_type   ),  // branch type 
        .branch_hf      ( branch_hf     ),  // branch help field
        .branch_src     ( branch_src    ),  // for selecting branch source (JALR)
        .we_rf          ( we_rf         ),  // write enable signal for register file
        .we_dm          ( we_dm_en      ),  // write enable signal for data memory and others
        .rf_src         ( rf_src        ),  // write data select for register file
        .imm_src        ( imm_src       ),  // selection immediate data input
        .size_dm        ( size_dm       ),  // size for load/store instructions
        .sign_dm        ( sign_dm       ),  // sign extended data memory for load instructions
        .csr_cmd        ( csr_cmd       ),  // csr command
        .csr_rreq       ( csr_rreq      ),  // read request to csr
        .csr_wreq       ( csr_wreq      ),  // write request to csr
        .csr_sel        ( csr_sel       ),  // csr select ( zimm or rd1 )
        .ALU_Code       ( ALU_Code      )   // output code for ALU unit
    );
    // creating sign extending unit
    nf_sign_ex 
    nf_sign_ex_0
    (
        .imm_data_i     ( imm_data_i    ),  // immediate data in i-type instruction
        .imm_data_u     ( imm_data_u    ),  // immediate data in u-type instruction
        .imm_data_b     ( imm_data_b    ),  // immediate data in b-type instruction
        .imm_data_s     ( imm_data_s    ),  // immediate data in s-type instruction
        .imm_data_j     ( imm_data_j    ),  // immediate data in j-type instruction
        .imm_src        ( imm_src       ),  // selection immediate data input
        .imm_ex         ( ext_data      )   // extended immediate data
    );
    // creating branch unit
    nf_branch_unit 
    nf_branch_unit_0
    (
        .branch_type    ( branch_type   ),  // from control unit, '1 if branch instruction
        .d1             ( rd1           ),  // from register file (rd1)
        .d2             ( rd2           ),  // from register file (rd2)
        .branch_hf      ( branch_hf     ),  // branch help field
        .pc_src         ( pc_src        )   // next program counter
    );

endmodule : nf_i_du
