# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.02.24
#  Language        :   Assembler
#  Description     :   This is example for working with UART
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.equ NF_RAM_ADDR      , 0x00000
.equ NF_GPIO_ADDR     , 0x00010
.equ NF_PWM_ADDR      , 0x00020
.equ NF_UART_ADDR     , 0x00030
.equ NF_UART_CR       , 0x0
.equ NF_UART_TX       , 0x4
.equ NF_UART_RX       , 0x8
.equ NF_UART_DR       , 0xC
.equ NF_UART_SP_115200, 0x1B2

.section    .text

_start:     lui     a4, 0x30
            addi    a3, zero, 0x04
            addi    a5, zero, 0x48
            addi    a2, zero, NF_UART_SP_115200
            sw      a2, 0xC(a4)
            sw      a3, 0x0(a4)
            sw      a5, 0x4(a4)
            addi    a3, zero, 0x05
            sw      a3, 0x0(a4)
loop1:      lw      a1, 0x0(a4)
            beq     a3, a1, loop1
            lui     a4, 0x10
            sw      a5, 0x4(a4)
loop2:      jal     zero, loop2
loop3:      jal     zero, loop3
loop4:      jal     zero, loop4
loop5:      jal     zero, loop5

