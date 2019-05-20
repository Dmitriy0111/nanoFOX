/*
*  File            :   nf_uart_receiver.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Description     :   This uart receiver module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_uart_receiver
(
    // reset and clock
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    resetn,     // resetn
    // controller side interface
    input   logic   [0  : 0]    rec_en,     // receiver enable
    input   logic   [15 : 0]    comp,       // compare input for setting baudrate
    output  logic   [7  : 0]    rx_data,    // received data
    output  logic   [0  : 0]    rx_valid,   // receiver data valid
    input   logic   [0  : 0]    rx_val_set, // receiver data valid set
    // uart rx side
    input   logic   [0  : 0]    uart_rx     // UART rx wire
);

    logic   [7  : 0]    int_reg;        // internal register
    logic   [3  : 0]    bit_counter;    // bit counter for internal register
    logic   [15 : 0]    counter;        // counter for baudrate
    logic   [0  : 0]    idle2rec;       // idle to receive
    logic   [0  : 0]    rec2wait;       // receive to wait
    logic   [0  : 0]    wait2idle;      // wait to idle
    enum
    logic   [1  : 0]    { IDLE_s, RECEIVE_s, WAIT_s } state, next_state; //FSM states

    assign idle2rec  = uart_rx == '0 ;
    assign rec2wait  = bit_counter == 4'h9;
    assign wait2idle = rx_val_set;
    
    assign rx_data = int_reg;
    
    // FSM state change
    always_ff @(posedge clk or negedge resetn)
        if( !resetn )
            state <= IDLE_s;
        else
        begin
            state <= next_state;
            if( !rec_en )
                state <= IDLE_s;
        end
    // Finding next state for FSM
    always_comb 
    begin : next_state_finding
        next_state = state;
        case( state )
            IDLE_s    :   if( idle2rec  )   next_state = RECEIVE_s;
            RECEIVE_s :   if( rec2wait  )   next_state = WAIT_s;
            WAIT_s    :   if( wait2idle )   next_state = IDLE_s;
            default   :                     next_state = IDLE_s;
        endcase
    end
    // Other FSM sequence logic
    always_ff @(posedge clk or negedge resetn)
    begin
        if( !resetn )
        begin
            counter  <= '0;
            int_reg  <= '0;
            rx_valid <= '0;
            bit_counter <= '0;
        end
        else
        begin
            if( rec_en )
            begin
                case( state )
                    IDLE_s :
                    begin
                        bit_counter <= '0;
                        counter <= '0;
                        rx_valid <= '0;
                    end
                    RECEIVE_s : 
                    begin
                        counter <= counter + 1'b1;
                        if( counter >= comp )
                        begin
                            counter <= '0;
                            bit_counter <= bit_counter + 1'b1;
                        end
                        if( counter == ( comp >> 1 ) )
                            int_reg <= { uart_rx , int_reg[7 : 1] };
                    end
                    WAIT_s :
                    begin
                        rx_valid <= '1;
                    end
                endcase
            end
            else
            begin
                counter <= '0;
                bit_counter <= '0;
                rx_valid <= '0;
            end
        end
    end

endmodule : nf_uart_receiver
