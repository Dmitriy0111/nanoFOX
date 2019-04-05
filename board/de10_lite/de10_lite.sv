module de10_lite
(
    //max10 clock input's
    input               adc_clk_10,
    input               max10_clk1_50,
    input               max10_clk2_50,
    //seven segment's
    output  [7  : 0]    hex0,
    output  [7  : 0]    hex1,
    output  [7  : 0]    hex2,
    output  [7  : 0]    hex3,
    output  [7  : 0]    hex4,
    output  [7  : 0]    hex5,
    //button's
    input   [1  : 0]    key,
    //led's
    output  [9  : 0]    ledr,
    //switches
    input   [9  : 0]    sw,
    //gpio
    inout   [35 : 0]    gpio
);

    // wires & inputs

    logic   [0     : 0]     clk;        // clock
    logic   [0     : 0]     resetn;     // reset
    logic   [6*8-1 : 0]     hex;        // for hex display
    // pwm side
    logic   [0     : 0]     pwm;        // pwm output
    // gpio side
    logic   [7     : 0]     gpio_i_0;   // gpio input
    logic   [7     : 0]     gpio_o_0;   // gpio output
    logic   [7     : 0]     gpio_d_0;   // gpio direction
    // UART side
    logic   [0     : 0]     uart_tx;    // UART tx wire
    logic   [0     : 0]     uart_rx;    // UART rx wire

    
    assign clk      = max10_clk1_50;
    assign resetn   = key[0];
    assign gpio_i_0 = sw[0 +: 5];
    assign ledr[8]  = pwm;
    assign ledr[0 +: 8] = gpio_o_0;
    assign { hex5 , hex4 , hex3 , hex2 , hex1 , hex0 } = hex;

    // creating one nf_top_0 unit
    nf_top nf_top_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .pwm        ( pwm       ),
        .gpio_i_0   ( gpio_i_0  ),
        .gpio_o_0   ( gpio_o_0  ),
        .gpio_d_0   ( gpio_d_0  ),
        .uart_tx    ( uart_tx   ),
        .uart_rx    ( uart_rx   )
    );
    // creating one nf_seven_seg_static_0 unit
    nf_seven_seg_static 
    #(
        .hn         ( 6         )
    )
    nf_seven_seg_static_0
    (
        .hex        ( 32'd2019  ),
        .cc_ca      ( '0        ),
        .seven_seg  ( hex       )
    );

endmodule : de10_lite
