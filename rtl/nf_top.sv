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
    // clock and reset
    input   logic   [0  : 0]    clk,        // clock input
    input   logic   [0  : 0]    resetn,     // reset input
    // GPIO side
    input   logic   [7  : 0]    gpio_i_0,   // GPIO_0 input
    output  logic   [7  : 0]    gpio_o_0,   // GPIO_0 output
    output  logic   [7  : 0]    gpio_d_0,   // GPIO_0 direction
    // PWM side
    output  logic   [0  : 0]    pwm,        // PWM output signal
    // UART side
    output  logic   [0  : 0]    uart_tx,    // UART tx wire
    input   logic   [0  : 0]    uart_rx     // UART rx wire
);

    localparam          gpio_w  = `NF_GPIO_WIDTH,
                        slave_c = `SLAVE_COUNT;

    // instruction memory (IF)
    logic   [31 : 0]    addr_i;                 // address instruction memory
    logic   [31 : 0]    rd_i;                   // read instruction memory
    logic   [31 : 0]    wd_i;                   // write instruction memory
    logic   [0  : 0]    we_i;                   // write enable instruction memory signal
    logic   [0  : 0]    req_i;                  // request instruction memory signal
    logic   [0  : 0]    req_ack_i;              // request acknowledge instruction memory signal
    // data memory and other's
    logic   [31 : 0]    addr_dm;                // address data memory
    logic   [31 : 0]    rd_dm;                  // read data memory
    logic   [31 : 0]    wd_dm;                  // write data memory
    logic   [0  : 0]    we_dm;                  // write enable data memory signal
    logic   [0  : 0]    req_dm;                 // request data memory signal
    logic   [0  : 0]    req_ack_dm;             // request acknowledge data memory signal
    // cross connect data
    logic   [31 : 0]    addr_cc;                // address cc_data memory
    logic   [31 : 0]    rd_cc;                  // read cc_data memory
    logic   [31 : 0]    wd_cc;                  // write cc_data memory
    logic   [0  : 0]    we_cc;                  // write enable cc_data memory signal
    logic   [0  : 0]    req_cc;                 // request cc_data memory signal
    logic   [0  : 0]    req_ack_cc;             // request acknowledge cc_data memory signal
    // PWM 
    logic               pwm_clk;                // PWM clock input
    logic               pwm_resetn;             // PWM reset input   
    // GPIO port 0
    logic   [gpio_w-1 : 0]   gpi_0;             // GPIO input
    logic   [gpio_w-1 : 0]   gpo_0;             // GPIO output
    logic   [gpio_w-1 : 0]   gpd_0;             // GPIO direction
    // RAM side
    logic   [31 : 0]    ram_addr;               // addr memory
    logic   [0  : 0]    ram_we;                 // write enable
    logic   [31 : 0]    ram_wd;                 // write data
    logic   [31 : 0]    ram_rd;                 // read data

    assign  pwm_clk    = clk;
    assign  pwm_resetn = resetn;    
    assign  gpi_0      = gpio_i_0;
    assign  gpio_o_0   = gpo_0;
    assign  gpio_d_0   = gpd_0;
 
    // Creating one nf_cpu_0
    nf_cpu nf_cpu_0
    (
        // clock and reset
        .clk            ( clk           ),      // clk  
        .resetn         ( resetn        ),      // resetn
        // instruction memory (IF)
        .addr_i         ( addr_i        ),      // address instruction memory
        .rd_i           ( rd_i          ),      // read instruction memory
        .wd_i           ( wd_i          ),      // write instruction memory
        .we_i           ( we_i          ),      // write enable instruction memory signal
        .req_i          ( req_i         ),      // request instruction memory signal
        .req_ack_i      ( req_ack_i     ),      // request acknowledge instruction memory signal
        // data memory and other's
        .addr_dm        ( addr_dm       ),      // address data memory
        .rd_dm          ( rd_dm         ),      // read data memory
        .wd_dm          ( wd_dm         ),      // write data memory
        .we_dm          ( we_dm         ),      // write enable data memory signal
        .req_dm         ( req_dm        ),      // request data memory signal
        .req_ack_dm     ( req_ack_dm    )       // request acknowledge data memory signal
    );

    // Creating one nf_cpu_cc_0
    nf_cpu_cc nf_cpu_cc_0
    (
        // clock and reset
        .clk            ( clk           ),      // clk
        .resetn         ( resetn        ),      // resetn
        // instruction memory (IF)
        .addr_i         ( addr_i        ),      // address instruction memory
        .rd_i           ( rd_i          ),      // read instruction memory
        .wd_i           ( wd_i          ),      // write instruction memory
        .we_i           ( we_i          ),      // write enable instruction memory signal
        .req_i          ( req_i         ),      // request instruction memory signal
        .req_ack_i      ( req_ack_i     ),      // request acknowledge instruction memory signal
        // data memory and other's
        .addr_dm        ( addr_dm       ),      // address data memory
        .rd_dm          ( rd_dm         ),      // read data memory
        .wd_dm          ( wd_dm         ),      // write data memory
        .we_dm          ( we_dm         ),      // write enable data memory signal
        .req_dm         ( req_dm        ),      // request data memory signal
        .req_ack_dm     ( req_ack_dm    ),      // request acknowledge data memory signal
        // cross connect data
        .addr_cc        ( addr_cc       ),      // address cc_data memory
        .rd_cc          ( rd_cc         ),      // read cc_data memory
        .wd_cc          ( wd_cc         ),      // write cc_data memory
        .we_cc          ( we_cc         ),      // write enable cc_data memory signal
        .req_cc         ( req_cc        ),      // request cc_data memory signal
        .req_ack_cc     ( req_ack_cc    )       // request acknowledge cc_data memory signal
    );

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
        .slave_c        ( slave_c       )
    )
    nf_ahb_top_0
    (
        // clock and reset
        .clk            ( clk           ),      // clk
        .resetn         ( resetn        ),      // resetn
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
        .addr           ( addr_cc       ),      // address memory
        .rd             ( rd_cc         ),      // read memory
        .wd             ( wd_cc         ),      // write memory
        .we             ( we_cc         ),      // write enable signal
        .req            ( req_cc        ),      // request memory signal
        .req_ack        ( req_ack_cc    )       // request acknowledge memory signal
    );

    // Creating one nf_ahb_ram_0
    nf_ahb_ram nf_ahb_ram_0
    (
        // clock and reset
        .hclk           ( clk           ),      // hclk
        .hresetn        ( resetn        ),      // hresetn
        // AHB RAM slave side
        .haddr_s        ( haddr_s   [0] ),      // AHB - RAM-slave HADDR
        .hwdata_s       ( hwdata_s  [0] ),      // AHB - RAM-slave HWDATA
        .hrdata_s       ( hrdata_s  [0] ),      // AHB - RAM-slave HRDATA
        .hwrite_s       ( hwrite_s  [0] ),      // AHB - RAM-slave HWRITE
        .htrans_s       ( htrans_s  [0] ),      // AHB - RAM-slave HTRANS
        .hsize_s        ( hsize_s   [0] ),      // AHB - RAM-slave HSIZE
        .hburst_s       ( hburst_s  [0] ),      // AHB - RAM-slave HBURST
        .hresp_s        ( hresp_s   [0] ),      // AHB - RAM-slave HRESP
        .hready_s       ( hready_s  [0] ),      // AHB - RAM-slave HREADYOUT
        .hsel_s         ( hsel_s    [0] ),      // AHB - RAM-slave HSEL
        // RAM side
        .ram_addr       ( ram_addr      ),      // addr memory
        .ram_we         ( ram_we        ),      // write enable
        .ram_wd         ( ram_wd        ),      // write data
        .ram_rd         ( ram_rd        )       // read data
    );

    // Creating one nf_ahb_gpio_0
    nf_ahb_gpio 
    #(
        .gpio_w         ( gpio_w        ) 
    )
    nf_ahb_gpio_b
    (
        // clock and reset
        .hclk           ( clk           ),      // hclock
        .hresetn        ( resetn        ),      // hresetn
        // Slaves side
        .haddr_s        ( haddr_s   [1] ),      // AHB - GPIO-slave HADDR
        .hwdata_s       ( hwdata_s  [1] ),      // AHB - GPIO-slave HWDATA
        .hrdata_s       ( hrdata_s  [1] ),      // AHB - GPIO-slave HRDATA
        .hwrite_s       ( hwrite_s  [1] ),      // AHB - GPIO-slave HWRITE
        .htrans_s       ( htrans_s  [1] ),      // AHB - GPIO-slave HTRANS
        .hsize_s        ( hsize_s   [1] ),      // AHB - GPIO-slave HSIZE
        .hburst_s       ( hburst_s  [1] ),      // AHB - GPIO-slave HBURST
        .hresp_s        ( hresp_s   [1] ),      // AHB - GPIO-slave HRESP
        .hready_s       ( hready_s  [1] ),      // AHB - GPIO-slave HREADYOUT
        .hsel_s         ( hsel_s    [1] ),      // AHB - GPIO-slave HSEL
        //gpio_side
        .gpi            ( gpi_0         ),      // GPIO input
        .gpo            ( gpo_0         ),      // GPIO output
        .gpd            ( gpd_0         )       // GPIO direction
    );

    // creating AHB PWM module
    nf_ahb_pwm
    #(
        .pwm_width      ( 8             )
    )
    nf_ahb_pwm_0
    (
        // clock and reset
        .hclk           ( clk           ),      // hclk
        .hresetn        ( resetn        ),      // hresetn
        // Slaves side
        .haddr_s        ( haddr_s   [2] ),      // AHB - PWM-slave HADDR
        .hwdata_s       ( hwdata_s  [2] ),      // AHB - PWM-slave HWDATA
        .hrdata_s       ( hrdata_s  [2] ),      // AHB - PWM-slave HRDATA
        .hwrite_s       ( hwrite_s  [2] ),      // AHB - PWM-slave HWRITE
        .htrans_s       ( htrans_s  [2] ),      // AHB - PWM-slave HTRANS
        .hsize_s        ( hsize_s   [2] ),      // AHB - PWM-slave HSIZE
        .hburst_s       ( hburst_s  [2] ),      // AHB - PWM-slave HBURST
        .hresp_s        ( hresp_s   [2] ),      // AHB - PWM-slave HRESP
        .hready_s       ( hready_s  [2] ),      // AHB - PWM-slave HREADYOUT
        .hsel_s         ( hsel_s    [2] ),      // AHB - PWM-slave HSEL
        // pmw_side
        .pwm_clk        ( pwm_clk       ),      // PWM_clk
        .pwm_resetn     ( pwm_resetn    ),      // PWM_resetn
        .pwm            ( pwm           )       // PWM output signal
    );

    // Creating one nf_ahb_gpio_0
    nf_ahb_uart 
    nf_ahb_uart_0
    (
        // clock and reset
        .hclk           ( clk           ),      // hclock
        .hresetn        ( resetn        ),      // hresetn
        // Slaves side
        .haddr_s        ( haddr_s   [3] ),      // AHB - UART-slave HADDR
        .hwdata_s       ( hwdata_s  [3] ),      // AHB - UART-slave HWDATA
        .hrdata_s       ( hrdata_s  [3] ),      // AHB - UART-slave HRDATA
        .hwrite_s       ( hwrite_s  [3] ),      // AHB - UART-slave HWRITE
        .htrans_s       ( htrans_s  [3] ),      // AHB - UART-slave HTRANS
        .hsize_s        ( hsize_s   [3] ),      // AHB - UART-slave HSIZE
        .hburst_s       ( hburst_s  [3] ),      // AHB - UART-slave HBURST
        .hresp_s        ( hresp_s   [3] ),      // AHB - UART-slave HRESP
        .hready_s       ( hready_s  [3] ),      // AHB - UART-slave HREADYOUT
        .hsel_s         ( hsel_s    [3] ),      // AHB - UART-slave HSEL
        // UART side
        .uart_tx        ( uart_tx       ),      // UART tx wire
        .uart_rx        ( uart_rx       )       // UART rx wire
    );
    
    //creating one instruction/data memory
    nf_ram
    #(
        .depth          ( 256           ),
        .load           ( 1             ),
        .path2file      ( `path2file    )
    )
    nf_ram_i_d_0
    (
        .clk            ( clk           ),
        .addr           ( ram_addr >> 2 ),      // addr memory (world addressable)
        .we             ( ram_we        ),      // write enable
        .wd             ( ram_wd        ),      // write data
        .rd             ( ram_rd        )       // read data
    );

endmodule : nf_top
