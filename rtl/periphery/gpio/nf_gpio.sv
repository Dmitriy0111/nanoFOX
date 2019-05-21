/*
*  File            :   nf_gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is GPIO module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_gpio.svh"

module nf_gpio
#(
    parameter                       gpio_w = 8
)(
    // clock and reset
    input   logic   [0        : 0]  clk,    // clk  
    input   logic   [0        : 0]  resetn, // resetn
    // bus side
    input   logic   [31       : 0]  addr,   // address
    input   logic                   we,     // write enable
    input   logic   [31       : 0]  wd,     // write data
    output  logic   [31       : 0]  rd,     // read data
    // GPIO side
    input   logic   [gpio_w-1 : 0]  gpi,    // GPIO input
    output  logic   [gpio_w-1 : 0]  gpo,    // GPIO output
    output  logic   [gpio_w-1 : 0]  gpd     // GPIO direction
);
    // gpio enable
    logic   [0        : 0]  gpio_en;    // gpio enable
    // gpio input
    logic   [gpio_w-1 : 0]  gpio_i;     // gpio input
    // gpio output
    logic   [gpio_w-1 : 0]  gpio_o;     // gpio output
    // gpio direction
    logic   [gpio_w-1 : 0]  gpio_d;     // gpio direction
    // write enable signals 
    logic   [0        : 0]  gpo_we;     // gpio output write enable
    logic   [0        : 0]  gpd_we;     // gpio direction write enable
    logic   [0        : 0]  gpio_en_we; // gpio enable write enable
    // assign inputs/outputs
    assign gpo    = gpio_o;
    assign gpd    = gpio_d;
    assign gpio_i = gpi;
    // assign write enable signals
    assign gpo_we     = we && ( addr[0 +: 4] == NF_GPIO_GPO ); 
    assign gpd_we     = we && ( addr[0 +: 4] == NF_GPIO_DIR ); 
    assign gpio_en_we = we && ( addr[0 +: 4] == NF_GPIO_EN  ); 
    // mux for routing one register value
    always_comb
    begin
        rd = '0 | gpio_i;
        casex( addr[0 +: 4] )
            NF_GPIO_GPI  :  rd = '0 | gpio_i;
            NF_GPIO_GPO  :  rd = '0 | gpio_o;
            NF_GPIO_DIR  :  rd = '0 | gpio_d;
            NF_GPIO_EN   :  rd = '0 | gpio_en;
            default      : ;
        endcase
    end
    // creating gpio registers
    nf_register_we  #( gpio_w ) gpo_reg     ( clk , resetn , gpo_we && gpio_en , wd , gpio_o  );
    nf_register_we  #( gpio_w ) gpd_reg     ( clk , resetn , gpd_we && gpio_en , wd , gpio_d  );
    nf_register_we  #(      1 ) gpio_en_reg ( clk , resetn , gpio_en_we        , wd , gpio_en );

endmodule : nf_gpio
