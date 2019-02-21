/*
*  File            :   nf_uart_transmitter.sv
*  Autor           :   Vlasov D.V. 63030
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Description     :   This uart transmitter module
*  Copyright(c)    :   2018 Vlasov D.V. 63030
*/

module nf_uart_transmitter
(
    // reset and clock
    input   logic               clk,        // clk
    input   logic               resetn,     // resetn
    // controller interface
    input   logic               en,         // strobing input
    input   logic               tr_en,      // transmitter enable
    input   logic   [7 : 0]     tx_data,    // data for transfer
    input   logic               req,        // request signal
    output  logic               req_ack,    // acknowledgent signal
    // uart tx side
    output  logic               uart_tx     // UART tx wire
);

    logic   [7 : 0]     int_reg;  //internal register
    logic   [3 : 0]     counter;
    logic               tr2wait;

    assign tr2wait = counter == 4'h8;
    
    enum logic [1 : 0] { WAIT_s, START_s, TRANSMIT_s, STOP_s } state, next_state; //FSM states
    
    //FSM state change
    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            state <= WAIT_s;
        else
            if( en || state == WAIT_s )
                state <= next_state;
            else if( !tr_en )
                state <= WAIT_s;
            
    //Finding next state for FSM
    always_comb 
    begin
        next_state = state;
        case( state )
            WAIT_s      :   if( req )       next_state = START_s;
            START_s     :                   next_state = TRANSMIT_s;
            TRANSMIT_s  :   if( tr2wait )   next_state = STOP_s;
            STOP_s      :                   next_state = WAIT_s;
            default     :                   next_state = WAIT_s;
        endcase

    end

    //Other FSM sequence logic
    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
        begin
            counter <= '0;
            int_reg <= '1;
            uart_tx <= '1;
        end
        else
        begin
            req_ack <= '0;
            if( en && tr_en )
                case( state )
                    WAIT_s      : 
                            begin
                                uart_tx <= '1;
                            end
                    START_s     : 
                            begin
                                int_reg <= tx_data;
                                uart_tx <= '0;
                                counter <= '0;
                            end
                    TRANSMIT_s  : 
                            begin
                                uart_tx <= int_reg[ counter[2 : 0] ];
                                counter <= counter + 1'b1;
                                if( counter == 4'h8 )
                                begin
                                    counter <= '0;
                                    uart_tx <= '1;
                                    
                                end
                            end
                    STOP_s      : 
                            begin
                                req_ack <= '1;
                            end
                endcase
            else
            begin
                counter <= '0;
                int_reg <= '1;
                uart_tx <= '1;
            end
        end
    end

endmodule : nf_uart_transmitter
