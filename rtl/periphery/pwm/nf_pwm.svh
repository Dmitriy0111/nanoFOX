/*
*  File            :   nf_pwm.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.21
*  Language        :   SystemVerilog
*  Description     :   This is constants for PWM module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`ifndef NF_PWM_CONSTANTS
`define NF_PWM_CONSTANTS 1

    typedef enum logic [3 : 0]
    {
        NF_PWM_CR      =   4'h0,
        NF_PWM_ENR     =   4'h4
    } nf_pwm_consts;  // pwm constants

`endif
