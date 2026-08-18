// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module spi_master_tb;

    
    // Testbench Signals
    

    reg clk;
    reg rst;

    reg start;
    reg [7:0] tx_data;

    wire miso;

    wire mosi;
    wire sclk;
    wire cs;

    wire [7:0] rx_data;
    wire busy;
    wire done;


  
    // SPI DUT
    

    spi_master #(
        .CLK_DIV(2)
    ) dut (

        .clk     (clk),
        .rst     (rst),

        .start   (start),
        .tx_data (tx_data),

        .miso    (miso),

        .mosi    (mosi),
        .sclk    (sclk),
        .cs      (cs),

        .rx_data (rx_data),
        .busy    (busy),
        .done    (done)

    );


  
    // LOOPBACK
    
    //
    // Whatever is transmitted on MOSI is returned
    // on MISO.
    //


    assign miso = mosi;


  
    // CLOCK GENERATION

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


  
    // TEST SEQUENCE
    

    initial begin

        // Initialize
        rst     = 1'b1;
        start   = 1'b0;
        tx_data = 8'h00;


        // Reset
        #20;

        rst = 1'b0;

        // Wait
        #20;



        // TEST 1
    

        tx_data = 8'b10100101;

        start = 1'b1;

        #10;

        start = 1'b0;


        // Wait for transaction to complete
        wait(done == 1'b1);

        #10;


    
        // Display Result
        

        $display("--------------------------------------------");
        $display("SPI TRANSACTION 1");
        $display("TX DATA = %b", tx_data);
        $display("RX DATA = %b", rx_data);

        if (rx_data == tx_data)
            $display("TEST 1 PASSED");
        else
            $display("TEST 1 FAILED");

        $display("--------------------------------------------");


        
        // TEST 2
      

        #30;

        tx_data = 8'b11001100;

        start = 1'b1;

        #10;

        start = 1'b0;


        wait(done == 1'b1);

        #10;


        $display("--------------------------------------------");
        $display("SPI TRANSACTION 2");
        $display("TX DATA = %b", tx_data);
        $display("RX DATA = %b", rx_data);

        if (rx_data == tx_data)
            $display("TEST 2 PASSED");
        else
            $display("TEST 2 FAILED");

        $display("--------------------------------------------");


        // TEST 3


        #30;

        tx_data = 8'b11110000;

        start = 1'b1;

        #10;

        start = 1'b0;


        wait(done == 1'b1);

        #10;


        $display("--------------------------------------------");
        $display("SPI TRANSACTION 3");
        $display("TX DATA = %b", tx_data);
        $display("RX DATA = %b", rx_data);

        if (rx_data == tx_data)
            $display("TEST 3 PASSED");
        else
            $display("TEST 3 FAILED");

        $display("--------------------------------------------");


        #50;

        $finish;

    end

    // MONITOR


    initial begin

        $monitor(
            "TIME=%0t | CS=%b | SCLK=%b | MOSI=%b | MISO=%b | BUSY=%b | DONE=%b | TX=%h | RX=%h",
            $time,
            cs,
            sclk,
            mosi,
            miso,
            busy,
            done,
            tx_data,
            rx_data
        );

    end


    // WAVEFORM GENERATION
  

    initial begin

        $dumpfile("spi_master.vcd");

        $dumpvars(0, spi_master_tb);

    end

endmodule
