/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.15
*  Language        :   C
*  Description     :   This is test program for csr instructions
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#include "../nf_drivers/nf_gpio.h"
#include "../nf_drivers/nf_csr.h"

volatile int delay_v;

void delay(int delay_c)
{
    delay_v = delay_c;
    while(delay_v)
        delay_v--;
}

volatile int cycle_res=0;

int main ()
{
    int cycle_s=0;
    int cycle_e=0;
    cycle_s = read_csr_v(mcycle);
    write_csr_v(ustatus, 0x01234567);
    NF_GPIO_GPO = read_csr_v(ustatus);
    write_csr_v(uie, 0x5);
    NF_GPIO_GPO = read_csr_v(uie);

    delay(400);

    cycle_e = read_csr_v(mcycle);
    __asm("nop");
    cycle_res = cycle_e - cycle_s;
    NF_GPIO_GPO = cycle_res;

    while( 1 )
    {
        ;
    }
    return 0;
}