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
    int exception = read_csr_v(scause); // read cause register
    if( exception == 5 )
        __asm   (
                    "lui    sp , 0x1        \n\t"
                    "addi   sp , sp,  -256" 
                );  // reset stack pointer to 0xf00
    int i = 0;
    char value;
    for( i = 0 ; i < 8 ; i ++ )
    {
        value = exception & 0xf;
        exp_message[19 + 7 - i] = ( value < 10 ) ? value + 0x30 : value + 0x37;
        exception = exception >> 4;
    }
    i = 0;
    NF_UART_DV = NF_UART_SP_115200;     // set baudrate
    NF_UART_CR = NF_UART_TX_EN;         // enable transmitter
    while( i != 29 )
    {
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
