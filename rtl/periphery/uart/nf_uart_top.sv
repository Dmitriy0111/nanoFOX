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
    // reset and clock
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    resetn,     // resetn
    // bus side
    input   logic   [31 : 0]    addr,       // address
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // uart side
    output  logic   [0  : 0]    uart_tx,    // UART tx wire
    input   logic   [0  : 0]    uart_rx     // UART rx wire
);

    logic   [7  : 0]    control_reg;
    logic   [7  : 0]    ctrl_cdc_out;
    logic   [7  : 0]    ctrl_cdc_in;
    logic   [7  : 0]    tx_data;
    logic   [15 : 0]    comp;
    logic   [7  : 0]    rx_data;
    logic   [0  : 0]    tr_en;
    logic   [0  : 0]    rec_en;
    logic   [0  : 0]    rx_valid;
    // write enable signals 
    logic   [0  : 0]    uart_cr_we;     // UART control register write enable
    logic   [0  : 0]    uart_tx_we;     // UART transmitter register write enable
    logic   [0  : 0]    uart_dv_we;     // UART divider register write enable
    // uart transmitter
    logic   [0  : 0]    req;            // request transmit
    logic   [0  : 0]    req_ack;        // request acknowledge transmit
    
    // assign write enable signals
    assign uart_cr_we = we && ( addr[0 +: 4] == `NF_UART_CR );
    assign uart_tx_we = we && ( addr[0 +: 4] == `NF_UART_TX );
    assign uart_dv_we = we && ( addr[0 +: 4] == `NF_UART_DR );

    assign req    = ctrl_cdc_out[0];
    assign tr_en  = ctrl_cdc_out[2];
    assign rec_en = ctrl_cdc_out[3];
    assign ctrl_cdc_in[0] = !req_ack;
    assign ctrl_cdc_in[1] = !rx_valid;
    assign ctrl_cdc_in[2 +: 7] = ctrl_cdc_out[2 +: 7];

    // mux for routing one register value
    always_comb
    begin
        rd = '0 | control_reg;
        casex( addr[0 +: 4] )
            `NF_UART_CR :   rd = '0 | control_reg ;
            `NF_UART_TX :   rd = '0 | tx_data     ;
            `NF_UART_RX :   rd = '0 | rx_data     ;
            `NF_UART_DR :   rd = '0 | comp        ;
            default     : ;
        endcase
    end

    nf_register_we #( 8  ) nf_uart_tx_reg    ( clk, resetn, uart_tx_we, wd, tx_data          );
    nf_register_we #( 16 ) nf_uart_dv_reg    ( clk, resetn, uart_dv_we, wd, comp             );
    // creating one cross domain crossing unit
    nf_cdc 
    #(
        .width      ( 8             )
    )
    nf_cdc_0
    (  
        .resetn_1   ( resetn        ),
        .resetn_2   ( resetn        ),
        .clk_1      ( clk           ),
        .clk_2      ( clk           ),
        .we_1       ( uart_cr_we    ),
        .we_2       ( req_ack       ),
        .data_1_in  ( wd            ),
        .data_2_in  ( ctrl_cdc_in   ),
        .data_1_out ( control_reg   ),
        .data_2_out ( ctrl_cdc_out  ),
        .wait_1     (               ),
        .wait_2     (               )
    );
    // creating one uart transmitter 
    nf_uart_transmitter nf_uart_transmitter_0
    (
        // reset and clock
        .clk        ( clk           ),     // clk
        .resetn     ( resetn        ),     // resetn
        // controller side interface
        .tr_en      ( tr_en         ),     // transmitter enable
        .comp       ( comp          ),     // compare input for setting baudrate
        .tx_data    ( tx_data       ),     // data for transfer
        .req        ( req           ),     // request signal
        .req_ack    ( req_ack       ),     // acknowledgent signal
        // uart tx side
        .uart_tx    ( uart_tx       )      // UART tx wire
    );
    // creating one uart receiver 
    nf_uart_receiver nf_uart_receiver_0
    (
        // reset and clock
        .clk        ( clk           ),      // clk
        .resetn     ( resetn        ),      // resetn
        // controller side interface
        .comp       ( comp          ),      // receiver enable
        .rec_en     ( rec_en        ),      // compare input for setting baudrate
        .rx_data    ( rx_data       ),      // received data
        .rx_valid   ( rx_valid      ),      // receiver data valid
        // uart rx side
        .uart_rx    ( uart_rx       )       // UART rx wire
    );

endmodule : nf_uart_top
