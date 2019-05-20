# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.20
#  Language        :   Assembler
#  Description     :   This is test program for csr pmp
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.section    .text
main:
_start:     la s0, 0x01234567           # load 01234567 value in s0
            csrrw  s1, ustatus, s0      # csr read to s1 , csr = ustatus , write from s0
            csrwi  uie, 0x5             # csr              csr = uie     , write zimm( 0x5 )
            csrrwi s2, uie, 0x8         # csr read to s2 , csr = ustatus , write zimm( 0x8 )
            csrsi  uie, 0x7             # csr            , csr = uie     , set with mask zimm( 0x5 )
            csrr   s1,  uie             # csr read to s1 , csr = uie
            csrci  uie, 0x7             # csr            , csr = uie     , clear with mask zimm( 0x5 )
while_1:
            j    while_1
