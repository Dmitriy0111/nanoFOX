/*
*  File            :   nf_cdc.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.22
*  Language        :   SystemVerilog
*  Description     :   This is cross domain crossing module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_cdc
#(
    parameter                       width = 8
)(
    input   logic   [0       : 0]   resetn_1,
    input   logic   [0       : 0]   resetn_2,
    input   logic   [0       : 0]   clk_1,
    input   logic   [0       : 0]   clk_2,
    input   logic   [0       : 0]   we_1,
    input   logic   [0       : 0]   we_2,
    input   logic   [width-1 : 0]   data_1_in,
    input   logic   [width-1 : 0]   data_2_in,
    output  logic   [width-1 : 0]   data_1_out,
    output  logic   [width-1 : 0]   data_2_out,
    output  logic   [0       : 0]   wait_1,
    output  logic   [0       : 0]   wait_2
);

    logic   [7 : 0]     int_reg1;
    logic   [7 : 0]     int_reg2;
    logic   [0 : 0]     req_1;
    logic   [0 : 0]     ack_1;
    logic   [0 : 0]     req_2;
    logic   [0 : 0]     ack_2;

    assign wait_1 = req_1 || ack_2;
    assign wait_2 = req_2 || ack_1;

    assign data_1_out = int_reg1;
    assign data_2_out = int_reg2;

    always_ff @(posedge clk_1) 
    begin : write2first_reg
        if( !resetn_1 )
            int_reg1 <= '0;
        else
        begin
            if( we_1 )
                int_reg1 <= data_1_in;
            else if( req_2 )
                int_reg1 <= data_2_in;
        end
    end

    always_ff @(posedge clk_1) 
    begin : answer_first
        if( !resetn_1 )
            ack_1 <= '0;
        else 
            ack_1 <= req_2;
    end

    always_ff @(posedge clk_1) 
    begin : request_first
        if( !resetn_1 )
            req_1 <= '0;
        else 
        begin
            if( we_1 )
                req_1 <= '1;
            if( ack_2 == '1 )
                req_1 <= '0;
        end
    end

    always_ff @(posedge clk_2) 
    begin : write2second_reg
        if( !resetn_2 )
            int_reg2 <= '0;
        begin
            if( we_2 )
                int_reg2 <= data_2_in;
            if( req_1 )
                int_reg2 <= data_1_in;
        end
    end

    always_ff @(posedge clk_2) 
    begin : answer_second
        if( !resetn_2 )
            ack_2 <= '0;
        else 
            ack_2 <= req_1;
    end

    always_ff @(posedge clk_2) 
    begin : request_second
        if( !resetn_2 )
            req_2 <= '0;
        else 
        begin
            if( we_2 )
                req_2 <= '1;
            if( ack_1 == '1 )
                req_2 <= '0;
        end
    end

endmodule : nf_cdc
