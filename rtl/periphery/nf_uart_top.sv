/*
*  File            :   nf_uart_top.sv
*  Autor           :   Vlasov D.V. 63030
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Description     :   This uart top module
*  Copyright(c)    :   2018 Vlasov D.V. 63030
*/

`include "../../inc/nf_settings.svh"

module nf_uart_top
(
    input   logic               clk,        // clk
    input   logic               resetn,     // resetn
    // bus side
    input   logic   [31 : 0]    addr,       // address
    input   logic               we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // uart side
    output  logic               uart_tx,    // UART tx wire
    input   logic               uart_rx
);

    logic   [7  : 0]    control_register;
    logic   [7  : 0]    tx_data;
    logic   [15 : 0]    comp;
    logic   [7  : 0]    rx_data;
    logic   [0  : 0]    tr_en;
    logic   [0  : 0]    rec_en;

    // write enable signals 
    logic  uart_cr_we;
    logic  uart_tx_we;
    logic  uart_dv_we;
    // assign write enable signals
    assign uart_cr_we = we && ( addr[0 +: 4] == `NF_UART_CR );
    assign uart_tx_we = we && ( addr[0 +: 4] == `NF_UART_TX );
    assign uart_dv_we = we && ( addr[0 +: 4] == `NF_UART_DR );
    
    nf_register_we #( 8  ) nf_uart_cr_reg    ( clk, resetn, uart_cr_we, wd, control_register );
    nf_register_we #( 8  ) nf_uart_tx_reg    ( clk, resetn, uart_tx_we, wd, tx_data          );
    nf_register_we #( 16 ) nf_uart_dv_reg    ( clk, resetn, uart_dv_we, wd, comp             );

    // mux for routing one register value
    always_comb
    begin
        rd = '0 | control_register;
        casex( addr[0 +: 4] )
            `NF_UART_CR :   rd = '0 | control_register ;
            `NF_UART_TX :   rd = '0 | tx_data          ;
            `NF_UART_RX :   rd = '0 | rx_data          ;
            `NF_UART_DR :   rd = '0 | comp             ;
            default     : ;
        endcase
    end

    logic   en;
    logic   req;
    logic   req_ack;

    assign  req    = control_register[0];
    assign  tr_en  = control_register[1];
    assign  rec_en = control_register[2];

    nf_strob_gen nf_strob_gen_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .comp       ( comp      ),
        .en         ( en        )
    );

    nf_uart_transmitter nf_uart_transmitter_0
    (
        .clk        ( clk       ),      // clk
        .resetn     ( resetn    ),      // resetn
        .en         ( en        ),      // strobing input
        .tr_en      ( tr_en     ),
        .tx_data    ( tx_data   ),      // data for transfer
        .req        ( req       ),      // request signal
        .req_ack    (           ),      // acknowledgent signal
        .uart_tx    ( uart_tx   )       // UART tx wire
    );

    nf_uart_receiver nf_uart_receiver_0
    (
        .clk        ( clk       ),
        .resetn     ( resetn    ),
        .comp       ( comp      ),
        .rec_en     ( rec_en    ),
        .rx_data    ( rx_data   ),
        .rx_valid   ( rx_valid  ),
        .uart_rx    ( uart_rx   )
    );

endmodule : nf_uart_top
