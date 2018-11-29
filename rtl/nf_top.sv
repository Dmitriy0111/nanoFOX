/*
*  File            :   nf_top.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.27
*  Language        :   SystemVerilog
*  Description     :   This is top unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_top
(
    input   logic               clk,
    input   logic               resetn,
    input   logic   [25 : 0]    div
`ifdef debug
    ,
    input   logic   [4  : 0]    reg_addr,
    output  logic   [31 : 0]    reg_data
`endif
);
    //instruction memory
    logic   [31 : 0]    instr_addr;
    logic   [31 : 0]    instr;
    //data memory and others's
    logic   [31 : 0]    addr_dm;
    logic               we_dm;
    logic   [31 : 0]    wd_dm;
    logic   [31 : 0]    rd_dm;
    //slave's side
    localparam                          Slave_n = `slave_number ;
    logic                               clk_s;
    logic                               resetn_s;
    logic   [31 : 0]                    addr_dm_s;
    logic   [Slave_n-1 : 0]             we_dm_s;
    logic   [31 : 0]                    wd_dm_s;
    logic   [Slave_n-1 : 0][31 : 0]     rd_dm_s;

    nf_cpu nf_cpu_0
    (
        .clk            ( clk               ),
        .resetn         ( resetn            ),
        .div            ( div               ),
        .instr_addr     ( instr_addr        ),
        .instr          ( instr             ),
        .addr_dm        ( addr_dm           ),
        .we_dm          ( we_dm             ),
        .wd_dm          ( wd_dm             ),
        .rd_dm          ( rd_dm             )
    `ifdef debug
        ,
        .reg_addr       ( reg_addr          ),
        .reg_data       ( reg_data          )
    `endif
    );

    //creating instruction memory 
    nf_instr_mem 
    #( 
        .depth          ( 64                ) 
    )
    instr_mem_0
    (
        .addr           ( instr_addr >> 2   ),
        .instr          ( instr             )
    );

    nf_router
    #(
        .Slave_n        ( `slave_number     )
    )
    nf_router_0
    (
        .clk            ( clk               ),
        .resetn         ( resetn            ),
        //cpu side
        .addr_dm_m      ( addr_dm >> 2      ),
        .we_dm_m        ( we_dm             ),
        .wd_dm_m        ( wd_dm             ),
        .rd_dm_m        ( rd_dm             ),
        //devices side
        .clk_s          ( clk_s             ),
        .resetn_s       ( resetn_s          ),
        .addr_dm_s      ( addr_dm_s         ),
        .we_dm_s        ( we_dm_s           ),
        .wd_dm_s        ( wd_dm_s           ),
        .rd_dm_s        ( rd_dm_s           )
    );

    nf_ram
    #(
        .depth          ( `ram_depth        )
    )
    nf_ram_0
    (
        .clk            ( clk_s             ),
        .addr           ( addr_dm_s         ),
        .we             ( we_dm_s[0]        ),
        .wd             ( wd_dm_s           ),
        .rd             ( rd_dm_s[0]        )
    );

    nf_gpio nf_gpio_0
    (
        .clk            ( clk_s             ),
        .resetn         ( resetn_s          ),
        //nf_router side
        .addr           ( addr_dm_s         ),
        .we             ( we_dm_s[1]        ),
        .wd             ( wd_dm_s           ),
        .rd             ( rd_dm_s[1]        ),
        //gpio_side
        .gpi            (                   ),
        .gpo            (                   )
    );

    nf_pwm nf_pwm_0
    (
        .clk            ( clk_s             ),
        .resetn         ( resetn_s          ),
        //nf_router side
        .addr           ( addr_dm_s         ),
        .we             ( we_dm_s[2]        ),
        .wd             ( wd_dm_s           ),
        .rd             ( rd_dm_s[2]        ),
        //pmw_side
        .pwm            (                   )
    );

endmodule : nf_top
