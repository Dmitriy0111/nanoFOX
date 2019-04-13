/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.03
*  Language        :   C
*  Description     :   This is simple memory example
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#include "../nf_drivers/nf_gpio.h"

int msg[3] = {0x55,0xaa,0x77};

void main (void)
{
    int i;
    i=0;
    while( i != 3 )
    {
        NF_GPIO_GPO = msg[i];
        i++;
    }
    NF_GPIO_GPO = i;
    while(1);
}
