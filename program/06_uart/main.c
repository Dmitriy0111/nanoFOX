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
#include "../nf_drivers/nf_pwm.h"

int main ()
{
    int i;
    NF_UART_DV = NF_UART_SP_115200;
    NF_UART_CR = NF_UART_TX_EN;
    NF_UART_TX = 72;
    NF_UART_CR = NF_UART_TX_EN | NF_UART_TX_SEND;
    while( NF_UART_CR == ( NF_UART_TX_EN | NF_UART_TX_SEND ) );
    __asm("nop");
    NF_GPIO_GPO = 0x55;
    while(1);
    return 0;
}