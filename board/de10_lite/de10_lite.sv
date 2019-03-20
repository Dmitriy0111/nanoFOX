module de10_lite
(
    // max10 clock input's
    input               adc_clk_10,
    input               max10_clk1_50,
    input               max10_clk2_50,
    // seven segment's
    output  [7  : 0]    hex0,
    output  [7  : 0]    hex1,
    output  [7  : 0]    hex2,
    output  [7  : 0]    hex3,
    output  [7  : 0]    hex4,
    output  [7  : 0]    hex5,
    // button's
    input   [1  : 0]    key,
    // led's
    output  [9  : 0]    ledr,
    // switches
    input   [9  : 0]    sw,
    // gpio
    inout   [35 : 0]    gpio
);

    // wires & inputs
    // clock and reset
    logic               clk;        // clock
    logic               resetn;     // reset
    logic   [25 : 0]    div;        // clock divide input
    // pwm side
    logic               pwm;        // PWM output
    // gpio side
    logic   [7 : 0]     gpi;        // GPIO input
    logic   [7 : 0]     gpo;        // GPIO output
    logic   [7 : 0]     gpd;        // GPIO direction
    // for debug
    logic   [4  : 0]    reg_addr;   // scan register address
    logic   [31 : 0]    reg_data;   // scan register data
    // hex
    logic   [6*8-1 : 0] hex;

    assign ledr[0 +: 8] = gpo;
    assign ledr[8]      = pwm;
    
    assign { hex5 , hex4 , hex3 , hex2 , hex1 , hex0 } = hex;
    assign clk      = max10_clk1_50;
    assign resetn   = key[0];
    assign reg_addr = sw[0 +: 5];
    assign div      = { sw[5 +: 5] , { 20 { 1'b1 } } };
    // creating one nf_top_0 unit
    nf_top nf_top_0
    (
        // clock and reset
        .clk        ( clk       ),  // clock
        .resetn     ( resetn    ),  // reset
        .div        ( div       ),  // clock divide input
        // pwm side
        .reg_addr   ( reg_addr  ),  // PWM output
        // gpio side
        .reg_data   ( reg_data  ),  // GPIO input
        .pwm        ( pwm       ),  // GPIO output
        .gpi        ( gpi       ),  // GPIO direction
        // for debug
        .gpo        ( gpo       ),  // scan register address
        .gpd        ( gpd       )   // scan register data
    );
    // creating one nf_seven_seg_static_0 unit
    nf_seven_seg_static 
    #(
        .hn         ( 6         )
    )
    nf_seven_seg_static_0
    (
        .hex        ( reg_data  ),  // hexadecimal value input
        .cc_ca      ( '0        ),  // common cathode or common anode
        .seven_seg  ( hex       )   // seven segments output
    );

endmodule : de10_lite
