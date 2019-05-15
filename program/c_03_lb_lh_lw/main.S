# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.15
#  Language        :   Assembler
#  Description     :   This is test program for lh, lb, lw instructions
#  Copyright(c)    :   2019 Vlasov D.V.
# 

.section    .text
main:
_start:     lui  s0, 0                  # s0 = 0; clear s0
            addi s0, s0, 200            # s0 = s0 + 100
            la   s1, 0x01234567
            la   s2, 0xaa557788
load_test_data:
            sw   s1, 0x00(s0)
            sw   s2, 0x04(s0)
read_test_data:
            lb   s3, 0x00(s0)
            lb   s3, 0x01(s0)
            lb   s3, 0x02(s0)
            lb   s3, 0x03(s0)
            lb   s3, 0x04(s0)
            lb   s3, 0x05(s0)
            lb   s3, 0x06(s0)
            lb   s3, 0x07(s0)
            lh   s3, 0x00(s0)
            lh   s3, 0x02(s0)
            lh   s3, 0x04(s0)
            lh   s3, 0x06(s0)
            lbu  s3, 0x00(s0)
            lbu  s3, 0x01(s0)
            lbu  s3, 0x02(s0)
            lbu  s3, 0x03(s0)
            lbu  s3, 0x04(s0)
            lbu  s3, 0x05(s0)
            lbu  s3, 0x06(s0)
            lbu  s3, 0x07(s0)
            lhu  s3, 0x00(s0)
            lhu  s3, 0x02(s0)
            lhu  s3, 0x04(s0)
            lhu  s3, 0x06(s0)
            lw   s3, 0x00(s0)
            lw   s3, 0x04(s0)
            wfi
            j    read_test_data
