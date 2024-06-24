/*
Read Pointer Module
Parameterized by ADDR_WIDTH

This read pointer module manages the read address and pointer, converting between binary and Gray 
code to facilitate synchronization with the write clock domain. It determines if the FIFO is empty 
by comparing the read pointer with the synchronized write pointer.
*/

module read_pointer #(
    parameter ADDR_WIDTH = 6  								                // Address width parameter
)(
    input  logic                    clk,                                    // Clock signal
    input  logic                    rst_n,                                  // Active low reset signal
    input  logic                    inc,                                    // Increment signal
    input  logic [ADDR_WIDTH:0]     rq2_wptr,                               // Synchronized write pointer from write clock domain
    output logic [ADDR_WIDTH:0]     rptr,                                   // Read pointer in Gray code
    output logic [ADDR_WIDTH-1:0]   raddr,                                  // Read address in binary
    output logic                    empty                                   // FIFO empty flag
);

    // Internal signals
    logic [ADDR_WIDTH:0] gray_rptr_next;  								    // Next Gray code read pointer
    logic [ADDR_WIDTH:0] binary_rptr, binary_rptr_next;  	                // Binary read pointer and its next value
    logic empty_next;  														// Next empty flag value

    // Sequential logic for updating pointers and empty flag
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset
            rptr <= 0;
            binary_rptr <= 0;
            empty <= 1;
        end else begin
            // Update pointers and empty flag on positive clock edge
            rptr <= gray_rptr_next;
            binary_rptr <= binary_rptr_next;
            empty <= empty_next;
        end
    end

    // Combinational logic for calculating next states
    assign empty_next = (gray_rptr_next == rq2_wptr);  						// FIFO is empty when read and synchronized write pointers are equal
    assign gray_rptr_next = (binary_rptr_next >> 1) ^ binary_rptr_next;  	// Convert binary pointer to Gray code
    assign binary_rptr_next = binary_rptr + (inc & ~empty);  				// Increment binary pointer if increment signal is high and FIFO is not empty
    assign raddr = binary_rptr[ADDR_WIDTH-1:0];  							// Read address is the lower bits of the binary read pointer

endmodule