# this is GPIO program example

.equ NF_RAM_ADDR ,  0x00000
.equ NF_GPIO_ADDR,  0x00010
.equ NF_PWM_ADDR ,  0x00020

.section    .text

_start:     lui     t0, 1                   # t0 = 0 ; clear t0;
            lui     t1, NF_PWM_ADDR         # load upper bytes of addr PWM;
pwm_load:   sw      t0, 0x00 (t1)           # mem[ 0x00 + t1 ] = t0;        
            addi    t0, t0, 1               # t0 = t0 + 1;
            beq     zero, zero, pwm_load    # go to pwm_load;
            