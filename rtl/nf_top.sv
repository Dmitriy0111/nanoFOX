/*
*  File            :   nf_top.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.27
*  Language        :   SystemVerilog
*  Description     :   This is top unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_top
(
    input   logic                           clk,
    input   logic                           resetn,
    input   logic   [25 : 0]                div,
    //pwm side
    output  logic                           pwm,
    //gpio side
    input   logic   [`NF_GPIO_WIDTH-1 : 0]  gpi,
    output  logic   [`NF_GPIO_WIDTH-1 : 0]  gpo,
    output  logic   [`NF_GPIO_WIDTH-1 : 0]  gpd
`ifdef debug
    ,
    input   logic   [4  : 0]                reg_addr,
    output  logic   [31 : 0]                reg_data
`endif
);
    //instruction memory
    logic   [31 : 0]    instr_addr;
    logic   [31 : 0]    instr;
    logic               cpu_en;
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

    assign  rd_dm_s[3]  = '0;

    nf_cpu nf_cpu_0
    (
        .clk            ( clk               ),
        .resetn         ( resetn            ),
        .instr_addr     ( instr_addr        ),  // cpu enable signal
        .instr          ( instr             ),  // instruction address
        .cpu_en         ( cpu_en            ),  // instruction data
        .addr_dm        ( addr_dm           ),  // data memory address
        .we_dm          ( we_dm             ),  // data memory write enable
        .wd_dm          ( wd_dm             ),  // data memory write data
        .rd_dm          ( rd_dm             )   // data memory read data
    `ifdef debug
        ,
        .reg_addr       ( reg_addr          ),  // register address
        .reg_data       ( reg_data          )   // register data
    `endif
    );

    //creating instruction memory 
    nf_instr_mem 
    #( 
        .depth          ( 64                ) 
    )
    instr_mem_0
    (
        .addr           ( instr_addr >> 2   ),  // instruction address
        .instr          ( instr             )   // instruction data
    );

    // creating strob generating unit for "dividing" clock
    nf_clock_div nf_clock_div_0
    (
        .clk            ( clk               ),
        .resetn         ( resetn            ),
        .div            ( div               ),  // div_number
        .en             ( cpu_en            )   // enable strobe
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
        .addr_dm_m      ( addr_dm           ),  // master address
        .we_dm_m        ( we_dm             ),  // master write enable
        .wd_dm_m        ( wd_dm             ),  // master write data
        .rd_dm_m        ( rd_dm             ),  // master read data
        //devices side
        .clk_s          ( clk_s             ),  // slave clock
        .resetn_s       ( resetn_s          ),  // slave reset
        .addr_dm_s      ( addr_dm_s         ),  // slave address
        .we_dm_s        ( we_dm_s           ),  // slave write enable
        .wd_dm_s        ( wd_dm_s           ),  // slave write data
        .rd_dm_s        ( rd_dm_s           )   // slave read data
    );

    nf_ram
    #(
        .depth          ( `ram_depth        )
    )
    nf_ram_0
    (
        .clk            ( clk_s             ),
        .addr           ( addr_dm_s >> 2    ),  // address
        .we             ( we_dm_s[0]        ),  // write enable
        .wd             ( wd_dm_s           ),  // write data
        .rd             ( rd_dm_s[0]        )   // read data
    );

    nf_gpio
    #(
        .gpio_w         ( `NF_GPIO_WIDTH    )
    ) 
    nf_gpio_0
    (
        .clk            ( clk_s             ),
        .resetn         ( resetn_s          ),
        //nf_router side
        .addr           ( addr_dm_s         ),  // address
        .we             ( we_dm_s[1]        ),  // write enable
        .wd             ( wd_dm_s           ),  // write data
        .rd             ( rd_dm_s[1]        ),  // read data
        //gpio_side
        .gpi            ( gpi               ),  // GPIO input
        .gpo            ( gpo               ),  // GPIO output
        .gpd            ( gpd               )   // GPIO direction
    );

    nf_pwm
    #(
        .pwm_width      ( 8                 )
    )
    nf_pwm_0
    (
        .clk            ( clk_s             ),
        .resetn         ( resetn_s          ),
        //nf_router side
        .addr           ( addr_dm_s         ),  // address
        .we             ( we_dm_s[2]        ),  // write enable
        .wd             ( wd_dm_s           ),  // write data
        .rd             ( rd_dm_s[2]        ),  // read data
        //pmw_side
        .pwm_clk        ( clk_s             ),  // PWM clock input
        .pwm_resetn     ( resetn_s          ),  // PWM reset input
        .pwm            ( pwm               )   // PWM output signal
    );

endmodule : nf_top
