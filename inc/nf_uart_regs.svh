/*
*  File            :   nf_uart_regs.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.10
*  Language        :   SystemVerilog
*  Description     :   This is uart constants
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

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
