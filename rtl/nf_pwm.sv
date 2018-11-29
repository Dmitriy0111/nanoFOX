/*
*  File            :   nf_pwm.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is PWM module
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_pwm
(
    input   logic               clk,
    input   logic               resetn,
    //nf_router side
    input   logic   [31 : 0]    addr,
    input   logic               we,
    input   logic   [31 : 0]    wd,
    output  logic   [31 : 0]    rd,
    //pmw_side
    output  logic               pwm
);

endmodule : nf_pwm
