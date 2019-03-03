.equ    _main_addr,     0x00000040
.equ    _stack_start,   0x00000100

nanoFOX_vectors:
        j _main         # reset vector
.word   0x00000000      # 0x01
.word   0x00000000      # 0x02
.word   0x00000000      # 0x03
.word   0x00000000      # 0x04
.word   0x00000000      # 0x05
.word   0x00000000      # 0x06
.word   0x00000000      # 0x07
.word   0x00000000      # 0x08
.word   0x00000000      # 0x09
.word   0x00000000      # 0x0a
.word   0x00000000      # 0x0b
.word   0x00000000      # 0x0c
.word   0x00000000      # 0x0d
.word   0x00000000      # 0x0e
.word   0x00000000      # 0x0f

_main:
        lui  sp,     %hi(_stack_start)  # load stack pointer value
        addi sp, sp, %lo(_stack_start)  # load stack pointer value
