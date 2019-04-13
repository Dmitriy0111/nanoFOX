/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.10
*  Language        :   C
*  Description     :   This is examples for working with UART (receive example)
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#include "../nf_drivers/nf_uart.h"
#include "../nf_drivers/nf_gpio.h"

int main ()
{
    NF_UART_DV = NF_UART_SP_115200;
    NF_UART_CR = NF_UART_RX_EN;
    while( 1 )
    {
        while( NF_UART_CR != ( NF_UART_RX_EN | NF_UART_RX_VALID ) );
        NF_UART_CR = NF_UART_RX_EN;
        NF_GPIO_GPO = NF_UART_RX;
    }
    return 0;
}