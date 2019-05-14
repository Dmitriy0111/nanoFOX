# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.14
#  Language        :   Assembler
#  Description     :   This is test program for bltu command
#  Copyright(c)    :   2019 Vlasov D.V.
# 

.section    .text
main:
_start:     lui  s2, 0                   # s2 = 0 ; clear s2   
            lui  s1, 0                   # s1 = 0 ; clear s1 
            addi s2, s2, 20
comp_s2_s1:
            bltu s2, s1,
            addi s1, s1, 1
            beq  zero, zero, comp_s2_s1
            lui  s1, 0
            beq  zero, zero, comp_s2_s1
