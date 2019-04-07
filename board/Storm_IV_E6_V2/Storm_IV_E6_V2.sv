module Storm_IV_E6_V2
(
    input   logic   [0 : 0]     clk50mhz,
    input   logic   [0 : 0]     rst_key,
	input   logic   [3 : 0]     key,
    input   logic   [3 : 0]     sw,
    output  logic   [7 : 0]     led,
    output  logic   [7 : 0]     hex0,
    output  logic   [0 : 0]     g,
    output  logic   [0 : 0]     b,
    output  logic   [0 : 0]     hsync,
    output  logic   [0 : 0]     vsync
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
    logic   [3  : 0]    dig;
    // assigns
    assign hex0     = hex;
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign gpio2hex = {'0,gpio_o_0};
    assign gpio_i_0 = '0 | sw;
    assign b        = dig[0];
    assign g        = dig[1];
    assign hsync    = dig[2];
    assign vsync    = dig[3];
    assign led[0]   = pwm; 
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

endmodule : Storm_IV_E6_V2
