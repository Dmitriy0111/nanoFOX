.equ    _main_addr,     0x00000040
.equ    _stack_start,   0x00000400

nanoFOX_vectors:
        j _main         # reset vector
        j vector_1      # 0x01  vector
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
        lui  sp,     %hi(_stack_start)  # load stack pointer value
        addi sp, sp, %lo(_stack_start)  # load stack pointer value
        j    main
