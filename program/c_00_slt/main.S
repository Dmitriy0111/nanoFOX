# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.13
#  Language        :   Assembler
#  Description     :   This is test program for slt command
#  Copyright(c)    :   2019 Vlasov D.V.
# 

.section    .text
main:
_start:     lui     t0, 0                   # t0 = 0 ; clear t0   
counter:    addi    t0, t0, 1               # t0 = t0 + 1 ; addition t0 with 1
            beq     zero, zero, counter     # go to counter label
