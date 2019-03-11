/*
*  File            :   nf_pars_instr.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is class for parsing instruction from instruction memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_tb.svh"
`include "../inc/nf_cpu.svh" 

import   NF_BTC::*;

class nf_pars_instr ;

    class insrt_cf_name extends nf_bt_class;
    
        string      instr_name;
        instr_cf    instr_cf_;

        function new( string instr_name_, instr_cf instr_cf__ );
            instr_name = instr_name_;
            instr_cf_  = instr_cf__;
        endfunction : new

        task instr_decode( instr_cf instr_cf_check, logic [31 : 0] instr, ref string instr_s, ref string instr_sep );

            // destination and sources registers
            bit     [4  : 0]    ra1       ;
            bit     [4  : 0]    ra2       ;
            bit     [4  : 0]    wa3       ;
            // immediate data
            bit     [19 : 0]    imm_data_u;
            bit     [11 : 0]    imm_data_i;
            bit     [11 : 0]    imm_data_b;
            bit     [11 : 0]    imm_data_s;
            bit     [19 : 0]    imm_data_j;
            // operation type fields
            bit     [1  : 0]    instr_type;
            bit     [4  : 0]    opcode    ;
            bit     [2  : 0]    funct3    ;
            bit     [6  : 0]    funct7    ;

            // destination and sources registers
            ra1         = instr[15 +: 5];
            ra2         = instr[20 +: 5];
            wa3         = instr[7  +: 5];
            // immediate data
            imm_data_u  = instr[12 +: 20];
            imm_data_i  = instr[20 +: 12];
            imm_data_b  = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };
            imm_data_s  = { instr[25 +: 7] , instr[7 +: 5] };
            imm_data_j  = { instr[31] , instr[12 +: 8] , instr[20] , instr[21 +: 10] };
            // operation type fields
            instr_type  = instr[0  +: 2];
            opcode      = instr[0  +: 5];
            funct3      = instr[12 +: 3];
            funct7      = instr[25 +: 7];

            if( instr_cf_check.OP == 'b01100 ) 
            begin
                instr_s =   $psprintf("%s rd  = %4s, rs1 = %4s, rs2 = %4s"          , instr_name , reg_list[wa3] , reg_list[ra1] , reg_list[ra2]                                );
                if( `debug_lev0 )
                    instr_sep = $psprintf("R-type  : %b_%b_%b_%b_%b_%b_%b"          , funct7, ra2, ra1, funct3, wa3, opcode, instr_type                                         );
            end
            else if ( 
                        instr_cf_check.OP == 'b00100 ||
                        instr_cf_check.OP == 'b00000 ||
                        instr_cf_check.OP == 'b11001 
                    ) 
            begin
                instr_s =   $psprintf("%s rd  = %4s, rs1 = %4s, Imm = 0x%h"         , instr_name , reg_list[wa3] , reg_list[ra1] , imm_data_i                                   );
                if( `debug_lev0 )
                    instr_sep = $psprintf("I-type  : %b_%b_%b_%b_%b_%b"             , instr[20 +: 12], ra1, funct3, wa3, opcode, instr_type                                     );
            end
            else if ( instr_cf_check.OP == 'b11000 ) 
            begin
                instr_s =   $psprintf("%s rs1 = %4s, rs2 = %4s, Imm = 0x%h"         , instr_name , reg_list[ra1] , reg_list[ra2] , imm_data_b                                   );
                if( `debug_lev0 )
                    instr_sep = $psprintf("B-type  : %b_%b_%b_%b_%b_%b_%b_%b_%b"    , instr[31], instr[25 +: 6], ra2, ra1, funct3, instr[8  +: 5], instr[7], opcode, instr_type );
            end
            else if ( instr_cf_check.OP == 'b01000 ) 
            begin
                instr_s =   $psprintf("%s rs1 = %4s, rs2 = %4s, Imm = 0x%h"         , instr_name , reg_list[ra1] , reg_list[ra2] , imm_data_s                                   );
                if( `debug_lev0 )
                    instr_sep = $psprintf("S-type  : %b_%b_%b_%b_%b_%b_%b"          , instr[25 +: 7], ra2, ra1, funct3, instr[7  +: 5], opcode, instr_type                      );
            end
            else if ( 
                        instr_cf_check.OP == 'b01101 ||
                        instr_cf_check.OP == 'b00101 
                    ) 
            begin
                instr_s =   $psprintf("%s rd  = %4s, Imm = 0x%h"                    , instr_name , reg_list[wa3] , imm_data_u                                                   );
                if( `debug_lev0 )
                    instr_sep = $psprintf("U-type  : %b_%b_%b_%b"                   , instr[12 +: 20], wa3, opcode, instr_type                                                  );
            end
            else if ( instr_cf_check.OP == 'b11011 ) 
            begin
                instr_s =   $psprintf("%s rd  = %4s, Imm = 0x%h"                    , instr_name , reg_list[wa3] , imm_data_j                                                   );
                if( `debug_lev0 )
                    instr_sep = $psprintf("J-type  : %b_%b_%b_%b_%b_%b_%b"          , instr[31], instr[21 +: 10], instr[20], instr[12 +: 8], wa3, opcode, instr_type            );
            end

        endtask : instr_decode

    endclass : insrt_cf_name  

    instr_cf            instr_cf_0;

    insrt_cf_name i_list [];

    function new();

        i_list = new[37];

        i_list[ 0] = new( "LUI   " , LUI   );
        i_list[ 1] = new( "AUIPC " , AUIPC );
        i_list[ 2] = new( "JAL   " , JAL   );
        i_list[ 3] = new( "JALR  " , JALR  );
        i_list[ 4] = new( "BEQ   " , BEQ   );
        i_list[ 5] = new( "BNE   " , BNE   );
        i_list[ 6] = new( "BLT   " , BLT   );
        i_list[ 7] = new( "BGE   " , BGE   );
        i_list[ 8] = new( "BLTU  " , BLTU  );
        i_list[ 9] = new( "BGEU  " , BGEU  );
        i_list[10] = new( "LB    " , LB    );
        i_list[11] = new( "LH    " , LH    );
        i_list[12] = new( "LW    " , LW    );
        i_list[13] = new( "LBU   " , LBU   );
        i_list[14] = new( "LHU   " , LHU   );
        i_list[15] = new( "SB    " , SB    );
        i_list[16] = new( "SH    " , SH    );
        i_list[17] = new( "SW    " , SW    );
        i_list[18] = new( "ADDI  " , ADDI  );
        i_list[19] = new( "SLTI  " , SLTI  );
        i_list[20] = new( "SLTIU " , SLTIU );
        i_list[21] = new( "XORI  " , XORI  );
        i_list[22] = new( "ORI   " , ORI   );
        i_list[23] = new( "ANDI  " , ANDI  );
        i_list[24] = new( "SLLI  " , SLLI  );
        i_list[25] = new( "SRLI  " , SRLI  );
        i_list[26] = new( "SRAI  " , SRAI  );
        i_list[27] = new( "ADD   " , ADD   );
        i_list[28] = new( "SUB   " , SUB   );
        i_list[29] = new( "SLL   " , SLL   );
        i_list[30] = new( "SLT   " , SLT   );
        i_list[31] = new( "SLTU  " , SLTU  );
        i_list[32] = new( "XOR   " , XOR   );
        i_list[33] = new( "SRL   " , SRL   );
        i_list[34] = new( "SRA   " , SRA   );
        i_list[35] = new( "OR    " , OR    );
        i_list[36] = new( "AND   " , AND   );

        $timeformat(-9, 2, " ns", 7);

    endfunction : new

    task pars(logic [31 : 0] instr, ref string instruction_s, ref string instr_sep);

        // operation type fields
        logic   [1  : 0]    instr_type;
        logic   [4  : 0]    opcode    ;
        logic   [2  : 0]    funct3    ;
        logic   [6  : 0]    funct7    ;
        // operation type fields
        instr_type  = instr[0  +: 2];
        opcode      = instr[2  +: 5];
        funct3      = instr[12 +: 3];
        funct7      = instr[25 +: 7];
        instruction_s = "";
        instr_sep     = "";

        instr_cf_0 = { instr_type , opcode , funct3 , funct7 };
        casex( instr_cf_0.IT )
            `RVI    :
            begin
                foreach( i_list[i] )
                begin
                    casex( instr_cf_0 )
                        i_list[i].instr_cf_ : 
                            i_list[i].instr_decode( instr_cf_0 , instr , instruction_s , instr_sep );
                    endcase
                end
                
                instruction_s = {"RVI " , instruction_s};
            end
            `RVC_0  : instruction_s = {"RVC_0"};
            `RVC_1  : instruction_s = {"RVC_1"};
            `RVC_2  : instruction_s = {"RVC_2"};
        endcase

        if( $isunknown(instr) || ( ( instruction_s == "" ) && ( instr != '0 ) ) )
            instruction_s = $psprintf("ERROR! Unknown instruction = %b", instr  );
        else if( instr == '0 )
            instruction_s = $psprintf("Flushed instruction",                    );
        
        if( `debug_lev0 )
        begin
            if( $isunknown(instr) || ( ( instruction_s == "" ) && ( instr != '0 ) ) )
                instr_sep = $psprintf("ERROR! Unknown instruction = %b", instr );
            else if( instr == '0 )
                instr_sep = $psprintf("Flushed : %b", instr );
        end

    endtask : pars

endclass : nf_pars_instr
