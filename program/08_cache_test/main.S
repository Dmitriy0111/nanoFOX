# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.06.20
#  Language        :   Assembler
#  Description     :   This is example for testing cache
#  Copyright(c)    :   2019 Vlasov D.V.
# 

.equ CACHE_TEST_ADDR,  256

.section    .text

_start:     lui     sp,     %hi(CACHE_TEST_ADDR)    # load stack pointer value
            addi    sp, sp, %lo(CACHE_TEST_ADDR)    # load stack pointer value
            lui     t0, 0x00
            lui     t1, 0x00
            addi    t1, t1, 0x20
            lui     t2, 0x00
            addi    t2, t2, 64

loop_wr:    sw      t1, 0x00( sp )
            addi    sp, sp, 0x04
            addi    t1, t1, 0x10
            addi    t0, t0, 0x01
            bne     t0, t2, loop_wr

            lui     t0, 0x00
            lui     sp,     %hi(CACHE_TEST_ADDR)    # load stack pointer value
            addi    sp, sp, %lo(CACHE_TEST_ADDR)    # load stack pointer value

loop_rd0:   lw      t1, 0x00( sp )
            addi    sp, sp, 0x04
            addi    t1, t1, 0x10
            addi    t0, t0, 0x01
            bne     t0, t2, loop_rd0

            lui     t0, 0x00
            la      sp, test_rd_word

loop_rd1:   lw      t1, 0x00( sp )
            addi    sp, sp, 0x04
            addi    t0, t0, 0x01
            bne     t0, t2, loop_rd1

while_1:    j       _start

.data
    .align 4

test_rd_word:
    .word 0x10203040    # addr 0x00
    .word 0x50607080    # addr 0x01
    .word 0x90a0b0c0    # addr 0x02
    .word 0xd0e0f000    # addr 0x03
    .word 0x11223344    # addr 0x04
    .word 0x55667788    # addr 0x05
    .word 0x99aabbcc    # addr 0x06
    .word 0xddeeff00    # addr 0x07
    .word 0x45653231    # addr 0x08
    .word 0x3141dabc    # addr 0x09
    .word 0x12341453    # addr 0x10
    .word 0x63567747    # addr 0x11
    .word 0x25466767    # addr 0x12
    .word 0x97585768    # addr 0x13
    .word 0x11111111    # addr 0x14
    .word 0x22222222    # addr 0x15
    .word 0x33333333    # addr 0x16
    .word 0x44444444    # addr 0x17
    .word 0x55555555    # addr 0x18
    .word 0x66666666    # addr 0x19
    .word 0x77777777    # addr 0x20
    .word 0x88888888    # addr 0x21
    .word 0x99999999    # addr 0x22
    .word 0xaaaaaaaa    # addr 0x23
    .word 0xbbbbbbbb    # addr 0x24
    .word 0xcccccccc    # addr 0x25
    .word 0xdddddddd    # addr 0x26
    .word 0xeeeeeeee    # addr 0x28
    .word 0xffffffff    # addr 0x29
    .word 0x00000000    # addr 0x30
    .word 0xab324235    # addr 0x31
    .word 0x13451341    # addr 0x32
    .word 0x34513423    # addr 0x33
    .word 0x13412341    # addr 0x34
    .word 0x56354241    # addr 0x35
    .word 0x43652451    # addr 0x36
    .word 0x46767324    # addr 0x37
    .word 0x75867635    # addr 0x38
    .word 0x56869895    # addr 0x39
    .word 0x54635245    # addr 0x40
    .word 0x89850578    # addr 0x41
    .word 0x47636565    # addr 0x42
    .word 0x15785784    # addr 0x43
    .word 0x5768ab23    # addr 0x44
    .word 0x1a20a40c    # addr 0x45
    .word 0x1a203a40    # addr 0x46
    .word 0x10a89687    # addr 0x47
    .word 0xa020304a    # addr 0x48
    .word 0x10256245    # addr 0x49
    .word 0x10135baf    # addr 0x50
    .word 0xa0135baf    # addr 0x51
    .word 0x10203a40    # addr 0x52
    .word 0x13562baf    # addr 0x53
    .word 0x10203123    # addr 0x54
    .word 0xa0135baf    # addr 0x55
    .word 0x15635220    # addr 0x56
    .word 0x50356526    # addr 0x58
    .word 0x55784675    # addr 0x59
    .word 0x13432665    # addr 0x60
    .word 0x34123453    # addr 0x61
    .word 0x11242112    # addr 0x62
    .word 0xa2351242    # addr 0x63
            