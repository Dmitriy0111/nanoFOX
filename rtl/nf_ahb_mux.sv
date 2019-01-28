/*
*  File            :   nf_ahb_mux.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.01.28
*  Language        :   SystemVerilog
*  Description     :   This is AHB multiplexor module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_ahb_mux
#(
    parameter                                   slave_c = 4
)(
    input   logic   [slave_c-1  : 0]            hsel_ff,
    input   logic   [slave_c-1  : 0][31 : 0]    rdata,
    input   logic   [slave_c-1  : 0]            resp,
    input   logic   [slave_c-1  : 0]            hreadyout,
    output  logic   [31         : 0]            hrdata,
    output  logic                               hresp,
    output  logic                               hready
);

    always_comb
        casex( hsel_ff )
            4'b???1 : begin hrdata = rdata[0]; hresp = resp[0]; hready = hreadyout[0];  end
            4'b??10 : begin hrdata = rdata[0]; hresp = resp[0]; hready = hreadyout[0];  end
            4'b?100 : begin hrdata = rdata[1]; hresp = resp[1]; hready = hreadyout[1];  end
            4'b1000 : begin hrdata = rdata[2]; hresp = resp[2]; hready = hreadyout[2];  end
            default : begin hrdata = 32'b0   ; hresp = 1'b1   ; hready = 1'b1        ;  end 
        endcase

endmodule : nf_ahb_mux
