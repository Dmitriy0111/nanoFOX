/*
*  File            :   nf_ahb_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.30
*  Language        :   SystemVerilog
*  Description     :   This is testbench for AHB
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"
`include "../tb/nf_tb.svh"

module nf_ahb_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 200;

    localparam          gpio_w  = `NF_GPIO_WIDTH,
                        slave_c = `SLAVE_COUNT;

    `define NF_GPIO_A_ADDR_MATCH    32'h0000XXXX
    `define NF_GPIO_B_ADDR_MATCH    32'h0001XXXX
    `define NF_PWM_ADDR_MATCH       32'h0002XXXX

    localparam  logic   [slave_c-1 : 0][31 : 0] ahb_vector = 
                                                            {
                                                                `NF_PWM_ADDR_MATCH,
                                                                `NF_GPIO_B_ADDR_MATCH,
                                                                `NF_GPIO_A_ADDR_MATCH
                                                            };
    
    bit     [0  : 0]    clk;            // clock
    bit     [0  : 0]    resetn;         // reset

    bit     [31 : 0]    addr_dm;        // address data memory
    logic   [31 : 0]    rd_dm;          // read data memory
    bit     [31 : 0]    wd_dm;          // write data memory
    bit     [0  : 0]    we_dm;          // write enable signal
    bit     [0  : 0]    req_dm;         // request data memory signal
    logic   [0  : 0]    req_ack_dm;     // request acknowledge data memory signal

    bit     [0  : 0]    pwm_clk;        // PWM clock input
    bit     [0  : 0]    pwm_resetn;     // PWM reset input
    logic   [0  : 0]    pwm;            // PWM output signal

    logic   [gpio_w-1 : 0]   gpi_a;     // GPIO input
    logic   [gpio_w-1 : 0]   gpo_a;     // GPIO output
    logic   [gpio_w-1 : 0]   gpd_a;     // GPIO direction

    logic   [gpio_w-1 : 0]   gpi_b;     // GPIO input
    logic   [gpio_w-1 : 0]   gpo_b;     // GPIO output
    logic   [gpio_w-1 : 0]   gpd_b;     // GPIO direction

    logic   [slave_c-1 : 0][31 : 0]     haddr_s;    // AHB - Slave HADDR 
    logic   [slave_c-1 : 0][31 : 0]     hwdata_s;   // AHB - Slave HWDATA 
    logic   [slave_c-1 : 0][31 : 0]     hrdata_s;   // AHB - Slave HRDATA 
    logic   [slave_c-1 : 0][0  : 0]     hwrite_s;   // AHB - Slave HWRITE 
    logic   [slave_c-1 : 0][1  : 0]     htrans_s;   // AHB - Slave HTRANS 
    logic   [slave_c-1 : 0][2  : 0]     hsize_s;    // AHB - Slave HSIZE 
    logic   [slave_c-1 : 0][2  : 0]     hburst_s;   // AHB - Slave HBURST 
    logic   [slave_c-1 : 0][1  : 0]     hresp_s;    // AHB - Slave HRESP 
    logic   [slave_c-1 : 0][0  : 0]     hready_s;   // AHB - Slave HREADYOUT 
    logic   [slave_c-1 : 0]             hsel_s;     // AHB - Slave HSEL

    assign gpi_a = gpo_a ^ gpd_a;
    assign gpi_b = gpo_b ^ gpd_b;

    assign pwm_clk = clk;
    assign pwm_resetn = resetn;

    task data_read( bit [31 : 0] addr );
        req_dm  = '1;
        addr_dm = addr;
        @(posedge clk);
        req_dm  = '0;
        @(posedge req_ack_dm);
        @(posedge clk);
    endtask : data_read

    task data_write( bit [31 : 0] addr , bit [31 : 0] data );
        req_dm  = '1;
        we_dm   = '1;
        addr_dm = addr;
        wd_dm   = data;
        @(posedge clk);
        we_dm   = '0;
        req_dm  = '0;
        @(posedge req_ack_dm);
        @(posedge clk);
    endtask : data_write

    task wait_clk( int number );
         repeat( number ) @(posedge clk);
    endtask : wait_clk

    // generating clock
    initial
    begin
    for( int i = 0 ; i < 3 ; i++ )
        $display("AHB slave[%d] = %h",i,ahb_vector[i]);
        $display("Clock generation start");
        forever #( T / 2 ) clk = ~clk;
    end
    // generation reset
    initial
    begin
        $display("Reset is in active state");
        wait_clk    ( resetn_delay );
        resetn  = '1;
        $display("Reset is in inactive state");
    end
    initial
    begin
        addr_dm = `NF_GPIO_A_ADDR_MATCH | `NF_GPIO_GPO;       
        wd_dm   = 8'h5a;     
        we_dm   = '0;
        req_dm  = '0;
        @(posedge resetn);
        wait_clk    ( 1 );
        data_write  ( `NF_PWM_ADDR_MATCH    | '0          , 32'd244 );
        data_read   ( `NF_PWM_ADDR_MATCH    | '0           );
        data_write  ( `NF_PWM_ADDR_MATCH    | '0          , 32'd10  );
        wait_clk    ( 3 );
        data_write  ( `NF_GPIO_A_ADDR_MATCH | `NF_GPIO_GPO, 32'h5a );
        data_write  ( `NF_GPIO_A_ADDR_MATCH | `NF_GPIO_DIR, 32'ha5 );
        data_read   ( `NF_GPIO_A_ADDR_MATCH | `NF_GPIO_DIR );
        data_read   ( `NF_GPIO_A_ADDR_MATCH | `NF_GPIO_GPO );
        data_read   ( `NF_GPIO_A_ADDR_MATCH | `NF_GPIO_GPI );
        wait_clk    ( 5 );
        addr_dm = '0;
        wait_clk    ( 5 );
        data_read   ( `NF_GPIO_A_ADDR_MATCH | `NF_GPIO_GPO );
        wait_clk    ( 20 );
        $stop;
    end

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
        .addr_dm        ( addr_dm       ),      // address data memory
        .rd_dm          ( rd_dm         ),      // read data memory
        .wd_dm          ( wd_dm         ),      // write data memory
        .we_dm          ( we_dm         ),      // write enable signal
        .req_dm         ( req_dm        ),      // request data memory signal
        .req_ack_dm     ( req_ack_dm    )       // request acknowledge data memory signal
    );

    nf_ahb_gpio 
    #(
        .gpio_w         ( gpio_w        ) 
    )
    nf_ahb_gpio_a
    (
        // clock and reset
        .hclk           ( clk           ),      // hclk
        .hresetn        ( resetn        ),      // hresetn
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
        .hsel_s         ( hsel_s    [0] ),      // AHB - Slave HSEL
        //gpio_side
        .gpi            ( gpi_a         ),      // GPIO input
        .gpo            ( gpo_a         ),      // GPIO output
        .gpd            ( gpd_a         )       // GPIO direction
    );

    nf_ahb_gpio 
    #(
        .gpio_w         ( gpio_w        ) 
    )
    nf_ahb_gpio_b
    (
        // clock and reset
        .hclk           ( clk           ),      // hclk
        .hresetn        ( resetn        ),      // hresetn
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
        .hsel_s         ( hsel_s    [1] ),      // AHB - Slave HSEL
        //gpio_side
        .gpi            ( gpi_b         ),      // GPIO input
        .gpo            ( gpo_b         ),      // GPIO output
        .gpd            ( gpd_b         )       // GPIO direction
    );

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
        .haddr_s        ( haddr_s   [2] ),      // AHB - Slave HADDR
        .hwdata_s       ( hwdata_s  [2] ),      // AHB - Slave HWDATA
        .hrdata_s       ( hrdata_s  [2] ),      // AHB - Slave HRDATA
        .hwrite_s       ( hwrite_s  [2] ),      // AHB - Slave HWRITE
        .htrans_s       ( htrans_s  [2] ),      // AHB - Slave HTRANS
        .hsize_s        ( hsize_s   [2] ),      // AHB - Slave HSIZE
        .hburst_s       ( hburst_s  [2] ),      // AHB - Slave HBURST
        .hresp_s        ( hresp_s   [2] ),      // AHB - Slave HRESP
        .hready_s       ( hready_s  [2] ),      // AHB - Slave HREADYOUT
        .hsel_s         ( hsel_s    [2] ),      // AHB - Slave HSEL
        // pmw_side
        .pwm_clk        ( pwm_clk       ),      // PWM clock input
        .pwm_resetn     ( pwm_resetn    ),      // PWM reset input
        .pwm            ( pwm           )       // PWM output signal
    );

endmodule : nf_ahb_tb
