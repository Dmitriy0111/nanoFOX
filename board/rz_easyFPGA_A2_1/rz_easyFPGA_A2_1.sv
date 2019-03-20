module rz_easyFPGA_A2_1
(
    input               clk50mhz,
    input               rst_key,
	input   [3 : 0]     key,
    output  [3 : 0]     led,
    output  [7 : 0]     hex0,
    output  [3 : 0]     dig
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
    logic   [7  : 0]    hex;
    
    assign hex0     = hex;
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign reg_addr = key[0 +: 4];
    assign div      = 26'h00_ff_ff_ff;
    // creating one nf_top_0 unit
    nf_top nf_top_0
    (
        .clk        ( clk       ),  // clock
        .resetn     ( resetn    ),  // reset
        .div        ( div       ),  // clock divide input
        .reg_addr   ( reg_addr  ),  // PWM output
        .reg_data   ( reg_data  ),  // GPIO input
        .pwm        ( pwm       ),  // GPIO output
        .gpi        ( gpi       ),  // GPIO direction
        .gpo        ( gpo       ),  // scan register address
        .gpd        ( gpd       )   // scan register data
    );
    // creating one nf_seven_seg_dynamic_0 unit
    nf_seven_seg_dynamic nf_seven_seg_dynamic_0
    (
        .clk        ( clk       ),  // clock
        .resetn     ( resetn    ),  // reset
        .hex        ( reg_data  ),  // hexadecimal value input
        .cc_ca      ( '0        ),  // common cathode or common anode
        .seven_seg  ( hex       ),  // seven segments output
        .dig        ( dig       )   // digital tube selector
    );

endmodule : rz_easyFPGA_A2_1
