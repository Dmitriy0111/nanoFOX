# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2018.12.05
#  Language        :   Assembler
#  Description     :   This is example for working with GPIO
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.equ NF_RAM_ADDR ,  0x00000
.equ NF_GPIO_ADDR,  0x00010
.equ NF_PWM_ADDR ,  0x00020

.section    .text


_start:     lui     t1, NF_GPIO_ADDR        # load upper bytes of addr GPIO;
            lui     t2, 0x00
            addi    t2, t2, 0x20            # load max value for gpio;
clean_t0:   lui     t0, 0                   # t0 = 0 ; clear t0;
            sw      t0, 0x04 (t1)           # mem[ 0x04 + t1 ] = t0; 
gpio_load:  lw      t0, 0x04 (t1)           # mem[ 0x04 + t1 ] = t0;   
            addi    t0, t0, 1               # t0 = t0 + 1;
            sw      t0, 0x04 (t1)           # mem[ 0x04 + t1 ] = t0;      
            beq     t0, t2, clean_t0        # go to clean_t0;
            beq     zero, zero, gpio_load   # go to gpio_load;
            