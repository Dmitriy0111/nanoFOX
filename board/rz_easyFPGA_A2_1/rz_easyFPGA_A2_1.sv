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

    localparam          debug_type  = "vga";
    localparam          cpu         = "nanoFOX";

    // wires & inputs
    // clock and reset
    logic               clk;        // clock
    logic               resetn;     // reset
    logic   [25 : 0]    div;        // clock divide input
    // for debug
    logic   [4  : 0]    reg_addr;   // scan register address
    logic   [31 : 0]    reg_data;   // scan register data
    // hex
    logic   [7  : 0]    hex;
    // for debug ScreenCore
    logic   [0  : 0]    en;
    
    assign hex0     = hex;
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign div      = 26'h00_ff_ff_ff;

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            en <= '0;
        else
            en <= ~ en;

    // creating one nf_top_0 unit
    nf_top nf_top_0
    (
        // clock and reset
        .clk        ( clk       ),  // clock
        .resetn     ( resetn    ),  // reset
        .div        ( div       ),  // clock divide input
        // for debug
        .reg_addr   ( reg_addr  ),  // scan register address
        .reg_data   ( reg_data  )   // scan register data
    );

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
            nf_seven_seg_dynamic nf_seven_seg_dynamic_0
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
            // creating one debug_screen_core
            vga_ds_top
            #(
                .cpu        ( cpu       )
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
