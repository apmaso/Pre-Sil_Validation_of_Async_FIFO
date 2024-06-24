/*
Write Pointer Module
Parameterized by ADDR_WIDTH

This write pointer module manages the write address and pointer, converting between 
binary and Gray code for synchronization with the read clock domain. It determines 
if the FIFO is full by comparing the write pointer with the synchronized read pointer.
*/

module write_pointer #(
    parameter ADDR_WIDTH = 6                  // Address width parameter
)(
    input  logic                    clk,      // Clock signal
    input  logic                    rst_n,    // Active low reset signal
    input  logic                    inc,      // Increment signal
    input  logic [ADDR_WIDTH:0]     wq2_rptr, // Synchronized read pointer from read clock domain
    output logic [ADDR_WIDTH:0]     wptr,     // Write pointer in Gray code
    output logic [ADDR_WIDTH-1:0]   waddr,    // Write address in binary
    output logic                    full      // FIFO full flag
);

    // Internal signals
    logic [ADDR_WIDTH:0] binary_wptr;          // Binary write pointer
    logic [ADDR_WIDTH:0] binary_wptr_next;     // Next binary write pointer
    logic [ADDR_WIDTH:0] gray_wptr_next;       // Next Gray code write pointer
    logic full_next;                           // Next full flag value

    // Sequential logic for updating pointers and full flag
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset
            wptr <= 0;
            binary_wptr <= 0;
            full <= 0;
        end else begin
            // Update pointers and full flag on positive clock edge
            wptr <= gray_wptr_next;
            binary_wptr <= binary_wptr_next;
            full <= full_next;
        end
    end

    // Combinational logic for calculating next states
    assign waddr = binary_wptr[ADDR_WIDTH-1:0]; 						// Write address is the lower bits of the binary write pointer
    assign binary_wptr_next = binary_wptr + (inc & ~full); 			    // Increment binary write pointer if increment signal is high and FIFO is not full
    assign gray_wptr_next = (binary_wptr_next >> 1) ^ binary_wptr_next; // Convert binary pointer to Gray code

    // Full flag logic
	// FIFO is full when the next Gray code write pointer matches the synchronized read pointer except for the most significant bits
    assign full_next =  ((gray_wptr_next[ADDR_WIDTH-2:0] == wq2_rptr[ADDR_WIDTH-2:0]) &&
                         (gray_wptr_next[ADDR_WIDTH-1:0] != wq2_rptr[ADDR_WIDTH-1:0]) && 
                         (gray_wptr_next[ADDR_WIDTH] != wq2_rptr[ADDR_WIDTH]));

endmodule
