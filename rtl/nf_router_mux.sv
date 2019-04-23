/*
*  File            :   nf_router_mux.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is mux unit for routing lw sw command's
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_router_mux
#(
    parameter                                   Slave_n = `SLAVE_NUMBER
)(
    input   logic   [Slave_n-1 : 0]             slave_sel,  // slave select
    input   logic   [Slave_n-1 : 0][31 : 0]     rd_s,       // read data array slave
    output  logic                  [31 : 0]     rd_m        // read data master
);  
    // selecting read data input
    always_comb
    begin
        rd_m = rd_s[0];
        casez( slave_sel )
            'b???1  : rd_m = rd_s[0];
            'b??10  : rd_m = rd_s[1];
            'b?100  : rd_m = rd_s[2];
            'b1000  : rd_m = rd_s[2];
        endcase
    end

endmodule : nf_router_mux
