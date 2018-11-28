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

    function new();
        $timeformat(-9, 2, " ns", 7);
    endfunction : new

    task pars(bit [31 : 0] instr, ref string intruction_s);
        ra1  = instr[15 +: 5];
        ra2  = instr[20 +: 5];
        wa3  = instr[7  +: 5];
        opcode = instr[0   +: 7];
        funct3 = instr[12  +: 3];
        funct7 = instr[25  +: 7];
        imm_data_u = instr[12 +: 20];
        imm_data_i = instr[20 +: 12];
        imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };

        casex( { opcode , funct3 , funct7 } )
            //  R - type command's
            { `C_ADD  , `F3_ADD  , `F7_ADD  } : intruction_s = $psprintf("ADD  rd  = %s, rs1 = %s, rs2 = %s", registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            { `C_SUB  , `F3_SUB  , `F7_SUB  } : intruction_s = $psprintf("SUB  rd  = %s, rs1 = %s, rs2 = %s", registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            { `C_OR   , `F3_OR   , `F7_ANY  } : intruction_s = $psprintf("OR   rd  = %s, rs1 = %s, rs2 = %s", registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            //  I - type command's
            { `C_SLLI , `F3_SLLI , `F7_ANY  } : intruction_s = $psprintf("SLLI rd  = %s, rs1 = %s, Imm = %h", registers_list[wa3], registers_list[ra1], imm_data_i           );
            { `C_ADDI , `F3_ADDI , `F7_ANY  } : intruction_s = $psprintf("ADDI rd  = %s, rs1 = %s, Imm = %h", registers_list[wa3], registers_list[ra1], imm_data_i           );
            //  U - type command's
            { `C_LUI  , `F3_ANY  , `F7_ANY  } : intruction_s = $psprintf("LUI  rd  = %s, Imm =%h",            registers_list[wa3], imm_data_u                                );
            //  B - type command's
            { `C_BEQ  , `F3_BEQ  , `F7_ANY  } : intruction_s = $psprintf("BEQ  rs1 = %s, rs2 = %s, Imm = %h", registers_list[ra1], registers_list[ra2], imm_data_b           );
            //  S and J - type command's
            //  in the future
            //  Other's instructions
            { `C_ANY  , `F3_ANY  , `F7_ANY  } : intruction_s = $psprintf("Unknown instruction",                                                                              );
        endcase
        $display("%t %s", $time, intruction_s);
    endtask : pars

endclass : pars_instr
