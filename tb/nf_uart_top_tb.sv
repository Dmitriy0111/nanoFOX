/*
*  File            :   nf_uart_top_tb.sv
*  Autor           :   Vlasov D.V. 63030
*  Data            :   2019.02.21
*  Language        :   SystemVerilog
*  Description     :   This uart top module
*  Copyright(c)    :   2018 Vlasov D.V. 63030
*/

`include "../../inc/nf_settings.svh"

module nf_uart_top_tb ();

    timeprecision   1ns;
    timeunit        1ns;

    localparam      T = 20;
    localparam      rst_delay  = 7;
    localparam      work_freq  = 50_000_000;
    localparam      uart_speed = 115200;

    // clock and reset
    bit                 clk;
    bit                 resetn;
    // bus side
    logic   [31 : 0]    addr;
    logic               we;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;
    // uart side
    logic               uart_tx;
    logic               uart_rx;

    logic [31 : 0] read_data;

    assign uart_rx = uart_tx;

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

    task write_reg( logic [31 : 0] reg_addr, logic [31 : 0] reg_data );
        addr = reg_addr;
        wd   = reg_data;
        we   = '1;
        @(posedge clk);
        we   = '0;
    endtask : write_reg

    task read_reg( logic [31 : 0] reg_addr);
        addr = reg_addr;
        @(posedge clk);
        read_data = rd;
    endtask : read_reg

    task set_bw( logic [15 : 0] bw );
        write_reg( '0 | `NF_UART_DR, '0 | bw );
    endtask : set_bw

    task write_tr( logic [7 : 0] tx_data );
        write_reg( '0 | `NF_UART_TX, '0 | tx_data );
    endtask : write_tr

    task write_cr( logic [7 : 0] control );
        write_reg( '0 | `NF_UART_CR, '0 | control );
    endtask : write_cr

    task delay( logic [31 : 0] delay_ );
        repeat(delay_) @(posedge clk);
    endtask : delay

    task send_message( string message);
        for( int i=0; i<message.len(); i++ )
        begin
            write_tr(message[i]);
            write_cr(8'h0D);
            do
                read_reg('0 | `NF_UART_CR );
            while(read_data[0]!=0);
        end
    endtask : send_message

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
        @(posedge resetn);
        set_bw( work_freq / uart_speed );
        send_message("Hello World!");
        $stop;
    end

endmodule : nf_uart_top_tb