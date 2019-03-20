# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2018.11.30
#  Language        :   Assembler
#  Description     :   This is running bit example
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.section    .text

_start:     lui     t0, 0                   # t0 = 0 ; clear t0
            addi    t0, t0, 1               # t0 = t0 + 1 ; addition t0 with 1         
counter:    slli    t0, t0, 1               # t0 = t0 << 1 ; left shift t0
            beq     t0, zero, _start        # go to _start label
            beq     zero, zero, counter     # go to counter label
