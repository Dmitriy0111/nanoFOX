/*
*  File            :   nf_pars.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.23
*  Language        :   SystemVerilog
*  Description     :   This is class for parsing instruction from instruction memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_cpu.svh"
`include "nf_tb.svh"

class nf_pars;

    bit     [4  : 0]    ra1        ;
    bit     [4  : 0]    ra2        ;
    bit     [4  : 0]    wa3        ;
    logic   [6  : 0]    opcode     ;
    logic   [2  : 0]    funct3     ;
    logic   [6  : 0]    funct7     ;
    logic   [19 : 0]    imm_data_u ;
    logic   [11 : 0]    imm_data_i ;
    logic   [11 : 0]    imm_data_b ;
    logic   [11 : 0]    imm_data_s ;
    logic   [31 : 0]    reg_file_l  [31 : 0];
    logic   [31 : 0]    table_html  [31 : 0];
    logic   [1  : 0]    table_c     [31 : 0];
    string              html_str = "";
    integer             html_p;

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

    task pars(logic [31 : 0] instr, ref string instruction_s,ref string instr_sep);

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
            // R - type command's
            { `C_ADD  , `F3_ADD  , `F7_ADD  } : instruction_s = $psprintf("ADD  rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            { `C_SUB  , `F3_SUB  , `F7_SUB  } : instruction_s = $psprintf("SUB  rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            { `C_OR   , `F3_OR   , `F7_ANY  } : instruction_s = $psprintf("OR   rd  = %s, rs1 = %s, rs2 = %s"  , registers_list[wa3], registers_list[ra1], registers_list[ra2]  );
            // I - type command's
            { `C_SLLI , `F3_SLLI , `F7_ANY  } : instruction_s = $psprintf("SLLI rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3], registers_list[ra1], imm_data_i           );
            { `C_ADDI , `F3_ADDI , `F7_ANY  } : instruction_s = $psprintf("ADDI rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3], registers_list[ra1], imm_data_i           );
            { `C_LW   , `F3_LW   , `F7_ANY  } : instruction_s = $psprintf("LW   rd  = %s, rs1 = %s, Imm = 0x%h", registers_list[wa3], registers_list[ra1], imm_data_i           );
            // U - type command's
            { `C_LUI  , `F3_ANY  , `F7_ANY  } : instruction_s = $psprintf("LUI  rd  = %s, Imm = 0x%h"          , registers_list[wa3], imm_data_u                                );
            // B - type command's
            { `C_BEQ  , `F3_BEQ  , `F7_ANY  } : instruction_s = $psprintf("BEQ  rs1 = %s, rs2 = %s, Imm = 0x%h", registers_list[ra1], registers_list[ra2], imm_data_b           );
            // S - type command's
            { `C_SW   , `F3_SW   , `F7_ANY  } : instruction_s = $psprintf("SW   rs1 = %s, rs2 = %s, Imm = 0x%h", registers_list[ra1], registers_list[ra2], imm_data_s           );
            // J - type command's
            // in the future
            // Other's instructions
            { `C_ANY  , `F3_ANY  , `F7_ANY  } : instruction_s = $psprintf("Unknown instruction"                ,                                                                );
        endcase

        if( $isunknown( { opcode , funct3 , funct7 } ) )
            instruction_s = $psprintf("Unknown instruction");

        if( `debug_lev0 )
            instr_separation(instr,instr_sep);

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
            instr_sep = $psprintf("R-type : %b_%b_%b_%b_%b_%b", funct7, ra2, ra1, funct3, wa3, opcode );
        if( ( opcode == 'b0010011 ) || ( opcode == 'b0000011 ) || ( opcode == 'b1100111 ) )
            instr_sep = $psprintf("I-type : %b_%b_%b_%b_%b", instr[20 +: 12], ra1, funct3, wa3, opcode );
        if( opcode == 'b0100011 )
            instr_sep = $psprintf("S-type : %b_%b_%b_%b_%b_%b", instr[25 +: 7], ra2, ra1, funct3, instr[7  +: 5], opcode );
        if( opcode == 'b1100011 )
            instr_sep = $psprintf("B-type : %b_%b_%b_%b_%b_%b_%b_%b", instr[31], instr[25 +: 6], ra2, ra1, funct3, instr[8  +: 5], instr[7], opcode );
        if( ( opcode == 'b0110111 ) || ( opcode == 'b0010111 ) )
            instr_sep = $psprintf("U-type : %b_%b_%b", instr[12 +: 20], wa3, opcode );
        if( opcode == 'b1101111 )
            instr_sep = $psprintf("J-type : %b_%b_%b_%b_%b_%b", instr[31], instr[21 +: 10], instr[20], instr[12 +: 8], wa3, opcode );
        if( instr_sep == "" )
            instr_sep = $psprintf("%b", instr );
        if( $isunknown( opcode ) )
            instr_sep = $psprintf("%b", instr );

    endtask : instr_separation

    task write_txt_table(logic [31 : 0] reg_file[31 : 0], ref string reg_str);

        integer reg_addr;
        string  reg_value;
        reg_addr = '0;
        reg_str = "register list :\n";

        do
        begin
            reg_value = $psprintf("%h",reg_file[reg_addr]);
            reg_str =  {
                            reg_str , 
                            $psprintf("%5s", registers_list[reg_addr] ) , 
                            $psprintf(" = 0x%s | ", reg_value.toupper() ) , 
                            reg_addr[0 +: 2] == 3 ? "\n" : "" 
                        };
            reg_addr++;
        end
        while( reg_addr != 32 );

    endtask : write_txt_table

    task build_html_loger(string out_file);

        for(integer i = 0; i < 32; i++)
        begin
            reg_file_l[i]   = '0;
            table_c[i]  = '0;
        end
        html_p = $fopen( { out_file , ".html"} ,"w");
        if( !html_p )
        begin
            $display("Error! File %s not open.", { out_file , ".html"} );
            $stop;
        end

    endtask : build_html_loger

    task write_html_log( logic [31 : 0] reg_file[31 : 0], string log_str);

        html_str = "";
        write_info_html(reg_file,log_str);
        write_html_table(8, 4);
        $fwrite(html_p,html_str);

    endtask : write_html_log

    task write_info_html(logic [31 : 0] reg_file[31 : 0], string log_str);

        integer i;
        i = 0;
        for( i = 0 ; i < 32 ; i++ )
        begin
            table_c[i] = reg_file_l[i] == reg_file[i] ? 2'b00 : 2'b01;
            if( $isunknown( | reg_file[i] ) )
                table_c[i] = 2'b10;
            reg_file_l[i]  =    table_c[i] == 2'b00 ? 
                                reg_file_l[i] : 
                                reg_file[i];
        end
        html_str = { html_str , "<font size = \"4\">" };
        html_str = { html_str , "<pre>" };
        html_str = { html_str , log_str };
        html_str = { html_str , "register list :" };
        html_str = { html_str , "</pre>" };
        html_str = { html_str , "</font>\n" };

    endtask : write_info_html

    task write_html_table(integer row, integer col);

        integer tr_i;
        integer td_i;
        string  reg_value;
        reg_value = "";
        tr_i = 0;
        td_i = 0;

        html_str = { html_str , "<table border=\"1\">\n" };

        do
        begin
            html_str = { html_str , "    <tr>\n" };
            do
            begin
                html_str = { html_str , $psprintf("        <td %s>",    table_c[ tr_i * col + td_i ] == 2'b00 ? "bgcolor = \"white\"" : ( 
                                                                        table_c[ tr_i * col + td_i ] == 2'b01 ? "bgcolor = \"green\"" : 
                                                                                                                "bgcolor = \"red\"" ) ) };
                html_str = { html_str , "<pre>" };
                reg_value = $psprintf("%h",reg_file_l[ tr_i * col + td_i ]);
                html_str = { html_str , $psprintf(" %5s 0x%H ", registers_list[ tr_i * col + td_i ], reg_value.toupper()) };
                html_str = { html_str , "</pre>" };
                html_str = { html_str , "</td>\n" };
                td_i++;
            end
            while( td_i != col );
            html_str = { html_str , "    </tr>\n" };
            tr_i++;
            td_i = 0;
        end
        while( tr_i != row );

        html_str = { html_str , "</table>" };

    endtask : write_html_table

endclass : nf_pars
