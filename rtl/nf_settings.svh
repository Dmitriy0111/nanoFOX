/*
*  File            :   nf_settings.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is file with common settings
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`define debug 1

`define RV32I

`ifdef RV32I
`define reg_number 32
`endif

`ifdef RV32E
`define reg_number 16
`endif

`ifndef reg_number
`define reg_number 32
`endif
//depth of ram module
`define ram_depth  64
//number of slave device's
`define slave_number 4

/*  
    memory map for devices

    0x0000_0000
        RAM
    0x0000_3fff
        unused
    0x0000_7f00
        GPIO
    0x0000_7fff
        unused
    0x0000_8f00
        PWM
    0x0000_8fff
        unused
    0xffff_ffff
*/
`define NF_RAM_ADDR_MATCH   18'h0000_0
`define NF_GPIO_ADDR_MATCH  24'h0000_7f
`define NF_PWM_ADDR_MATCH   24'h0000_8f
//constant's for gpio module
`define NF_GPIO_GPI         'h0
`define NF_GPIO_GPO         'h4
`define NF_GPIO_DIR         'h8
`define NF_GPIO_WIDTH       8
