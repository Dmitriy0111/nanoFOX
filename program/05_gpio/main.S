# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2018.12.05
#  Language        :   Assembler
#  Description     :   This is example for working with GPIO
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.equ NF_GPIO_GPI,   0x00010000
.equ NF_GPIO_GPO,   0x00010004
.equ NF_GPIO_DIR,   0x00010008

.section    .text

_start:     lui     t1, %hi(NF_GPIO_GPI)        # load upper bytes of addr gpio;
            lui     t2, 0x00
clean_t0:   lui     t0, 0                       # t0 = 0 ; clear t0;
gpio_load:  lw      t2, %lo(NF_GPIO_GPI) (t1)   # t2 = gpi ; mem[ 0x04 + t1 ]
            add     t0, t2, t0                  # t0 = t0 + 1;
            sw      t0, %lo(NF_GPIO_GPO) (t1)   # mem[ 0x00 + t1 ] = t0;
            beq     zero, zero, gpio_load       # go to gpio_load;
