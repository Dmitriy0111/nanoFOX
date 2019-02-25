#include "../nf_drivers/nf_uart.h"

void inline uart_init()
{
    NF_UART_DV = NF_UART_SP_115200;
    NF_UART_CR = NF_UART_TX_EN;
}

int main ()
{
    int i;
    uart_init();
    __asm(nop);
    while(1)
    {
        NF_UART_TX = i;
        NF_UART_CR = NF_UART_TX_EN | NF_UART_TX_SEND;
        i++;
    }
    return 0;
}