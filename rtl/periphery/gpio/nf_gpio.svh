/*
*  File            :   nf_gpio.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.21
*  Language        :   SystemVerilog
*  Description     :   This is constants for GPIO module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`ifndef NF_GPIO_CONSTANTS
`define NF_GPIO_CONSTANTS 1

    typedef enum logic [3 : 0]
    {
        NF_GPIO_GPI =   4'h0,
        NF_GPIO_GPO =   4'h4,
        NF_GPIO_DIR =   4'h8,
        NF_GPIO_EN  =   4'hC
    } nf_gpio_consts;  // gpio constants

`endif
