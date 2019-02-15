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

    logic               clk;
    logic               resetn;
    logic   [7  : 0]    gpio_i_0;   // GPIO_0 input
    logic   [7  : 0]    gpio_o_0;   // GPIO_0 output
    logic   [7  : 0]    gpio_d_0;   // GPIO_0 direction
    logic               pwm;        // PWM output signal
    logic   [31 : 0]    gpio2hex;
    logic   [7  : 0]    hex;
    
    assign hex0     = hex;
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign gpio2hex = {'0,gpio_o_0};

    nf_top nf_top_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .gpio_i_0   ( gpio_i_0  ),
        .gpio_o_0   ( gpio_o_0  ),
        .gpio_d_0   ( gpio_d_0  ),
        .pwm        ( pwm       ) 
    );

    nf_seven_seg_dynamic nf_seven_seg_dynamic_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .hex        ( gpio2hex  ),
        .cc_ca      ( '0        ),
        .seven_seg  ( hex       ),
        .dig        ( dig       )
    );

endmodule : rz_easyFPGA_A2_1
