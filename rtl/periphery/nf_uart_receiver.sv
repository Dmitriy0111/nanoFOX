/*
*  File            :   nf_uart_receiver.sv
*  Autor           :   Vlasov D.V. 63030
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Company         :   ISS
*  Description     :   This uart receiver module
*  Copyright(c)    :   2018 Vlasov D.V. 63030
*/

module nf_uart_receiver
(
    //reset and clock
    input   logic               clk,
    input   logic               resetn,
    //controller side interface
    input   logic               rec_en,      // receiver enable
    input   logic   [15 : 0]    comp,
    output  logic   [7  : 0]    rx_data,
    output  logic               rx_valid,
    //uart side
    input   logic               uart_rx
);

    logic   [7  : 0]    int_reg; //internal register
    logic   [15 : 0]    counter;
    logic   [3  : 0]    bit_counter;
    
    assign rx_data = int_reg;
    
    enum logic [1 : 0] { WAIT_s, RECEIVE_s } state, next_state; //FSM states
    
    //FSM state change
    always_ff @(posedge clk or negedge resetn)
        if( !resetn )
            state <= WAIT_s;
        else
        begin
            state <= next_state;
            if( !rec_en )
                state <= WAIT_s;
        end
            
    //Finding next state for FSM
    always_comb 
    begin : next_state_finding
        next_state = state;
        case( state )
            WAIT_s      :   if( uart_rx == '0 )         next_state = RECEIVE_s;
            RECEIVE_s   :   if( bit_counter == 4'h9 )   next_state = WAIT_s;
            default     :                               next_state = WAIT_s;
        endcase
    end
    //Other FSM sequence logic
    always_ff @(posedge clk or negedge resetn)
    begin
        if( !resetn )
        begin
            counter <= '0;
            bit_counter <= '0;
            rx_valid <= '0;
        end
        else
        begin
            if( rec_en )
                case( state )
                    WAIT_s :
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
                                int_reg <= {uart_rx,int_reg[7:1]};
                            if( bit_counter == 4'h9 )
                                rx_valid <= '1;
                        end
                endcase
            else
            begin
                counter <= '0;
                bit_counter <= '0;
                rx_valid <= '0;
            end
        end
    end

endmodule : nf_uart_receiver
