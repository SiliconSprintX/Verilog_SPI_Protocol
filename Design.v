`timescale 1ns/1ps

module spi_master #(
    parameter CLK_DIV = 2
)(
    input  wire       clk,
    input  wire       rst,

    input  wire       start,
    input  wire [7:0] tx_data,

    input  wire       miso,

    output reg        mosi,
    output reg        sclk,
    output reg        cs,

    output reg [7:0]  rx_data,
    output reg        busy,
    output reg        done
);

    //====================================================
    // Internal Registers
    //====================================================

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    reg [3:0] bit_count;

    reg [15:0] clk_count;
  
    // SPI Master
    //
    // SPI Mode 0:
    // CPOL = 0
    // CPHA = 0
    //
    // Data changes on falling edge
    // Data is sampled on rising edge
    //
    

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            tx_shift  <= 8'd0;
            rx_shift  <= 8'd0;

            bit_count <= 4'd0;
            clk_count <= 16'd0;

            mosi      <= 1'b0;
            sclk      <= 1'b0;
            cs        <= 1'b1;

            rx_data   <= 8'd0;

            busy      <= 1'b0;
            done      <= 1'b0;

        end

        else begin

            // done is normally LOW
            done <= 1'b0;


  
            // IDLE STATE
            

            if (!busy) begin

                sclk      <= 1'b0;
                cs        <= 1'b1;
                clk_count <= 16'd0;

                if (start) begin

                    // Start SPI transaction
                    busy <= 1'b1;
                    cs   <= 1'b0;

                    // Load transmit data
                    tx_shift <= tx_data;

                    // Clear receive register
                    rx_shift <= 8'd0;

                    // Start from first bit
                    bit_count <= 4'd0;

                    // SPI Mode 0:
                    // First bit must already be available
                    // before first rising edge
                    mosi <= tx_data[7];

                end

            end


    
            // SPI TRANSACTION
    

            else begin

                // Clock divider
                if (clk_count == CLK_DIV - 1) begin

                    clk_count <= 16'd0;


                  
                    // SCLK LOW -> HIGH
                  
                    //
                    // Rising edge:
                    // Sample MISO
                  

                    if (sclk == 1'b0) begin

                        sclk <= 1'b1;

                        // Sample incoming data
                        rx_shift <= {
                            rx_shift[6:0],
                            miso
                        };

                    end


                  
                    // SCLK HIGH -> LOW
              
                    //
                    // Falling edge:
                    // Change MOSI
                    //
            

                    else begin

                        sclk <= 1'b0;


                        // Check whether 8 bits are complete
                        if (bit_count == 4'd7) begin

                            // Transaction complete
                            busy <= 1'b0;
                            done <= 1'b1;

                            cs   <= 1'b1;
                            mosi <= 1'b0;

                            // rx_shift already contains
                            // all 8 received bits
                            rx_data <= rx_shift;

                        end

                        else begin

                            // Move to next bit
                            bit_count <= bit_count + 1'b1;

                            // Shift transmit register
                            tx_shift <= {
                                tx_shift[6:0],
                                1'b0
                            };

                            // Output next MSB
                            mosi <= tx_shift[6];

                        end

                    end

                end

                else begin

                    clk_count <= clk_count + 1'b1;

                end

            end

        end

    end

endmodule
