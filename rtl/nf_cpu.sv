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
    input                   clk,
    input                   resetn,
    input   logic   [25:0]  div
`ifdef debug
    ,
    input   [4:0]           reg_addr,
    output  [31:0]          reg_data
`endif
);

    logic   [31 : 0]    pc_i;
    logic   [31 : 0]    pc_o;
    logic   [31 : 0]    pc_nb;
    logic   [31 : 0]    pc_b;
    logic               pc_en;
    logic               next_pc_sel;
    logic   [31 : 0]    instr;
    //register file
    logic   [4  : 0]    ra1;
    logic   [31 : 0]    rd1;
    logic   [4  : 0]    ra2;
    logic   [31 : 0]    rd2;
    logic   [4  : 0]    wa3;
    logic   [31 : 0]    wd3;
    logic               we3;
    //sign extend
    logic   [11 : 0]    imm_data_i;
    logic   [19 : 0]    imm_data_u;
    logic   [11 : 0]    imm_data_b;
    logic   [31 : 0]    ext_data;
    //ALU
    logic   [31 : 0]    srcA;
    logic   [31 : 0]    srcB;
    logic   [4  : 0]    shamt;
    logic   [31 : 0]    ALU_Code;
    logic   [31 : 0]    result;
    logic               zero;

    logic   [6  : 0]    opcode;
    logic   [2  : 0]    funct3;
    logic   [6  : 0]    funct7;
    logic               branch;
    logic               eq_neq;

    logic               srcBsel;
    logic   [1  : 0]    imm_src;

    assign ra1  = instr[15 +: 5];
    assign ra2  = instr[20 +: 5];
    assign wa3  = instr[7  +: 5];
    assign wd3  = result;
    assign srcA = rd1;
    assign srcB = srcBsel ? rd2 : ext_data;
    assign shamt = instr[20  +: 5];

    assign opcode = instr[0   +: 7];
    assign funct3 = instr[12  +: 3];
    assign funct7 = instr[25  +: 7];

    assign imm_data_i = instr[20 +: 12];
    assign imm_data_u = instr[12 +: 20];
    assign imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };
    nf_sign_ex nf_sign_ex_0
    (
        .imm_data_i     ( imm_data_i    ),
        .imm_data_u     ( imm_data_u    ),
        .imm_data_b     ( imm_data_b    ),
        .imm_src        ( imm_src       ),
        .imm_ex         ( ext_data      )
    );

    nf_clock_div nf_clock_div_0
    (
        .clk            ( clk           ),
        .resetn         ( resetn        ),
        .div            ( div           ),
        .en             ( pc_en         )
    );

    assign next_pc_sel = branch && ( ~ ( zero ^ eq_neq ) );
    assign pc_i  = next_pc_sel ? pc_b : pc_nb;
    assign pc_nb = pc_o + 4;
    assign pc_b  = pc_o + 4 + ( ext_data << 1 );

    nf_register_we
    #(
        .width          ( 32            )
    )
    register_pc
    (
        .clk            ( clk           ),
        .resetn         ( resetn        ),
        .datai          ( pc_i          ),
        .datao          ( pc_o          ),
        .en             ( pc_en         )
    );

    nf_instr_mem 
    #( 
        .depth          ( 64            ) 
    )
    instr_mem_0
    (
        .clk            ( clk           ),
        .addr           ( pc_o >> 2     ),
        .instr          ( instr         )
    );

    nf_reg_file reg_file_0
    (
        .clk            ( clk           ),
        .ra1            ( ra1           ),
        .rd1            ( rd1           ),
        .ra2            ( ra2           ),
        .rd2            ( rd2           ),
        .wa3            ( wa3           ),
        .wd3            ( wd3           ),
        .we3            ( we3 && pc_en  )
        `ifdef debug
        ,
        .ra0            ( reg_addr      ),
        .rd0            ( reg_data      )
        `endif
    );

    nf_alu alu_0
    (
        .srcA           ( srcA          ),
        .srcB           ( srcB          ),
        .shamt          ( shamt         ),
        .ALU_Code       ( ALU_Code      ),
        .result         ( result        ),
        .zero           ( zero          )
    );

    nf_control_unit nf_control_unit_0
    (
        .opcode         ( opcode        ),
        .funct3         ( funct3        ),
        .funct7         ( funct7        ),
        .srcBsel        ( srcBsel       ),
        .branch         ( branch        ),
        .eq_neq         ( eq_neq        ),
        .we             ( we3           ),
        .imm_src        ( imm_src       ),
        .ALU_Code       ( ALU_Code      )
    );

endmodule : nf_cpu
