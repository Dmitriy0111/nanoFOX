/*
*  File            :   nf_gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is GPIO module
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_gpio
(
    input   logic               clk,
    input   logic               resetn,
    //nf_router side
    input   logic   [31 : 0]    addr,
    input   logic               we,
    input   logic   [31 : 0]    wd,
    output  logic   [31 : 0]    rd,
    //gpio_side
    input   logic   [7  : 0]    gpi,
    output  logic   [7  : 0]    gpo
);

endmodule : nf_gpio
