/*
*  File            :   nf_router_dec.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is decoder unit for routing lw sw command's
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_router_dec
#(
    parameter                           Slave_n = `slave_number
)(
    input   logic   [31 : 0]            addr_m,
    output  logic   [Slave_n-1 : 0]     slave_sel
);  
    // Decode based on most significant bits of the address
    // RAM   0x00000000 - 0x00003fff
    assign slave_sel[0] = ( addr_m [ 15:14 ] == `NF_RAM_ADDR_MATCH);

    // GPIO module  0x00007f00 - 0x00007f0f
    assign slave_sel[1] = ( addr_m [ 15:4  ] == `NF_GPIO_ADDR_MATCH);

    // PWM module   0x00007f10 - 0x00007f1f
    assign slave_sel[2] = ( addr_m [ 15:4  ] == `NF_PWM_ADDR_MATCH);

    assign slave_sel[3] = '0;

endmodule : nf_router_dec

