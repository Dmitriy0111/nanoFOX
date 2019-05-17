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
clean_regs:
            lui  ra,   0x00 # reset ra  value
            lui  sp,   0x00 # reset sp  value
            lui  gp,   0x00 # reset gp  value
            lui  tp,   0x00 # reset tp  value
            lui  t0,   0x00 # reset t0  value
            lui  t1,   0x00 # reset t1  value
            lui  t2,   0x00 # reset t2  value
            lui  s0,   0x00 # reset s0  value
            lui  s1,   0x00 # reset s1  value
            lui  a0,   0x00 # reset a0  value
            lui  a1,   0x00 # reset a1  value
            lui  a2,   0x00 # reset a2  value
            lui  a3,   0x00 # reset a3  value
            lui  a4,   0x00 # reset a4  value
            lui  a5,   0x00 # reset a5  value
            lui  a6,   0x00 # reset a6  value
            lui  a7,   0x00 # reset a7  value
            lui  s2,   0x00 # reset s2  value
            lui  s3,   0x00 # reset s3  value
            lui  s4,   0x00 # reset s4  value
            lui  s5,   0x00 # reset s5  value
            lui  s6,   0x00 # reset s6  value
            lui  s7,   0x00 # reset s7  value
            lui  s8,   0x00 # reset s8  value
            lui  s9,   0x00 # reset s9  value
            lui  s10,  0x00 # reset s10 value
            lui  s11,  0x00 # reset s11 value
            lui  t3,   0x00 # reset t3  value
            lui  t4,   0x00 # reset t4  value
            lui  t5,   0x00 # reset t5  value
            lui  t6,   0x00 # reset t6  value
_start:     
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
            j    read_test_data
