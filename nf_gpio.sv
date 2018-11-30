/*
*  File            :   nf_gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is GPIO module
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

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
    output  logic   [7  : 0]    gpo,
    output  logic   [7  : 0]    gpd
);

    logic   [7 : 0]     gpio_i;
    logic   [7 : 0]     gpio_o;
    logic   [7 : 0]     gpio_d;
    logic               gpo_we;
    logic               gpd_we;

    assign gpo    = gpio_o;
    assign gpd    = gpio_d;
    assign gpio_i = gpi;
    
    assign gpo_we = we && ( addr[0 +: 4] == `NF_GPIO_GPO ); 
    assign gpd_we = we && ( addr[0 +: 4] == `NF_GPIO_DIR ); 

    always_comb
    begin
        rd = gpio_i;
        casex(addr[0 +: 4])
            `NF_GPIO_GPI :  rd = gpio_i;
            `NF_GPIO_GPO :  rd = gpio_o;
            `NF_GPIO_DIR :  rd = gpio_d;
        endcase
    end

    always_ff @(posedge clk, negedge resetn)
    begin : load_gpo
        if(!resetn)
            gpio_o <= '0;
        else
            if(gpo_we)
            gpio_o <= wd;
    end

    always_ff @(posedge clk, negedge resetn)
    begin : load_gpd
        if(!resetn)
            gpio_d <= '0;
        else
            if(gpd_we)
            gpio_d <= wd;
    end

endmodule : nf_gpio
