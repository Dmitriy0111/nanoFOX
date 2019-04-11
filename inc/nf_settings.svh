/*
*  File            :   nf_settings.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is file with common settings
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

//depth of ram module
`define ram_depth   64
//path to program file
`define path2file   "../../program_file/program"
//number of slave device's
`define SLAVE_COUNT 4
// program counter init value
`define PROG_START  32'h00_00_00_00

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
                 UART
                /
    0x0003_ffff/
    0x0004_0000\
                \
                 Unused
                /
    0xffff_ffff/
*/
`define NF_RAM_ADDR_MATCH   32'h0000XXXX
`define NF_GPIO_ADDR_MATCH  32'h0001XXXX
`define NF_PWM_ADDR_MATCH   32'h0002XXXX
`define NF_UART_ADDR_MATCH  32'h0003XXXX

`ifndef ahb_vector_
`define ahb_vector_
    parameter   logic   [0 : `SLAVE_COUNT-1][31 : 0]    ahb_vector = 
                                                                    {
                                                                        `NF_RAM_ADDR_MATCH,
                                                                        `NF_GPIO_ADDR_MATCH,
                                                                        `NF_PWM_ADDR_MATCH,
                                                                        `NF_UART_ADDR_MATCH
                                                                    };
`endif

//constant's for gpio module
`define NF_GPIO_GPI         'h0
`define NF_GPIO_GPO         'h4
`define NF_GPIO_DIR         'h8
`define NF_GPIO_WIDTH       8

//constant's for uart module
`define NF_UART_CR          'h0
`define NF_UART_TX          'h4
`define NF_UART_RX          'h8
`define NF_UART_DR          'hC
