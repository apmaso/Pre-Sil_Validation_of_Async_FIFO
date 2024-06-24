/*
Synchronization Module
Parameterized by ADDR_WIDTH

This synchronization module safely transfers multi-bit data between different 
clock domains using double-flop synchronization. It reduces the risk of metastability 
and ensures reliable data transfer by buffering the data before outputting it.
*/

module sync #(
    parameter ADDR_WIDTH = 6                // Address width parameter
)(
    input  logic                  clk,      // Clock signal
    input  logic                  rst_n,    // Active low reset signal
    input  logic [ADDR_WIDTH:0]   data_in,  // Data input to be synchronized
    output logic [ADDR_WIDTH:0]   data_out  // Synchronized data output
);

    // Internal buffer for synchronization
    logic [ADDR_WIDTH:0] buffer;

    // Sequential logic for synchronization
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset: clear buffer and data output
            data_out <= 0;
            buffer <= 0;
        end else begin
            // Synchronize data on positive clock edge
            buffer <= data_in;              // Capture input data in buffer
            data_out <= buffer;             // Update output data with buffer value
        end
    end

endmodule