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

int message[14] = {'H','e','l','l','o',' ','W','o','r','l','d','!','\n','\r'};
//char message[14] = "Hello World!\n\r"; doesn't work

int main ()
{
    int i;
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
    NF_GPIO_GPO = 0x55;
    while(1);
    return 0;
}