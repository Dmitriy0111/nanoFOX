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
    logic   [0  : 0]    clk;        // clock
    logic   [0  : 0]    resetn;     // reset
    // GPIO
    logic   [7  : 0]    gpio_i_0;   // GPIO_0 input
    logic   [7  : 0]    gpio_o_0;   // GPIO_0 output
    logic   [7  : 0]    gpio_d_0;   // GPIO_0 direction
    // PWM
    logic   [0  : 0]    pwm;        // PWM output signal
    // UART side
    logic   [0  : 0]    uart_tx;    // UART tx wire
    logic   [0  : 0]    uart_rx;    // UART rx wire

    logic   [31 : 0]    gpio2hex;   // gpio to hex
    logic   [7  : 0]    hex;        // for hex display
    // assigns
    assign hex0     = hex;
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign gpio2hex = {'0,gpio_o_0};
    // creating one nf_top_0 unit
    nf_top nf_top_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .gpio_i_0   ( gpio_i_0  ),
        .gpio_o_0   ( gpio_o_0  ),
        .gpio_d_0   ( gpio_d_0  ),
        .pwm        ( pwm       ),
        .uart_tx    ( uart_tx   ),
        .uart_rx    ( uart_rx   )
    );
    // creating one nf_seven_seg_dynamic_0 unit
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
