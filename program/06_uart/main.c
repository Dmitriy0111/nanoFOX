/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.25
*  Language        :   C
*  Description     :   This is examples for working with UART
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#include "../nf_drivers/nf_uart.h"
#include "../nf_drivers/nf_gpio.h"

char message[14] = "Hello World!\n\r";

int main ()
{
    int i;
    NF_GPIO_EN = 1;
    i=0;
    NF_UART_DV = NF_UART_SP_115200;
    NF_UART_CR = NF_UART_TX_EN;
    while( i != 14 )
    {
        NF_UART_TX = message[i];
        NF_UART_CR = NF_UART_TX_EN | NF_UART_TX_SEND;
        while( NF_UART_CR == ( NF_UART_TX_EN | NF_UART_TX_SEND ) );
        i++;
    }
    NF_GPIO_GPO = i;
    while(1);
    return 0;
}