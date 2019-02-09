/*
*  File            :   pars_instr.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is class for parsing instruction from instruction memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_tb.svh"
`include "../inc/nf_cpu.svh"

class pars_instr;

    bit     [4  : 0]    ra1       ;
    bit     [4  : 0]    ra2       ;
    bit     [4  : 0]    wa3       ;
    bit     [6  : 0]    opcode    ;
    bit     [2  : 0]    funct3    ;
    bit     [6  : 0]    funct7    ;
    bit     [19 : 0]    imm_data_u;
    bit     [11 : 0]    imm_data_i;
    logic   [11 : 0]    imm_data_b;
    logic   [11 : 0]    imm_data_s;

    string registers_list [0  : 31] =   {
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

    task pars(logic [31 : 0] instr, ref string instruction_s, ref string instr_sep);

        instr_sep = "";
        // destination and sources registers
        ra1        = instr[15 +: 5];
        ra2        = instr[20 +: 5];
        wa3        = instr[7  +: 5];
        // operation type fields
        opcode     = instr[0  +: 7];
        funct3     = instr[12 +: 3];
        funct7     = instr[25 +: 7];
        // immediate data
        imm_data_u = instr[12 +: 20];
        imm_data_i = instr[20 +: 12];
        imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };
        imm_data_s = { instr[25 +: 7] , instr[7 +: 5] };

        casex( { opcode , funct3 , funct7 } )
            //  R - type command's
            { `C_ADD  , `F3_ADD  , `F7_ADD  } : instruction_s = $psprintf("ADD  rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3] , registers_list[ra1] , registers_list[ra2] );
            { `C_SUB  , `F3_SUB  , `F7_SUB  } : instruction_s = $psprintf("SUB  rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3] , registers_list[ra1] , registers_list[ra2] );
            { `C_OR   , `F3_OR   , `F7_ANY  } : instruction_s = $psprintf("OR   rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3] , registers_list[ra1] , registers_list[ra2] );
            //  I - type command's
            { `C_SLLI , `F3_SLLI , `F7_ANY  } : instruction_s = $psprintf("SLLI rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3] , registers_list[ra1] , imm_data_i          );
            { `C_ADDI , `F3_ADDI , `F7_ANY  } : instruction_s = $psprintf("ADDI rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3] , registers_list[ra1] , imm_data_i          );
            { `C_LW   , `F3_LW   , `F7_ANY  } : instruction_s = $psprintf("LW   rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3] , registers_list[ra1] , imm_data_i          );
            //  U - type command's
            { `C_LUI  , `F3_ANY  , `F7_ANY  } : instruction_s = $psprintf("LUI  rd  = %s, Imm = 0x%h"          , registers_list[wa3] , imm_data_u                                );
            //  B - type command's
            { `C_BEQ  , `F3_BEQ  , `F7_ANY  } : instruction_s = $psprintf("BEQ  rs1 = %s, rs2 = %s, Imm = 0x%h", registers_list[ra1] , registers_list[ra2] , imm_data_b          );
            //  S - type command's
            { `C_SW   , `F3_SW   , `F7_ANY  } : instruction_s = $psprintf("SW   rs1 = %s, rs2 = %s, Imm = 0x%h", registers_list[ra1] , registers_list[ra2] , imm_data_s          );
            //  J - type command's
            //  in the future
            //  Other's instructions
            { `C_ANY  , `F3_ANY  , `F7_ANY  } : instruction_s = $psprintf("Unknown instruction"                ,                                                                 );
        endcase

        // Flushed instruction
        if( instr == '0 )
            instruction_s = $psprintf("Flushed instruction"                ,                                                                 );
        
        $display("%s", instruction_s);
        if( `debug_lev0 )
        begin
            instr_separation(instr,instr_sep);
        end

    endtask : pars

    task instr_separation(bit [31 : 0] instr, ref string instr_sep);

        instr_sep= "";

        ra1    = instr[15 +: 5];
        ra2    = instr[20 +: 5];
        wa3    = instr[7  +: 5];
        opcode = instr[0  +: 7];
        funct3 = instr[12 +: 3];
        funct7 = instr[25 +: 7];

        if( opcode == 'b0110011 )
            instr_sep = $psprintf("R-type  : %b_%b_%b_%b_%b_%b", funct7, ra2, ra1, funct3, wa3, opcode );
        if( ( opcode == 'b0010011 ) || ( opcode == 'b0000011 ) || ( opcode == 'b1100111 ) )
            instr_sep = $psprintf("I-type  : %b_%b_%b_%b_%b", instr[20 +: 12], ra1, funct3, wa3, opcode );
        if( opcode == 'b0100011 )
            instr_sep = $psprintf("S-type  : %b_%b_%b_%b_%b_%b", instr[25 +: 7], ra2, ra1, funct3, instr[7  +: 5], opcode );
        if( opcode == 'b1100011 )
            instr_sep = $psprintf("B-type  : %b_%b_%b_%b_%b_%b_%b_%b", instr[31], instr[25 +: 6], ra2, ra1, funct3, instr[8  +: 5], instr[7], opcode );
        if( ( opcode == 'b0110111 ) || ( opcode == 'b0010111 ) )
            instr_sep = $psprintf("U-type  : %b_%b_%b", instr[12 +: 20], wa3, opcode );
        if( opcode == 'b1101111 )
            instr_sep = $psprintf("J-type  : %b_%b_%b_%b_%b_%b", instr[31], instr[21 +: 10], instr[20], instr[12 +: 8], wa3, opcode );
        if( instr == '0 )
            instr_sep = $psprintf("Flushed : %b", instr );
        if( instr_sep == "" )
            instr_sep = $psprintf("%b", instr );
    endtask : instr_separation

endclass : pars_instr
