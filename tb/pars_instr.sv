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
    bit     [1  : 0]    instr_type;
    bit     [4  : 0]    opcode    ;
    bit     [2  : 0]    funct3    ;
    bit     [6  : 0]    funct7    ;
    bit     [19 : 0]    imm_data_u;
    bit     [11 : 0]    imm_data_i;
    logic   [11 : 0]    imm_data_b;
    logic   [11 : 0]    imm_data_s;
    instr_cf            instr_cf_0;

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
        instr_type = instr[0  +: 2];
        opcode     = instr[2  +: 5];
        funct3     = instr[12 +: 3];
        funct7     = instr[25 +: 7];
        instr_cf_0 = {opcode,funct3,funct7};
        // immediate data
        imm_data_u = instr[12 +: 20];
        imm_data_i = instr[20 +: 12];
        imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };
        imm_data_s = { instr[25 +: 7] , instr[7 +: 5] };
        casex( instr_type )
            `RVI :
            begin
                casex( instr_cf_0 )
                    //  R - type command's
                    ADD     : instruction_s = $psprintf("ADD  rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3] , registers_list[ra1] , registers_list[ra2]  );
                    SUB     : instruction_s = $psprintf("SUB  rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3] , registers_list[ra1] , registers_list[ra2]  );
                    OR      : instruction_s = $psprintf("OR   rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3] , registers_list[ra1] , registers_list[ra2]  );
                    //  I - type command's
                    SLLI    : instruction_s = $psprintf("SLLI rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3] , registers_list[ra1] , imm_data_i           );
                    ADDI    : instruction_s = $psprintf("ADDI rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3] , registers_list[ra1] , imm_data_i           );
                    LW      : instruction_s = $psprintf("LW   rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3] , registers_list[ra1] , imm_data_i           );
                    //  U - type command's
                    LUI     : instruction_s = $psprintf("LUI  rd  = %s, Imm = 0x%h"          , registers_list[wa3] , imm_data_u                                 );
                    //  B - type command's
                    BEQ     : instruction_s = $psprintf("BEQ  rs1 = %s, rs2 = %s, Imm = 0x%h", registers_list[ra1] , registers_list[ra2] , imm_data_b           );
                    //  S - type command's
                    SW      : instruction_s = $psprintf("SW   rs1 = %s, rs2 = %s, Imm = 0x%h", registers_list[ra1] , registers_list[ra2] , imm_data_s           );
                    //  J - type command's
                    //  in the future
                endcase
                instruction_s = {"RVI " , instruction_s};
            end
            `ANY :
                casex( { opcode , funct3 , funct7 } )
                    //  Other's instructions
                    { VER.OP  , VER.F3  , VER.F7  } : instruction_s =   $psprintf("ERROR! Unknown instruction = %b", instr                                      );
                endcase
        endcase
        // Flushed instruction
        if( instr == '0 )
            instruction_s =                                             $psprintf("Flushed instruction",                                                        );
        
        $display("%s", instruction_s);
        if( `debug_lev0 )
        begin
            instr_separation(instr,instr_sep);
        end

    endtask : pars

    task instr_separation(bit [31 : 0] instr, ref string instr_sep);

        instr_sep= "";

        ra1         = instr[15 +: 5];
        ra2         = instr[20 +: 5];
        wa3         = instr[7  +: 5];
        instr_type  = instr[0  +: 2];
        opcode      = instr[0  +: 5];
        funct3      = instr[12 +: 3];
        funct7      = instr[25 +: 7];
        case( instr_type )
            `RVI :
            begin
                case( 1 )
                    ( opcode == 'b01100 )   : instr_sep = $psprintf("R-type  : %b_%b_%b_%b_%b_%b"       , funct7, ra2, ra1, funct3, wa3, opcode                                         );
                    ( opcode == 'b00100 ) , 
                    ( opcode == 'b00000 ) , 
                    ( opcode == 'b11001 )   : instr_sep = $psprintf("I-type  : %b_%b_%b_%b_%b"          , instr[20 +: 12], ra1, funct3, wa3, opcode                                     );
                    ( opcode == 'b01000 )   : instr_sep = $psprintf("S-type  : %b_%b_%b_%b_%b_%b"       , instr[25 +: 7], ra2, ra1, funct3, instr[7  +: 5], opcode                      );
                    ( opcode == 'b11000 )   : instr_sep = $psprintf("B-type  : %b_%b_%b_%b_%b_%b_%b_%b" , instr[31], instr[25 +: 6], ra2, ra1, funct3, instr[8  +: 5], instr[7], opcode );
                    ( opcode == 'b01101 ) ,
                    ( opcode == 'b00101 )   : instr_sep = $psprintf("U-type  : %b_%b_%b"                , instr[12 +: 20], wa3, opcode                                                  );
                    ( opcode == 'b11011 )   : instr_sep = $psprintf("J-type  : %b_%b_%b_%b_%b_%b"       , instr[31], instr[21 +: 10], instr[20], instr[12 +: 8], wa3, opcode            );
                endcase
                instr_sep = { "RVI " , instr_sep };
            end
        endcase

        if( instr == '0 )
            instr_sep = $psprintf("Flushed : %b", instr );
            
        if( instr_sep == "" )
            instr_sep = $psprintf("%b", instr );

    endtask : instr_separation

endclass : pars_instr
