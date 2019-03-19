/*
*  File            :   nf_uart.h
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.25
*  Language        :   C
*  Description     :   This is constants for working with UART
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

// UART registers addr
#define     NF_UART_CR_ADDR     0x00030000
#define     NF_UART_TX_ADDR     0x00030004
#define     NF_UART_RX_ADDR     0x00030008
#define     NF_UART_DV_ADDR     0x0003000C
// UART constants
#define     NF_UART_SP_115200   0x1B2
#define     NF_UART_TX_SEND     0x1
#define     NF_UART_TX_EN       0x2
#define     NF_UART_RX_EN       0x4
#define     NF_UART_RX_VALID    0x8
// UART registers
#define     NF_UART_CR          (* (volatile unsigned *) NF_UART_CR_ADDR )
#define     NF_UART_TX          (* (volatile unsigned *) NF_UART_TX_ADDR )
#define     NF_UART_RX          (* (volatile unsigned *) NF_UART_RX_ADDR )
#define     NF_UART_DV          (* (volatile unsigned *) NF_UART_DV_ADDR )
