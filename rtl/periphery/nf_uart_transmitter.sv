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
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    resetn,     // resetn
    // controller side interface
    input   logic   [0  : 0]    tr_en,      // transmitter enable
    input   logic   [15 : 0]    comp,       // compare input for setting baudrate
    input   logic   [7  : 0]    tx_data,    // data for transfer
    input   logic   [0  : 0]    req,        // request signal
    output  logic   [0  : 0]    req_ack,    // acknowledgent signal
    // uart tx side
    output  logic   [0  : 0]    uart_tx     // UART tx wire
);

    logic   [7  : 0]    int_reg;        // internal register
    logic   [3  : 0]    bit_counter;    // bit counter for internal register
    logic   [15 : 0]    counter;        // counter for baudrate
    logic               idle2start;     // idle to start
    logic               start2tr;       // start to transmit
    logic               tr2stop;        // transmit to stop
    logic               stop2wait;      // stop to wait
    logic               wait2idle;      // wait to idle

    assign idle2start = req;
    assign start2tr   = counter >= comp;
    assign tr2stop    = bit_counter == 4'h8;
    assign stop2wait  = counter >= comp;
    assign wait2idle  = req_ack;
    
    enum logic [2 : 0] { IDLE_s, START_s, TRANSMIT_s, STOP_s, WAIT_s} state, next_state; //FSM states
    
    //FSM state change
    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            state <= IDLE_s;
        else
        begin
            state <= next_state;
            if( !tr_en )
                state <= IDLE_s;
        end
            
    //Finding next state for FSM
    always_comb 
    begin : next_state_finding
        next_state = state;
        case( state )
            IDLE_s      :   if( idle2start  )   next_state = START_s;
            START_s     :   if( start2tr    )   next_state = TRANSMIT_s;
            TRANSMIT_s  :   if( tr2stop     )   next_state = STOP_s;
            STOP_s      :   if( stop2wait   )   next_state = WAIT_s;
            WAIT_s      :   if( wait2idle   )   next_state = IDLE_s;
            default     :                       next_state = IDLE_s;
        endcase
    end

    //Other FSM sequence logic
    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
        begin
            bit_counter <= '0;
            int_reg <= '1;
            uart_tx <= '1;
            req_ack <= '0;
        end
        else
        begin
            case( state )
                IDLE_s      : 
                        begin
                            uart_tx <= '1;
                            req_ack <= '0;
                            if( idle2start )
                            begin
                                bit_counter <= '0;
                                counter <= '0;
                                int_reg <= tx_data;
                            end
                        end
                START_s     : 
                        begin
                            uart_tx <= '0;
                            counter <= counter + 1'b1;
                            if( counter >= comp )
                            begin
                                counter <= '0;
                            end
                        end
                TRANSMIT_s  : 
                        begin
                            uart_tx <= int_reg[ bit_counter[2 : 0] ];
                            counter <= counter + 1'b1;
                            if( counter >= comp )
                            begin
                                counter <= '0;
                                bit_counter <= bit_counter + 1'b1;
                            end
                            if( bit_counter == 4'h8 )
                            begin
                                bit_counter <= '0;
                                uart_tx <= '1;
                            end
                        end
                STOP_s      : 
                        begin
                            counter <= counter + 1'b1;
                            if( counter >= comp )
                            begin
                                counter <= '0;
                                req_ack <= '1;
                            end
                        end
                WAIT_s      :
                        begin

                        end
            endcase
            if( !tr_en )
            begin
                bit_counter <= '0;
                int_reg <= '1;
                uart_tx <= '1;
            end
        end
    end

endmodule : nf_uart_transmitter
