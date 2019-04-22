/*
*  File            :   nf_settings.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is file with common settings
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

// depth of ram module
`define RAM_DEPTH       64
// number of slave device's
`define SLAVE_NUMBER    4

/*  
    memory map for devices

    0x0000_0000\
                \
                 RAM
                /
    0x0000_ffff/
    0x0001_0000\
                \
                 GPIO
                /
    0x0001_ffff/
    0x0002_0000\
                \
                 PWM
                /
    0x0002_ffff/
    0x0003_0000\
                \
                 Unused
                /
    0xffff_ffff/
*/
`define NF_RAM_ADDR_MATCH   16'h0000
`define NF_GPIO_ADDR_MATCH  16'h0001
`define NF_PWM_ADDR_MATCH   16'h0002
// constant's for gpio module
`define NF_GPIO_GPI         'h0
`define NF_GPIO_GPO         'h4
`define NF_GPIO_DIR         'h8
`define NF_GPIO_WIDTH       8
