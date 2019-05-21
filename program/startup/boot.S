#
#  File            :   boot.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.03.03
#  Language        :   Assembler
#  Description     :   This is Assembler file for first initialization nanoFOX
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
#

.equ    _stack_start,   0x0000f00  # 3C0 << 2

nanoFOX_vectors:
        j _main         # 0x00  vector  ( reset vector )
        j vector_1      # 0x01  vector  ( exception vector )
        j vector_2      # 0x02  vector
        j vector_3      # 0x03  vector
        j vector_4      # 0x04  vector
        j vector_5      # 0x05  vector
        j vector_6      # 0x06  vector
        j vector_7      # 0x07  vector
        j vector_8      # 0x08  vector
        j vector_9      # 0x09  vector
        j vector_10     # 0x0a  vector
        j vector_11     # 0x0b  vector
        j vector_12     # 0x0c  vector
        j vector_13     # 0x0d  vector
        j vector_14     # 0x0e  vector
        j vector_15     # 0x0f  vector

_main:
_clean_registers:
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
load_sp:
        la   sp, _stack_start   # load stack pointer value
        j    main               # jump to main program
