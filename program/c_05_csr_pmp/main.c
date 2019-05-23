/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.20
*  Language        :   C
*  Description     :   This is test program for csr pmp with bad delay function
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#include "../nf_drivers/nf_gpio.h"
#include "../nf_drivers/nf_csr.h"

#define SYNTH   1
#define SIM     0
#define RUNTYPE SYNTH

#if   RUNTYPE == SIM
    #define delay_value 2
#elif RUNTYPE == SYNTH
    #define delay_value 100000
#endif

// bad delay
void delay(int delay_c)
{
    volatile int delay_v;
    delay_v = delay_c;
    while(delay_v)
        delay_v--;
}

int main ()
{
    write_csr_v(pmpaddr0, 0x00000000);
    write_csr_v(pmpaddr1, 0x00000800);  // read only from 0x0000_0000 to 0x0000_0800
    write_csr_v(pmpaddr2, 0xffffffff);  // can write from 0x0000_0800 to 0xffff_ffff

    write_csr_v(pmpcfg0, ( 0x22 << 16 ) | ( 0x20 << 8 ) );

    int i = 1;
    NF_GPIO_GPO = i;
    NF_GPIO_EN = 1;

    while( 1 )
    {
        delay(delay_value);
        i = NF_GPIO_GPO;
        if( i == 20 )
            i = 0;
        else
            i += NF_GPIO_GPI;
        NF_GPIO_GPO = i;
    }
    return 0;
}