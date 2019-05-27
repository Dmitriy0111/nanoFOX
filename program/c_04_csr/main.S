# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.15
#  Language        :   Assembler
#  Description     :   This is test program for csr instructions
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.section    .text
main:
_start:     la s0, 0x01234567
            csrrw  s1, mtvec, s0
            csrwi  mtvec, 0x5
            csrrwi s2, mtvec, 0x8
            csrsi  mtvec, 0x7
            csrr   s1,  mtvec
            csrci  mtvec, 0x7
while_1:
            j    while_1
