#include "../nf_drivers/nf_gpio.h"

// GPIO registers
#define     NF_GPIO_GPI         (* (volatile unsigned *) NF_GPIO_GPI_ADDR )
#define     NF_GPIO_GPO         (* (volatile unsigned *) NF_GPIO_GPO_ADDR )
#define     NF_GPIO_GPD         (* (volatile unsigned *) NF_GPIO_GPD_ADDR )

void main (void)
{
    int i = 1;
    NF_GPIO_GPO = i;
    while(1)
    {
        i = NF_GPIO_GPO;
        i++;
        NF_GPIO_GPO = i;
    }
}