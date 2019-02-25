// GPIO registers addr
#define     NF_GPIO_GPI_ADDR    0x00010000
#define     NF_GPIO_GPO_ADDR    0x00010004
#define     NF_GPIO_GPD_ADDR    0x00010008
// GPIO registers
#define     NF_GPIO_GPI         (* (volatile unsigned *) NF_GPIO_GPI_ADDR )
#define     NF_GPIO_GPO         (* (volatile unsigned *) NF_GPIO_GPO_ADDR )
#define     NF_GPIO_GPD         (* (volatile unsigned *) NF_GPIO_GPD_ADDR )
