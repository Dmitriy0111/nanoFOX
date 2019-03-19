# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2018.12.02
#  Language        :   Assembler
#  Description     :   This is example for working with ram
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.equ NF_RAM_ADDR ,  0x00000
.equ NF_GPIO_ADDR,  0x00010
.equ NF_PWM_ADDR ,  0x00020

.section    .text

_start:     lui     t0, 0                   # t0 = 0 ; clear t0
            lui     t1, 0                   # t1 = 0 ; clear t1
            addi    t0, t0, 0x55            # t1 = t0 + 0x55 ; addition t0 with 0x55 
write:      sw      t0, 0x0 (zero)          # mem[zero + 0x0] = t0;
            addi    t0, t0, 0x55            # t0 = t0 + 0x55 ; addition t0 with 0x55      
            sw      t0, 0x4 (zero)          # mem[zero + 0x4] = t0;
            addi    t0, t0, 0x55            # t0 = t0 + 0x55 ; addition t0 with 0x55 
            sw      t0, 0x8 (zero)          # mem[zero + 0x8] = t0;
            addi    t0, t0, 0x55            # t0 = t0 + 0x55 ; addition t0 with 0x55
            sw      t0, 0xc (zero)          # mem[zero + 0xc] = t0;
read:       lw      t1, 0x0 (zero)          # t1 = mem[zero + 0x0];
            lw      t1, 0x4 (zero)          # t1 = mem[zero + 0x4];
            lw      t1, 0x8 (zero)          # t1 = mem[zero + 0x8];
            lw      t1, 0xc (zero)          # t1 = mem[zero + 0xc];
            beq     zero, zero, _start      # go to _start label
