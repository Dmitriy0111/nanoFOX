# this is UART program example

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

_start:     lui     t1, NF_UART_ADDR            # load upper bytes of addr UART;
            lui     t3, 0x0D                    # reset t3
            lui     t2, 0x00                    # reset t2
            addi    t2, t2, NF_UART_SP_115200   # load UART speed
            sw      t2, NF_UART_DR (t1)         # load UART speed to UART module
load_data:  lui     t2, 0x00                    # reset t2
            addi    t2, t2, 72                  # load in UART tx_data register 'H'
            sw      t2, NF_UART_TX (t1)         # load UART speed to UART module
            lui     t2, 0x00                    # reset t2
            addi    t2, t2, 0xD                 # load in UART tx_data register 'H'
            sw      t2, NF_UART_CR (t1)         # load UART speed to UART module
read_cr:    #lw      t2, NF_UART_CR (t1)         # t2 = UART control register
            #beq     t2, t3, read_cr             # go to clean_t0;
            #beq     t0, t0, load_data           # go to clean_t0;
            beq     t0, t0, read_cr           # go to clean_t0;

            