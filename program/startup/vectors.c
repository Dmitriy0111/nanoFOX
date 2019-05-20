/*
*  File            :   vectors.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.14
*  Language        :   C
*  Description     :   This is source file for working with vectors
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#include "../nf_drivers/nf_csr.h"
#include "../nf_drivers/nf_uart.h"

char exp_message[29] = "Exception code = 0x00000000\n\r";

void __attribute__((noreturn)) vector_1(void)
{
    __asm("lui sp, 0x00001");           // reset stack pointer to 0x1000
    int exception = read_csr_v(scause); // read cause register
    int i = 0;
    // TODO :
    //exp_message[26] = ( exception >>  0 ) + 0x30;
    //exp_message[25] = ( exception >>  4 ) + 0x30;
    //exp_message[24] = ( exception >>  8 ) + 0x30;
    //exp_message[23] = ( exception >> 12 ) + 0x30;
    //exp_message[22] = ( exception >> 16 ) + 0x30;
    //exp_message[21] = ( exception >> 20 ) + 0x30;
    //exp_message[20] = ( exception >> 24 ) + 0x30;
    //exp_message[19] = ( exception >> 28 ) + 0x30;
    NF_UART_DV = NF_UART_SP_115200;     // set baudrate
    NF_UART_CR = NF_UART_TX_EN;         // enable transmitter
    while( i != 29 )
    {
        if(i == 19)
            NF_UART_TX = exception + 0x30;  // write exception number
        else
            NF_UART_TX = exp_message[i];    // write message
        NF_UART_CR = NF_UART_TX_EN | NF_UART_TX_SEND;
        while( NF_UART_CR == ( NF_UART_TX_EN | NF_UART_TX_SEND ) );
        i++;
    }
    while(1);
}

void __attribute__((noreturn)) vector_2(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_3(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_4(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_5(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_6(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_7(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_8(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_9(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_10(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_11(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_12(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_13(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_14(void)
{
    while(1);
}

void __attribute__((noreturn)) vector_15(void)
{
    while(1);
}
