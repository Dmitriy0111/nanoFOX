# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2019.04.10
#  Language        :   Assembler
#  Description     :   This is example for working with UART (receive example)
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

_start:     beq     zero, zero, _start
