/*
*  File            :   nf_pwm.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is PWM module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_pwm.svh"

module nf_pwm
#(
    parameter                   pwm_width = 8
)(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clk  
    input   logic   [0  : 0]    resetn,     // resetn
    // bus side
    input   logic   [31 : 0]    addr,       // address
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // pmw_side
    input   logic   [0  : 0]    pwm_clk,    // PWM clock input
    input   logic   [0  : 0]    pwm_resetn, // PWM reset input
    output  logic   [0  : 0]    pwm         // PWM output signal
);

    logic   [pwm_width-1 : 0]   pwm_i;      // internal counter register
    logic   [pwm_width-1 : 0]   pwm_c;      // internal compare register
    // write enable signals 
    logic   [0           : 0]   pwm_cr_we;  // gpio compare register write enable
    logic   [0           : 0]   pwm_en_we;  // gpio enable register write enable
    //
    logic   [0           : 0]   pwm_en; 

    assign pwm = ( pwm_i >= pwm_c );

    assign pwm_cr_we = we && ( addr[0 +: 4] == NF_PWM_CR  );
    assign pwm_en_we = we && ( addr[0 +: 4] == NF_PWM_ENR );

    // mux for routing one register value
    always_comb
    begin
        rd = '0 | pwm_c;
        casex( addr[0 +: 4] )
            NF_PWM_CR   :   rd = '0 | pwm_c;
            NF_PWM_ENR  :   rd = '0 | pwm_en;
            default     :   ;
        endcase
    end

    always_ff @(posedge pwm_clk, negedge pwm_resetn)
    begin : work_with_counter_pwm
        if( !pwm_resetn )
            pwm_i <= '0;
        else if( pwm_en )
            pwm_i <= pwm_i + 1'b1;
    end
    
    // creating gpio registers
    nf_register_we  #( pwm_width )  pwm_cr_reg  ( clk , resetn , pwm_cr_we && pwm_en , wd , pwm_c   );
    nf_register_we  #(         1 )  pwm_en_reg  ( clk , resetn , pwm_en_we           , wd , pwm_en  );

endmodule : nf_pwm
