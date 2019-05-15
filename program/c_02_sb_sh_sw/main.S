# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.15
#  Language        :   Assembler
#  Description     :   This is test program for sb, sh, sw instructions
#  Copyright(c)    :   2019 Vlasov D.V.
# 

.section    .text
main:
_start:     lui  s0, 0                  # s0 = 0; clear s0
            addi s0, s0, 200            # s0 = s0 + 100
            la   s1, 0x01234567
            la   s2, 0x55aa7788
sb_sh_sw_test:
            sb   s1, 0x00(s0)
            sb   s1, 0x01(s0)
            sb   s1, 0x02(s0)
            sb   s1, 0x03(s0)
            sb   s2, 0x04(s0)
            sb   s2, 0x05(s0)
            sb   s2, 0x06(s0)
            sb   s2, 0x07(s0)
            sh   s1, 0x08(s0)
            sh   s1, 0x0a(s0)
            sh   s2, 0x0c(s0)
            sh   s2, 0x0e(s0)
            sw   s1, 0x10(s0)
            sw   s2, 0x14(s0)
            j    sb_sh_test
