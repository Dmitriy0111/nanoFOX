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
    logic   [3  : 0]    dig;
    // for debug ScreenCore
    logic   [0  : 0]    en;         // enable logic for vga DebugScreenCore
    logic   [0  : 0]    r;
    
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign div      = { sw[1 +: 3] , 24'h_ff_ff_ff };

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
            assign hex0     = hex;
            assign b        = dig[0];
            assign g        = dig[1];
            assign hsync    = dig[2];
            assign vsync    = dig[3];
            assign reg_addr = { sw[0] , key[0 +: 4] };
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
            assign hex0[0]  = r;
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
                .R          ( r         ),  // R-color
                .G          ( g         ),  // G-color
                .B          ( b         )   // B-color
            );
        end

    endgenerate

endmodule : Storm_IV_E6_V2
