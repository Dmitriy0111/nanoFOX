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
    // vga
    output  [0  : 0]    hsync,
    output  [0  : 0]    vsync,
    output  [2  : 0]    R,
    output  [2  : 0]    G,
    output  [2  : 0]    B,
    // button's
    input   [1  : 0]    key,
    // led's
    output  [9  : 0]    ledr,
    // switches
    input   [9  : 0]    sw,
    // gpio
    inout   [35 : 0]    gpio
);

    localparam              debug_type  = "hex";
    localparam              cpu         = "nanoFOX";
    localparam              sub_path    = "../../brd_rtl/DebugScreenCore/";

    // wires & inputs
    // clock and reset
    logic   [0     : 0]     clk;        // clock
    logic   [0     : 0]     resetn;     // reset
    logic   [25    : 0]     div;        // clock divide input
    // for debug
    logic   [4     : 0]     reg_addr;   // scan register address
    logic   [31    : 0]     reg_data;   // scan register data
    // hex
    logic   [6*8-1 : 0]     hex;        // hex values from convertors
    // for debug ScreenCore
    logic   [0     : 0]     en;         // enable logic for vga DebugScreenCore
    
    assign { hex5 , hex4 , hex3 , hex2 , hex1 , hex0 } = hex;
    assign clk      = max10_clk1_50;
    assign resetn   = key[0];
    assign div      = { sw[5 +: 5] , { 20 { 1'b1 } } };

    // creating one nf_top_0 unit
    nf_top 
    nf_top_0
    (
        // clock and reset
        .clk        ( clk       ),  // clock
        .resetn     ( resetn    ),  // reset
        .div        ( div       ),  // clock divide input
        // for debug
        .reg_addr   ( reg_addr  ),  // scan register address
        .reg_data   ( reg_data  )   // scan register data
    );
    // generate block
    generate

        if( debug_type == "hex" )
        begin
            assign reg_addr = sw[0 +: 5];
            assign R        = '0;
            assign G        = '0;
            assign B        = '0;
            assign hsync    = '0;
            assign vsync    = '0;
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
        end

        if( debug_type == "vga" )
        begin
            assign hex = '0;
            // creating one enable flip-flop
            nf_register #( 1 ) en_ff    ( clk, resetn, !en , en );
            // creating one debug_screen_core
            vga_ds_top
            #(
                .cpu        ( cpu       ),
                .sub_path   ( sub_path  )
            )
            vga_ds_top_0
            (
                .clk        ( clk       ),  // clock
                .resetn     ( resetn    ),  // reset
                .en         ( en        ),  // enable input
                .hsync      ( hsync     ),  // hsync output
                .vsync      ( vsync     ),  // vsync output
                .bgColor    ( 12'h00f   ),  // Background color
                .fgColor    ( 12'hf00   ),  // Foreground color
                .regData    ( reg_data  ),  // Register data input from cpu
                .regAddr    ( reg_addr  ),  // Register data output to cpu
                .R          ( R         ),  // R-color
                .G          ( G         ),  // G-color
                .B          ( B         )   // B-color
            );
        end

    endgenerate

endmodule : de10_lite
