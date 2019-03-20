/*
*  File            :   nf_gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is GPIO module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_gpio
#(
    parameter                       gpio_w = `NF_GPIO_WIDTH
)(
    // clock and reset
    input   logic                   clk,    // clock
    input   logic                   resetn, // reset
    //nf_router side
    input   logic   [31        : 0] addr,   // address
    input   logic   [0         : 0] we,     // write enable
    input   logic   [31        : 0] wd,     // write data
    output  logic   [31        : 0] rd,     // read data
    //gpio_side
    input   logic   [gpio_w-1  : 0] gpi,    // GPIO input
    output  logic   [gpio_w-1  : 0] gpo,    // GPIO output
    output  logic   [gpio_w-1  : 0] gpd     // GPIO direction
);
    // gpio input
    logic   [gpio_w-1 : 0]  gpio_i;
    // gpio output
    logic   [gpio_w-1 : 0]  gpio_o;
    // gpio direction
    logic   [gpio_w-1 : 0]  gpio_d;
    // write enable signals 
    logic                   gpo_we;
    logic                   gpd_we;
    // assign inputs/outputs
    assign gpo    = gpio_o;
    assign gpd    = gpio_d;
    assign gpio_i = gpi;
    // assign write enable signal's
    assign gpo_we = we && ( addr[0 +: 4] == `NF_GPIO_GPO ); 
    assign gpd_we = we && ( addr[0 +: 4] == `NF_GPIO_DIR ); 
    // mux for routing one register value
    always_comb
    begin
        rd = gpio_i;
        casex( addr[0 +: 4] )
            `NF_GPIO_GPI :  rd = gpio_i;
            `NF_GPIO_GPO :  rd = gpio_o;
            `NF_GPIO_DIR :  rd = gpio_d;
        endcase
    end

    always_ff @(posedge clk, negedge resetn)
    begin : load_gpo
        if( !resetn )
            gpio_o <= '0;
        else
            if( gpo_we )
                gpio_o <= wd;
    end

    always_ff @(posedge clk, negedge resetn)
    begin : load_gpd
        if( !resetn )
            gpio_d <= '0;
        else
            if( gpd_we )
                gpio_d <= wd;
    end

endmodule : nf_gpio
