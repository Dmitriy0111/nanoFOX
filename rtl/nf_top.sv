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
    input   logic   [7  : 0]                gpio_i_a,   // GPIO_A input
    output  logic   [7  : 0]                gpio_o_a,   // GPIO_A output
    output  logic   [7  : 0]                gpio_d_a,   // GPIO_A direction
    input   logic   [7  : 0]                gpio_i_b,   // GPIO_B input
    output  logic   [7  : 0]                gpio_o_b,   // GPIO_B output
    output  logic   [7  : 0]                gpio_d_b,   // GPIO_B direction
    output  logic                           pwm         // PWM output signal
`ifdef debug
    ,
    input   logic   [4  : 0]                reg_addr,
    output  logic   [31 : 0]                reg_data
`endif
);

    localparam          gpio_w  = `NF_GPIO_WIDTH,
                        slave_c = `SLAVE_COUNT;

    //instruction memory
    logic   [31 : 0]    addr_i;     // instruction address
    logic   [31 : 0]    rd_i;       // read instruction
    //data memory and others's
    logic   [31 : 0]    addr_dm;    // address data memory
    logic   [0  : 0]    we_dm;      // write enable signal
    logic   [31 : 0]    wd_dm;      // write data memory
    logic   [31 : 0]    rd_dm;      // read data memory
    logic   [0  : 0]    req_dm;     // request data memory signal
    logic   [0  : 0]    req_ack_dm; // request acknowledge data memory signal
    // PWM 
    logic               pwm_clk;    // PWM clock input
    logic               pwm_resetn; // PWM reset input   
    assign              pwm_clk = clk;
    assign              pwm_resetn = resetn;    
    // GPIO
    // GPIO port A
    logic   [gpio_w-1 : 0]   gpi_a;        // GPIO input
    logic   [gpio_w-1 : 0]   gpo_a;        // GPIO output
    logic   [gpio_w-1 : 0]   gpd_a;        // GPIO direction
    // GPIO port B
    logic   [gpio_w-1 : 0]   gpi_b;        // GPIO input
    logic   [gpio_w-1 : 0]   gpo_b;        // GPIO output
    logic   [gpio_w-1 : 0]   gpd_b;        // GPIO direction

    assign gpi_a    = gpio_i_a;
    assign gpio_o_a = gpo_a;
    assign gpio_d_a = gpd_a;
    assign gpi_b    = gpio_i_b;
    assign gpio_o_b = gpo_b;
    assign gpio_d_b = gpd_b;

    //creating one cpu unit
    nf_cpu nf_cpu_0
    (
        .clk        ( clk               ),
        .resetn     ( resetn            ),
        .addr_i     ( addr_i            ),  // instruction address
        .rd_i       ( rd_i              ),  // read instruction
        .addr_dm    ( addr_dm           ),  // address data memory
        .rd_dm      ( rd_dm             ),  // read data memory
        .wd_dm      ( wd_dm             ),  // write data memory
        .we_dm      ( we_dm             ),  // write enable signal
        .req_dm     ( req_dm            ),  // request data memory signal
        .req_ack_dm ( req_ack_dm        )   // request acknowledge data memory signal
    `ifdef debug
        ,
        .reg_addr   ( reg_addr          ),  // register address
        .reg_data   ( reg_data          )   // register data
    `endif
    );

    // AHB memory map
    `define NF_GPIO_A_ADDR_MATCH    32'h0000XXXX
    `define NF_GPIO_B_ADDR_MATCH    32'h0001XXXX
    `define NF_PWM_ADDR_MATCH       32'h0002XXXX
    localparam  logic   [slave_c-1 : 0][31 : 0] ahb_vector = 
                                                            {
                                                                `NF_PWM_ADDR_MATCH,
                                                                `NF_GPIO_B_ADDR_MATCH,
                                                                `NF_GPIO_A_ADDR_MATCH
                                                            };
    // AHB interconnect wires
    logic   [slave_c-1 : 0][31 : 0]         haddr_s;        // AHB - Slave HADDR 
    logic   [slave_c-1 : 0][31 : 0]         hwdata_s;       // AHB - Slave HWDATA 
    logic   [slave_c-1 : 0][31 : 0]         hrdata_s;       // AHB - Slave HRDATA 
    logic   [slave_c-1 : 0][0  : 0]         hwrite_s;       // AHB - Slave HWRITE 
    logic   [slave_c-1 : 0][1  : 0]         htrans_s;       // AHB - Slave HTRANS 
    logic   [slave_c-1 : 0][2  : 0]         hsize_s;        // AHB - Slave HSIZE 
    logic   [slave_c-1 : 0][2  : 0]         hburst_s;       // AHB - Slave HBURST 
    logic   [slave_c-1 : 0][1  : 0]         hresp_s;        // AHB - Slave HRESP 
    logic   [slave_c-1 : 0][0  : 0]         hready_s;       // AHB - Slave HREADYOUT 
    logic   [slave_c-1 : 0]                 hsel_s;         // AHB - Slave HSEL
    // creating AHB top module
    nf_ahb_top
    #(
        .slave_c        ( slave_c       ),
        .ahb_vector     ( ahb_vector    )
    )
    nf_ahb_top_0
    (
        .clk            ( clk           ),
        .resetn         ( resetn        ),
        // AHB slaves side
        .haddr_s        ( haddr_s       ),      // AHB - Slave HADDR 
        .hwdata_s       ( hwdata_s      ),      // AHB - Slave HWDATA 
        .hrdata_s       ( hrdata_s      ),      // AHB - Slave HRDATA 
        .hwrite_s       ( hwrite_s      ),      // AHB - Slave HWRITE 
        .htrans_s       ( htrans_s      ),      // AHB - Slave HTRANS 
        .hsize_s        ( hsize_s       ),      // AHB - Slave HSIZE 
        .hburst_s       ( hburst_s      ),      // AHB - Slave HBURST 
        .hresp_s        ( hresp_s       ),      // AHB - Slave HRESP 
        .hready_s       ( hready_s      ),      // AHB - Slave HREADYOUT 
        .hsel_s         ( hsel_s        ),      // AHB - Slave HSEL
        // core side
        .addr_dm        ( addr_dm       ),      // address data memory
        .rd_dm          ( rd_dm         ),      // read data memory
        .wd_dm          ( wd_dm         ),      // write data memory
        .we_dm          ( we_dm         ),      // write enable signal
        .req_dm         ( req_dm        ),      // request data memory signal
        .req_ack_dm     ( req_ack_dm    )       // request acknowledge data memory signal
    );
    // creating AHB GPIO A module
    nf_ahb_gpio 
    #(
        .gpio_w         ( gpio_w        ) 
    )
    nf_ahb_gpio_a
    (
        .hclk           ( clk           ),
        .hresetn        ( resetn        ),
        // Slaves side
        .haddr_s        ( haddr_s   [0] ),      // AHB - Slave HADDR
        .hwdata_s       ( hwdata_s  [0] ),      // AHB - Slave HWDATA
        .hrdata_s       ( hrdata_s  [0] ),      // AHB - Slave HRDATA
        .hwrite_s       ( hwrite_s  [0] ),      // AHB - Slave HWRITE
        .htrans_s       ( htrans_s  [0] ),      // AHB - Slave HTRANS
        .hsize_s        ( hsize_s   [0] ),      // AHB - Slave HSIZE
        .hburst_s       ( hburst_s  [0] ),      // AHB - Slave HBURST
        .hresp_s        ( hresp_s   [0] ),      // AHB - Slave HRESP
        .hready_s       ( hready_s  [0] ),      // AHB - Slave HREADYOUT
        .hsel_s         ( hsel_s    [0] ),      // AHB - Slave HBURST
        //gpio_side
        .gpi            ( gpi_a         ),      // GPIO input
        .gpo            ( gpo_a         ),      // GPIO output
        .gpd            ( gpd_a         )       // GPIO direction
    );
    // creating AHB GPIO B module
    nf_ahb_gpio 
    #(
        .gpio_w         ( gpio_w        ) 
    )
    nf_ahb_gpio_b
    (
        .hclk           ( clk           ),
        .hresetn        ( resetn        ),
        // Slaves side
        .haddr_s        ( haddr_s   [1] ),      // AHB - Slave HADDR
        .hwdata_s       ( hwdata_s  [1] ),      // AHB - Slave HWDATA
        .hrdata_s       ( hrdata_s  [1] ),      // AHB - Slave HRDATA
        .hwrite_s       ( hwrite_s  [1] ),      // AHB - Slave HWRITE
        .htrans_s       ( htrans_s  [1] ),      // AHB - Slave HTRANS
        .hsize_s        ( hsize_s   [1] ),      // AHB - Slave HSIZE
        .hburst_s       ( hburst_s  [1] ),      // AHB - Slave HBURST
        .hresp_s        ( hresp_s   [1] ),      // AHB - Slave HRESP
        .hready_s       ( hready_s  [1] ),      // AHB - Slave HREADYOUT
        .hsel_s         ( hsel_s    [1] ),      // AHB - Slave HBURST
        //gpio_side
        .gpi            ( gpi_b         ),      // GPIO input
        .gpo            ( gpo_b         ),      // GPIO output
        .gpd            ( gpd_b         )       // GPIO direction
    );
    // creating AHB PWM module
    nf_ahb_pwm
    #(
        .pwm_width      ( 8             )
    )
    nf_ahb_pwm_0
    (
        .hclk           ( clk           ),
        .hresetn        ( resetn        ),
        // Slaves side
        .haddr_s        ( haddr_s   [2] ),      // AHB - Slave HADDR
        .hwdata_s       ( hwdata_s  [2] ),      // AHB - Slave HWDATA
        .hrdata_s       ( hrdata_s  [2] ),      // AHB - Slave HRDATA
        .hwrite_s       ( hwrite_s  [2] ),      // AHB - Slave HWRITE
        .htrans_s       ( htrans_s  [2] ),      // AHB - Slave HTRANS
        .hsize_s        ( hsize_s   [2] ),      // AHB - Slave HSIZE
        .hburst_s       ( hburst_s  [2] ),      // AHB - Slave HBURST
        .hresp_s        ( hresp_s   [2] ),      // AHB - Slave HRESP
        .hready_s       ( hready_s  [2] ),      // AHB - Slave HREADYOUT
        .hsel_s         ( hsel_s    [2] ),      // AHB - Slave HBURST
        // pmw_side
        .pwm_clk        ( pwm_clk       ),      // PWM clock input
        .pwm_resetn     ( pwm_resetn    ),      // PWM reset input
        .pwm            ( pwm           )       // PWM output signal
    );
    //creating one instruction/data memory
    nf_dp_ram
    #(
        .depth      ( 256               ) 
    )
    nf_dp_ram_0
    (
        .clk        ( clk               ),
        // Port 1
        .addr_p1    ( addr_i >> 2       ),  // Port-1 addr
        .we_p1      ( '0                ),  // Port-1 write enable
        .wd_p1      ( '0                ),  // Port-1 write data
        .rd_p1      ( rd_i              )   // Port-1 read data
        // Port 2
        //.addr_p2    ( addr_dm >> 2      ),  // Port-2 addr
        //.we_p2      ( we_dm             ),  // Port-2 write enable
        //.wd_p2      ( wd_dm             ),  // Port-2 write data
        //.rd_p2      ( rd_dm             )   // Port-2 read data
    );

endmodule : nf_top
