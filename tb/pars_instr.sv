/*
*  File            :   pars_instr.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is class for parsing instruction from instruction memory
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_cpu.svh"

class pars_instr;

    bit     [4  : 0]    ra1        ;
    bit     [4  : 0]    ra2        ;
    bit     [4  : 0]    wa3        ;
    bit     [6  : 0]    opcode     ;
    bit     [2  : 0]    funct3     ;
    bit     [6  : 0]    funct7     ;
    bit     [19 : 0]    imm_data_u ;
    bit     [11 : 0]    imm_data_i ;
    logic   [11 : 0]    imm_data_b ;

    string registers_list [0:31] =  {
                                        "zero",
                                        "ra",
                                        "sp",
                                        "gp",
                                        "tp",
                                        "t0",
                                        "t1",
                                        "t2",
                                        "s0/fp",
                                        "s1",
                                        "a0",
                                        "a1",
                                        "a2",
                                        "a3",
                                        "a4",
                                        "a5",
                                        "a6",
                                        "a7",
                                        "s2",
                                        "s3",
                                        "s4",
                                        "s5",
                                        "s6",
                                        "s7",
                                        "s8",
                                        "s9",
                                        "s10",
                                        "s11",
                                        "t3",
                                        "t4",
                                        "t5",
                                        "t6"
                                    };

    task pars(bit [31 : 0] instr);
        ra1  = instr[15 +: 5];
        ra2  = instr[20 +: 5];
        wa3  = instr[7  +: 5];
        opcode = instr[0   +: 7];
        funct3 = instr[12  +: 3];
        funct7 = instr[25  +: 7];
        imm_data_u = instr[12 +: 20];
        imm_data_i = instr[20 +: 12];
        imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };

        casex( { opcode , funct3 } )
            { `C_SLLI , `F_SLLI } : $display(" %8tns SLLI rd = %s, rs1 =%s , Imm =%h",  $time, registers_list[wa3], registers_list[ra1], imm_data_i           );
            { `C_ADDI , `F_ADDI } : $display(" %8tns ADDI rd = %s, rs1 =%s , Imm =%h",  $time, registers_list[wa3], registers_list[ra1], imm_data_i           );
            { `C_ADD  , `F_ADD  } : $display(" %8tns ADD rd = %s , rs1 =%s , rs2 = %s", $time, registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            { `C_OR   , `F_OR   } : $display(" %8tns OR rd = %s , rs1 =%s , rs2 = %s",  $time, registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            { `C_BEQ  , `F_BEQ  } : $display(" %8tns BEQ rs1 =%s , rs2 = %s, Imm = %h", $time, registers_list[ra1], registers_list[ra2], imm_data_b           );
            { `C_LUI  , `F_ANY  } : $display(" %8tns LUI rd = %s , Imm =%h",            $time, registers_list[wa3], imm_data_u                                );
            { `C_ANY  , `F_ANY  } : $display(" %8tns Unknown instruction",              $time                                                                 );
        endcase
    endtask : pars

endclass : pars_instr
