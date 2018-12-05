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
    input   logic   [31        : 0]     addr_m,
    output  logic   [Slave_n-1 : 0]     slave_sel
);  

    // RAM  address range  0x0000_0000 - 0x0000_3fff
    assign slave_sel[0] = ( addr_m [ 14 +: 18 ] == `NF_RAM_ADDR_MATCH  );

    // GPIO address range  0x0000_7f00 - 0x0000_7fff
    assign slave_sel[1] = ( addr_m [ 8  +: 24 ] == `NF_GPIO_ADDR_MATCH );

    // PWM  address range  0x0000_8f00 - 0x0000_8fff
    assign slave_sel[2] = ( addr_m [ 8  +: 24 ] == `NF_PWM_ADDR_MATCH  );
    
    // For future devices
    assign slave_sel[3] = '0;

endmodule : nf_router_dec
