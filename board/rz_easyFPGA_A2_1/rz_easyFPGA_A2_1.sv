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
    logic   [4  : 0]    reg_addr;
    logic   [31 : 0]    reg_data;
    logic   [7  : 0]    hex;
    
    assign hex0     = hex;
    assign clk      = clk50mhz;
    assign resetn   = rst_key;
    assign reg_addr = key[0 +: 4];
    assign div      = 26'h00_ff_ff_ff;

    nf_top nf_top_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .reg_addr   ( reg_addr  ),
        .reg_data   ( reg_data  )
    );

    nf_seven_seg_dynamic nf_seven_seg_dynamic_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .hex        ( reg_data  ),
        .cc_ca      ( '0        ),
        .seven_seg  ( hex       ),
        .dig        ( dig       )
    );

endmodule : rz_easyFPGA_A2_1
