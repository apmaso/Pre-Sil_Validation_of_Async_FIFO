/*
Top-Level FIFO Module
Parameterized by DATA_WIDTH and ADDR_WIDTH

This top-level FIFO module integrates all the FIFO components, including memory, 
write pointer, read pointer, and synchronization logic. It manages data flow 
between asynchronous clock domains ao that there are correct operation through full, 
empty, and half-full flags.
*/


module fifo_top #(
    parameter DATA_WIDTH = 8,  				    // Width of data stored in the FIFO
    parameter ADDR_WIDTH = 6   				    // Log2 of FIFO depth, e.g., 64 entries
)(
    input  logic                   clk_wr,      // Write clock
    input  logic                   clk_rd,      // Read clock
    input  logic                   rst_n,       // Active low reset
    input  logic                   wr_en,       // Write enable signal
    input  logic                   rd_en,       // Read enable signal
    input  logic [DATA_WIDTH-1:0]  data_in,     // Data input to be written to the FIFO
    output logic [DATA_WIDTH-1:0]  data_out,    // Data output read from the FIFO
    output logic                   full,        // Full flag
    output logic                   empty,       // Empty flag
    output logic                   half         // Half-full/half-empty flag
);

    // Internal signals for fifo_top
    logic [ADDR_WIDTH:0] wptr, rptr;         	// Write and read pointers (ADDR_WIDTH+1 bits)
    logic [ADDR_WIDTH-1:0] waddr, raddr;     	// Write and read addresses (ADDR_WIDTH bits)
    logic [ADDR_WIDTH:0] wq2_rptr, rq2_wptr; 	// Synchronized pointers between clock domains

    // Importing interface of signals internal to the FIFO
    fifo_bfm bfm();

    // Instantiate FIFO Memory Module
    fifo_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem_inst (
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .waddr(waddr),
        .raddr(raddr),
        .data_in(data_in),
        .data_out(data_out),
        .wr_en(wr_en & ~full),                  // Write enable only if FIFO is not full
        .rd_en(rd_en & ~empty),                 // Read enable only if FIFO is not empty
        .half(half)
    );

    // Instantiate Write Pointer and Full Flag Logic
    write_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) write_ptr (
        .clk(clk_wr),
        .rst_n(rst_n),
        .inc(wr_en),                            // Increment write pointer on write enable
        .wptr(wptr),                            // Write pointer
        .waddr(waddr),                          // Write address
        .wq2_rptr(wq2_rptr),                    // Synchronized read pointer in write domain
        .full(full)                             // Full flag output
    );

    // Instantiate Read Pointer and Empty Flag Logic
    read_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) read_ptr (
        .clk(clk_rd),
        .rst_n(rst_n),
        .inc(rd_en),                            // Increment read pointer on read enable
        .rptr(rptr),                            // Read pointer
        .raddr(raddr),                          // Read address
        .rq2_wptr(rq2_wptr),                    // Synchronized write pointer in read domain
        .empty(empty)                           // Empty flag output
    );

    // Synchronization from write to read domain
    sync #(.ADDR_WIDTH(ADDR_WIDTH)) sync_w2r (
        .clk(clk_rd),                           // Clock for synchronization (read clock)
        .rst_n(rst_n),                          // Active low reset
        .data_in(wptr),                         // Write pointer to be synchronized
        .data_out(rq2_wptr)                     // Synchronized write pointer output
    );

    // Synchronization from read to write domain
    sync #(.ADDR_WIDTH(ADDR_WIDTH)) sync_r2w (
        .clk(clk_wr),                           // Clock for synchronization (write clock)
        .rst_n(rst_n),                          // Active low reset
        .data_in(rptr),                         // Read pointer to be synchronized
        .data_out(wq2_rptr)                     // Synchronized read pointer output
    );

endmodule