# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2018.11.30
#  Language        :   Assembler
#  Description     :   This is number's of leonardo example
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.section    .text   

_start:     lui     t0, 0                   # t0 = 0 ; clear t0   
            addi    t0, t0, 1               # t0 = t0 + 1 ; addition t0 with 1
            addi    t1, t0, 0               # t1 = t0 ; mv t1, t0
            addi    s1, t1, 0               # s1 = t1 ; mv s1, t1

leonardo:   add     t0, t0, t1
            addi    t0, t0, 1               # t0 = t0 + 1 ; addition t0 with 1
            addi    s1, t0, 0               # s1 = t0 ; mv s1, t0
            add     t1, t0, t1              # t1 = t0 + t1 ; 
            addi    t1, t1, 1               # t0 = t0 + 1 ; addition t0 with 1
            addi    s1, t1, 0               # s1 = t1 ; mv s1, t1
            beq     zero, zero, leonardo    # go to leonardo label
