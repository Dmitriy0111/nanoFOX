/*
*  File            :   nf_uart_top.sv
*  Autor           :   Vlasov D.V. 63030
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Description     :   This uart top module
*  Copyright(c)    :   2018 Vlasov D.V. 63030
*/

`include "../../inc/nf_settings.svh"
`include "../../inc/nf_uart_regs.svh"

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

    UCR                 CRI;            // control register input
    UCR                 CRO;            // control register output
    UDVR                UDVR_0;         // "dividing frequency"
    UDR                 UDR_TX;         // transmitting data
    UDR                 UDR_RX;         // received data
    // write enable signals 
    logic   [0  : 0]    uart_cr_we;     // UART control register write enable
    logic   [0  : 0]    uart_tx_we;     // UART transmitter register write enable
    logic   [0  : 0]    uart_dv_we;     // UART divider register write enable
    // uart transmitter other signals
    logic   [0  : 0]    req;            // request transmit
    logic   [0  : 0]    req_ack;        // request acknowledge transmit
    // uart receiver other signals
    logic   [0  : 0]    rx_valid;       // rx byte received
    logic   [0  : 0]    rx_val_set;     // receiver data valid set
    
    // assign write enable signals
    assign uart_cr_we = we && ( addr[0 +: 4] == `NF_UART_CR );
    assign uart_tx_we = we && ( addr[0 +: 4] == `NF_UART_TX );
    assign uart_dv_we = we && ( addr[0 +: 4] == `NF_UART_DR );

    assign CRI.TX_REQ = wd[0];
    assign CRI.RX_VAL = wd[1];
    assign CRI.TX_EN  = wd[2];
    assign CRI.RX_EN  = wd[3];
    assign CRI.UN     = '0;
    assign CRO.UN     = '0;

    // mux for routing one register value
    always_comb
    begin
        rd = '0 | CRO;
        casex( addr[0 +: 4] )
            `NF_UART_CR :   rd = '0 | CRO    ;
            `NF_UART_TX :   rd = '0 | UDR_TX ;
            `NF_UART_RX :   rd = '0 | UDR_RX ;
            `NF_UART_DR :   rd = '0 | UDVR_0 ;
            default     : ;
        endcase
    end
    // creating control and data registers
    nf_register_we #( 8  ) nf_uart_tx_reg    ( clk , resetn , uart_tx_we , wd        , UDR_TX    );
    nf_register_we #( 16 ) nf_uart_dv_reg    ( clk , resetn , uart_dv_we , wd        , UDVR_0    );
    nf_register_we #( 1  ) nf_uart_tx_en     ( clk , resetn , uart_cr_we , CRI.TX_EN , CRO.TX_EN );
    nf_register_we #( 1  ) nf_uart_rx_en     ( clk , resetn , uart_cr_we , CRI.RX_EN , CRO.RX_EN );
    // creating one cross domain crossing for tx request
    nf_cdc 
    #(
        .width      ( 1             )
    )
    nf_cdc_req
    (  
        .resetn_1   ( resetn        ),  // controller side reset
        .resetn_2   ( resetn        ),  // uart side reset
        .clk_1      ( clk           ),  // controller side clock
        .clk_2      ( clk           ),  // uart side clock
        .we_1       ( uart_cr_we    ),  // controller side write enable
        .we_2       ( req_ack       ),  // uart side write enable
        .data_1_in  ( CRI.TX_REQ    ),  // controller side request
        .data_2_in  ( !req_ack      ),  // uart side request
        .data_1_out ( CRO.TX_REQ    ),  // controller side request out
        .data_2_out ( req           ),  // uart side request out
        .wait_1     (               ),
        .wait_2     (               )
    );
    // creating one cross domain crossing for rx valid
    nf_cdc 
    #(
        .width      ( 1             )
    )
    nf_cdc_valid
    (  
        .resetn_1   ( resetn        ),  // controller side reset
        .resetn_2   ( resetn        ),  // uart side reset
        .clk_1      ( clk           ),  // controller side clock
        .clk_2      ( clk           ),  // uart side clock
        .we_1       ( uart_cr_we    ),  // controller side write enable
        .we_2       ( rx_valid      ),  // uart side write enable
        .data_1_in  ( CRI.RX_VAL    ),  // controller side valid
        .data_2_in  ( rx_valid      ),  // uart side valid
        .data_1_out ( CRO.RX_VAL    ),  // controller side valid out
        .data_2_out ( rx_val_set    ),  // uart side valid out
        .wait_1     (               ),
        .wait_2     (               )
    );
    // creating one uart transmitter 
    nf_uart_transmitter 
    nf_uart_transmitter_0
    (
        // reset and clock
        .clk        ( clk           ),     // clk
        .resetn     ( resetn        ),     // resetn
        // controller side interface
        .tr_en      ( CRO.TX_EN     ),     // transmitter enable
        .comp       ( UDVR_0        ),     // compare input for setting baudrate
        .tx_data    ( UDR_TX        ),     // data for transfer
        .req        ( req           ),     // request signal
        .req_ack    ( req_ack       ),     // acknowledgent signal
        // uart tx side
        .uart_tx    ( uart_tx       )      // UART tx wire
    );
    // creating one uart receiver 
    nf_uart_receiver 
    nf_uart_receiver_0
    (
        // reset and clock
        .clk        ( clk           ),      // clk
        .resetn     ( resetn        ),      // resetn
        // controller side interface
        .rec_en     ( CRO.RX_EN     ),      // receiver enable
        .comp       ( UDVR_0        ),      // compare input for setting baudrate
        .rx_data    ( UDR_RX        ),      // received data
        .rx_valid   ( rx_valid      ),      // receiver data valid
        .rx_val_set ( rx_val_set    ),      // receiver data valid set
        // uart rx side
        .uart_rx    ( uart_rx       )       // UART rx wire
    );

endmodule : nf_uart_top
