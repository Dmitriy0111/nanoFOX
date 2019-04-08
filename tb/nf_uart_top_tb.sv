/*
*  File            :   nf_uart_top_tb.sv
*  Autor           :   Vlasov D.V. 63030
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Description     :   This uart top module
*  Copyright(c)    :   2018 Vlasov D.V. 63030
*/

`include "../../inc/nf_settings.svh"

`define     tx_req      0
`define     rx_valid    1
`define     tr_en       2
`define     rec_en      3

module nf_uart_top_tb ();

    timeprecision   1ns;
    timeunit        1ns;

    localparam      T = 20;
    localparam      rst_delay  = 7;
    localparam      work_freq  = 50_000_000;
    localparam      uart_speed = 115200;

    // clock and reset
    bit     [0  : 0]    clk;        // clk
    bit     [0  : 0]    resetn;     // resetn
    // bus side
    logic   [31 : 0]    addr;       // address
    logic   [0  : 0]    we;         // write enable
    logic   [31 : 0]    wd;         // write data
    logic   [31 : 0]    rd;         // read data
    // uart side
    logic   [0  : 0]    uart_tx;    // UART tx wire
    logic   [0  : 0]    uart_rx;    // UART rx wire

    logic   [31 : 0]    read_data;

    //assign uart_rx = uart_tx;
    // creating one nf_uart_top_0 module
    nf_uart_top nf_uart_top_0
    (
        .clk        ( clk       ),      // clk
        .resetn     ( resetn    ),      // resetn
        .addr       ( addr      ),      // address
        .we         ( we        ),      // write enable
        .wd         ( wd        ),      // write data
        .rd         ( rd        ),      // read data
        .uart_tx    ( uart_tx   ),      // UART tx wire
        .uart_rx    ( uart_rx   )       // UART rx wire
    );
    // task for writing register
    task write_reg( logic [31 : 0] reg_addr, logic [31 : 0] reg_data );
        addr = reg_addr;
        wd   = reg_data;
        we   = '1;
        @(posedge clk);
        we   = '0;
    endtask : write_reg
    // task for reading register
    task read_reg( logic [31 : 0] reg_addr);
        addr = reg_addr;
        @(posedge clk);
        read_data = rd;
    endtask : read_reg
    // task for setting bandwidth
    task set_bw( logic [15 : 0] bw );
        write_reg( '0 | `NF_UART_DR, '0 | bw );
    endtask : set_bw
    // task for writing data in transmit register
    task write_tr( logic [7 : 0] tx_data );
        write_reg( '0 | `NF_UART_TX, '0 | tx_data );
    endtask : write_tr
    // task for writing data in control register
    task write_cr( logic [7 : 0] control );
        write_reg( '0 | `NF_UART_CR, '0 | control );
    endtask : write_cr
    // task for creating transaction for uart sender
    task send_message( string message );
        for( int i=0; i<message.len(); i++ )
        begin
            write_tr(message[i]);
            write_cr( ( 1'b1 << `tr_en ) | ( 1'b1 << `rec_en ) );
            do
                read_reg('0 | `NF_UART_CR );
            while(read_data[0]!=0);
        end
    endtask : send_message
    // task for sending symbol over uart to receive module
    task send_uart_symbol( logic [7 : 0] symbol );
        // generate 'start'
        uart_rx = '0;
        repeat( work_freq / uart_speed ) @(posedge clk);
        // generate transaction
        for( integer i = 0 ; i < 8 ; i ++ )
        begin
            uart_rx = symbol[i];
            repeat( work_freq / uart_speed ) @(posedge clk);
        end
        // generate 'stop'
        uart_rx = '1;
        repeat( work_freq / uart_speed ) @(posedge clk);
    endtask : send_uart_symbol
    // task for sending message over uart to receive module
    task send_uart_message( string message );
        for( int i=0; i<message.len(); i++ )
            send_uart_symbol(message[i]);
    endtask : send_uart_message

    // clock generation
    initial
    begin
        $display("Clock generation start!");
        forever #( T / 2 ) clk = ~ clk;
    end
    // reset generation
    initial
    begin
        $display("Reset is in active state!");
        repeat(rst_delay) @(posedge clk);
        resetn = '1;
        $display("Reset is in inactive state!");
    end
    // other logic
    initial
    begin
        addr = '0;
        we   = '0;
        wd   = '0;
        uart_rx = '1;
        @(posedge resetn);
        set_bw( work_freq / uart_speed );
        write_cr( ( 1'b1 << `tr_en ) | ( 1'b1 << `rec_en ) );
        send_uart_message("Hello World!");
        //send_message("Hello World!");
        $stop;
    end

endmodule : nf_uart_top_tb