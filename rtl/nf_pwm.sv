/*
*  File            :   nf_pwm.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is PWM module
*  Copyright(c)    :   2018 Vlasov D.V.
*/

module nf_pwm
#(
    parameter                   pwm_width = 8
)(
    input   logic               clk,
    input   logic               resetn,
    //nf_router side
    input   logic   [31 : 0]    addr,
    input   logic               we,
    input   logic   [31 : 0]    wd,
    output  logic   [31 : 0]    rd,
    //pmw_side
    input   logic               pwm_clk,
    input   logic               pwm_resetn,
    output  logic               pwm
);

    logic   [pwm_width-1 : 0]  pwm_i;      //internal counter register
    logic   [pwm_width-1 : 0]  pwm_c;      //internal compare register

    assign pwm = (pwm_i >= pwm_c);
    assign rd  = { '0 , pwm_c };

    always_ff @(posedge pwm_clk, negedge pwm_resetn)
    begin : work_with_counter_pwm
        if(!pwm_resetn)
            pwm_i <= '0;
        else
            pwm_i <= pwm_i + 1'b1;
    end
    
    always_ff @(posedge clk, negedge resetn)
    begin : work_with_compare_pwm
        if(!resetn)
            pwm_c <= '0;
        else
            if(we)
                pwm_c <= wd;
    end

endmodule : nf_pwm
