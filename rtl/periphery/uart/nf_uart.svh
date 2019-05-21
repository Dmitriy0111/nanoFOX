/*
*  File            :   nf_uart.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.21
*  Language        :   SystemVerilog
*  Description     :   This is constants for uart module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`ifndef NF_UART_CONSTANTS
`define NF_UART_CONSTANTS 1

    typedef struct packed
    {
        logic   [3  : 0]    UN;     // unused
        logic   [0  : 0]    RX_EN;  // receiver enable
        logic   [0  : 0]    TX_EN;  // transmitter enable
        logic   [0  : 0]    RX_VAL; // rx byte received
        logic   [0  : 0]    TX_REQ; // request transmit
    } UCR;  // uart control reg

    typedef struct packed
    {
        logic   [15 : 0]    COMP;   // data for comparing
    } UDVR;  // uart divide reg

    typedef struct packed
    {
        logic   [7  : 0]    DATA;   // data field
    } UDR;  // uart data register

    typedef enum logic [3 : 0]
    {
        NF_UART_CR  =   4'h0,
        NF_UART_TX  =   4'h4,
        NF_UART_RX  =   4'h8,
        NF_UART_DR  =   4'hC
    } nf_uart_consts;  // uart constants

`endif
