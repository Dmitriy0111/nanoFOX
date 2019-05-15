# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.15
#  Language        :   Assembler
#  Description     :   This is test program for csr instructions
#  Copyright(c)    :   2019 Vlasov D.V.
# 

.section    .text
main:
_start:     la s0, 0x01234567
            csrrw  s1, 0x11, s0  # rd , csr_addr , rs1
            csrrwi s1, 0x12, 0x8  # rd , csr_addr , rs1
while_1:
            j    while_1
