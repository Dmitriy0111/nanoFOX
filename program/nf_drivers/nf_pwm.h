/*
*  File            :   nf_pwm.h
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.25
*  Language        :   C
*  Description     :   This is constants for working with PWM
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

// PWM registers addr
#define     NF_PWM_ADDR     0x00020000
// PWM registers
#define     NF_PWM          (* (volatile unsigned *) NF_PWM_ADDR )
