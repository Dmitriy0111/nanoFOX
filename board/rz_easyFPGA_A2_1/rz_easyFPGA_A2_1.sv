module rz_easyFPGA_A2_1
(
    input   logic   [0 : 0]     clk50mhz,
    input   logic   [0 : 0]     rst_key,
    input   logic   [3 : 0]     key,
    output  logic   [3 : 0]     led,
    output  logic   [7 : 0]     hex0,
    output  logic   [3 : 0]     dig,
    output  logic   [0 : 0]     R,
    output  logic   [0 : 0]     G,
    output  logic   [0 : 0]     B,
    output  logic   [0 : 0]     hsync,
    output  logic   [0 : 0]     vsync
);

    localparam          debug_type  = "hex";
    localparam          cpu         = "nanoFOX";
    localparam          sub_path    = "../../brd_rtl/DebugScreenCore/";

    // wires & inputs
    // clock and reset
    logic   [0  : 0]    clk;        // clock
    logic   [0  : 0]    resetn;     // reset
    logic   [25 : 0]    div;        // clock divide input
    // for debug
    logic   [4  : 0]    reg_addr;   // scan register address
    logic   [31 : 0]    reg_data;   // scan register data
    // hex
    logic   [7  : 0]    hex;        // hex values from convertors
    // for debug ScreenCore
    logic   [0  : 0]    en;         // enable logic for vga DebugScreenCore
    
    assign hex0     = hex;
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign div      = 26'h00_ff_ff_ff;

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
            assign reg_addr = key[0 +: 4];
            assign R        = '0;
            assign G        = '0;
            assign B        = '0;
            assign hsync    = '0;
            assign vsync    = '0;
            // creating one nf_seven_seg_dynamic_0 unit
            nf_seven_seg_dynamic 
            nf_seven_seg_dynamic_0
            (
                .clk        ( clk       ),  // clock
                .resetn     ( resetn    ),  // reset
                .hex        ( reg_data  ),  // hexadecimal value input
                .cc_ca      ( '0        ),  // common cathode or common anode
                .seven_seg  ( hex       ),  // seven segments output
                .dig        ( dig       )   // digital tube selector
            );
        end

        if( debug_type == "vga" )
        begin
            assign hex = '0;
            assign dig = '0;
            // creating one enable flip-flop
            nf_register #( 1 ) en_ff    ( clk, resetn, !en , en );
            // creating one debug_screen_core
            vga_ds_top
            #(
                .cpu        ( cpu       ),  // cpu type
                .sub_path   ( sub_path  )   // sub path for DebugScreenCore memorys
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

endmodule : rz_easyFPGA_A2_1
