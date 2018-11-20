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
    input           clk,
    input           resetn
`ifdef debug
    ,
    input   [4:0]   reg_addr,
    output  [31:0]  reg_data
`endif
);

    logic   [31 : 0]    pc_i;
    logic   [31 : 0]    pc_o;
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
    logic   [11 : 0]    imm_data;
    logic   [31 : 0]    ext_data;
    //ALU
    logic   [31 : 0]    srcA;
    logic   [31 : 0]    srcB;
    logic   [4  : 0]    shamt;
    logic   [31 : 0]    ALU_Code;
    logic   [31 : 0]    result;
    logic   [31 : 0]    alu_flags;

    logic   [6  : 0]    opcode;
    logic   [2  : 0]    funct3;
    logic   [6  : 0]    funct7;

    logic               srcBsel;

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
    //for I-type
    assign imm_data = instr[20 +: 12];
    assign ext_data = { { 20 { imm_data[11] } } , imm_data[0 +: 12] };

    assign pc_i = pc_o + 1;


    nf_register 
    #(
        .WIDTH      ( 32        )
    )
    register_pc
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .datai      ( pc_i      ),
        .datao      ( pc_o      )
    );

    nf_instr_mem 
    #( 
        .depth  ( 64        ) 
    )
    instr_mem_0
    (
        .addr   ( pc_o      ),
        .instr  ( instr     )
    );

    nf_reg_file reg_file_0
    (
        .clk    ( clk       ),
        .ra1    ( ra1       ),
        .rd1    ( rd1       ),
        .ra2    ( ra2       ),
        .rd2    ( rd2       ),
        .wa3    ( wa3       ),
        .wd3    ( wd3       ),
        .we3    ( we3       )
        `ifdef debug
        ,
        .ra0    ( reg_addr  ),
        .rd0    ( reg_data  )
        `endif
    );

    nf_alu alu_0
    (
        .srcA       ( srcA      ),
        .srcB       ( srcB      ),
        .shamt      ( shamt     ),
        .ALU_Code   ( ALU_Code  ),
        .result     ( result    ),
        .alu_flags  ( alu_flags )
    );

    nf_control_unit nf_control_unit_0
    (
        .opcode     ( opcode    ),
        .funct3     ( funct3    ),
        .funct7     ( funct7    ),
        .srcBsel    ( srcBsel   ),
        .we         ( we3       ),
        .ALU_Code   ( ALU_Code  )
    );

endmodule : nf_cpu
