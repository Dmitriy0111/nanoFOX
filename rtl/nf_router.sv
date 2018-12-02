/*
*  File            :   nf_router.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is unit for routing lw sw command's
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_router
#(
    parameter                                   Slave_n = `slave_number
)(
    input   logic                               clk,
    input   logic                               resetn, 
    //cpu side (master)
    input   logic   [31 : 0]                    addr_dm_m,
    input   logic                               we_dm_m,
    input   logic   [31 : 0]                    wd_dm_m,
    output  logic   [31 : 0]                    rd_dm_m,
    //devices side (slave's)
    output  logic                               clk_s,
    output  logic                               resetn_s,
    output  logic   [31 : 0]                    addr_dm_s,
    output  logic   [Slave_n-1 : 0]             we_dm_s,
    output  logic   [31 : 0]                    wd_dm_s,
    input   logic   [Slave_n-1 : 0][31 : 0]     rd_dm_s
);

    logic   [Slave_n-1 : 0]     slave_sel;

    assign clk_s     = clk;
    assign resetn_s  = resetn;
    assign wd_dm_s   = wd_dm_m;
    assign addr_dm_s = addr_dm_m;
    assign we_dm_s   = { `slave_number { we_dm_m } } & slave_sel ;

    nf_router_dec
    #(
        .Slave_n        ( `slave_number     )
    )
    nf_router_dec_0
    (
        .addr_m         ( addr_dm_m         ),
        .slave_sel      ( slave_sel         )
    );

    nf_router_mux
    #(
        .Slave_n        ( `slave_number     )
    )
    nf_router_mux_0
    (
        .slave_sel      ( slave_sel         ),
        .rd_s           ( rd_dm_s           ),
        .rd_m           ( rd_dm_m           )
    );  

endmodule : nf_router
