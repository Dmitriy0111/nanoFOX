/*
*  File            :   nf_cpu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_cpu
(
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
    logic   [31 : 0]    OpCode;
    logic   [31 : 0]    result;
    logic   [31 : 0]    alu_flags;

    logic               imm_src;

    assign ra1  = instr[15 +: 5];
    assign ra2  = instr[20 +: 5];
    assign wa3  = instr[7  +: 5];
    assign wd3  = result;
    assign srcA = rd1;
    assign srcB = imm_src ? rd2 : ext_data;
    //for I-type
    assign imm_data = instr[20 +: 12];
    assign ext_data = { 20 { imm_data[11] } , imm_data[0 +: 11] };


    nf_register 
    #(
        .WIDTH      ( 32        )
    )
    register_pc
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .datai      ( pc_i      ),
        .datao      ( pc_0      )
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
        .clk    ( clk       )
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
        .OpCode     ( OpCode    ),
        .result     ( result    ),
        .alu_flags  ( alu_flags )
    );

endmodule : nf_cpu
