/*
*  File            :   nf_log_writer.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.11
*  Language        :   SystemVerilog
*  Description     :   This is class for writing log info in html and txt document and printing info in terminal
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../tb/nf_tb.svh"

import NF_BTC::*;

class nf_log_writer extends nf_bt_class;

    logic   [31 : 0]    reg_file_l  [31 : 0];   // local register file
    logic   [1  : 0]    table_c     [31 : 0];   // change table
    string              html_str = "";          // html string
    string              txt_str = "";           // text string

    integer             html_p;     // pointer to html log file
    integer             txt_p;      // pointer to text log file
    // constructor
    function new();
        name = "Log writer";
    endfunction : new
    // task for building logger
    task build(string out_file);

        for( integer i = 0 ; i < 32 ; i++ )
        begin
            reg_file_l[i]   = '0;
            table_c[i]  = '0;
        end

        if( `log_html )
        begin
            html_p = $fopen( { out_file , ".html"} ,"w");
            if( !html_p )
            begin
                $display("Error! File %s not open.", { out_file , ".html"} );
                $stop;
            end
        end

        if( `log_txt )
        begin
            txt_p = $fopen( { out_file , ".log"} ,"w");
            if( !txt_p )
            begin
                $display("Error! File %s not open.", { out_file , ".log"} );
                $stop;
            end
        end

        super.build();

    endtask : build
    // task for writing log info in file
    task write_log( logic [31 : 0] reg_file[31 : 0], string log_str);

        begin
            fork
                if( `log_html )
                begin
                    html_str = "";
                    form_info_html(reg_file,log_str);
                    form_html_table(8, 4);
                    $fwrite(html_p,html_str);
                end
                begin
                    txt_str = "";
                    write_txt_table(reg_file);
                    txt_str = { log_str , txt_str };
                    if( `log_txt )
                        $fwrite( txt_p, txt_str );
                    if( `log_term )
                    $write( txt_str );
                end
            join
        end

    endtask : write_log
    // task for formirate current instruction info in html
    task form_info_html(logic [31 : 0] reg_file[31 : 0], string log_str);

        integer i;
        i = 0;

        for( i = 0 ; i < 32 ; i++ )
        begin
            table_c[i] = reg_file_l[i] == reg_file[i] ? 2'b00 : 2'b01;
            if( $isunknown( | table_c[i] ) )
            begin
                if( $isunknown( | reg_file[i] ) )
                    table_c[i] = 2'b10;
                else
                    table_c[i] = 2'b01;
                reg_file_l[i] = reg_file[i];
            end
            else
                reg_file_l[i] = table_c[i] == 2'b00 ? 
                                reg_file_l[i] : 
                                reg_file[i];
        end
        html_str = { html_str , "<font size = \"4\">" };
        html_str = { html_str , "<pre>" };
        html_str = { html_str , log_str };
        html_str = { html_str , "</pre>" };
        html_str = { html_str , "</font>\n" };

    endtask : form_info_html
    // task for formirate register file values in html table
    task form_html_table(integer row, integer col);

        integer tr_i;
        integer td_i;
        string  reg_value;
        tr_i = 0;
        td_i = 0;
        reg_value = "";

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
                html_str = { html_str , $psprintf(" %5s 0x%H ", reg_list[ tr_i * col + td_i ], reg_value.toupper()) };
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

    endtask : form_html_table
    // task for writing register file values in txt file ( table )
    task write_txt_table(logic [31 : 0] reg_file[31 : 0]);

        integer reg_addr;
        reg_addr = '0;
        txt_str = "register list :\n";

        do
        begin
            txt_str =  {
                            txt_str , 
                            $psprintf("%5s", reg_list[reg_addr] ) , 
                            $psprintf(" = 0x%h | ", reg_file[reg_addr] ) , 
                            reg_addr[0 +: 2] == 3 ? "\n" : "" 
                        };
            reg_addr++;
        end
        while( reg_addr != 32 );

    endtask : write_txt_table

endclass : nf_log_writer
