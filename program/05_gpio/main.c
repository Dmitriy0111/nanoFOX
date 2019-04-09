/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.05
*  Language        :   C
*  Description     :   This is examples for working with GPIO
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#include "../nf_drivers/nf_gpio.h"

#define SYNTH   1
#define SIM     0
#define RUNTYPE SIM

#if   RUNTYPE == SIM
    #define delay_value 10
#elif RUNTYPE == SYNTH
    #define delay_value 100000
#endif

void delay(int delay_c)
{
    volatile int delay_v = delay_c;
    while(delay_v)
        delay_v--;
}

void main (void)
{
    int i = 1;
    NF_GPIO_GPO = i;
    while(1)
    {
        delay(delay_value);
        i = NF_GPIO_GPO;
        if( i == 20 )
            i = 0;
        else
            i += NF_GPIO_GPI;
        NF_GPIO_GPO = i;
    }
}