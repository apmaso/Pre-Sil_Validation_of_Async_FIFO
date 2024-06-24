/*
FIFO Memory Module
Parameterized by DATA_WIDTH and ADDR_WIDTH

This FIFO memory module stores data in a dual-port memory array, allowing simultaneous read and write 
operations from different clock domains. It handles write operations based on the write enable signal 
and read operations on the read enable signal.
*/

module fifo_memory #(
    parameter DATA_WIDTH = 8,                       // Width of data stored in the FIFO
    parameter ADDR_WIDTH = 6                        // Width of the address bus
)(
    input  logic                      clk_wr, 	    // Write clock
    input  logic                      clk_rd, 	    // Read clock
    input  logic                      wr_en,  	    // Write enable signal
    input  logic                      rd_en,  	    // Read enable signal
    input  logic  [ADDR_WIDTH-1:0]    waddr,  	    // Write address
    input  logic  [ADDR_WIDTH-1:0]    raddr,  	    // Read address
    input  logic  [DATA_WIDTH-1:0]    data_in, 	    // Data input to be written to the FIFO
    output logic  [DATA_WIDTH-1:0]    data_out,     // Data output read from the FIFO
    output logic                      half  		// Half-full/half-empty flag
);
    
    // Memory array declaration
    logic [DATA_WIDTH-1:0] mem[2**ADDR_WIDTH-1:0];

    // Write operation
    always_ff @(posedge clk_wr) begin
        if (wr_en) mem[waddr] <= data_in; 		    // Write data to memory at write address on positive edge of write clock
    end

    // Read operation
    always_ff @(posedge clk_rd) begin
        if (rd_en) data_out <= mem[raddr]; 		    // Read data from memory at read address on positive edge of read clock
    end

    // Half-full/Half-empty logic
    // 1 left shifted by ADDR_WIDTH-1 is always half of the FIFO's depth 
    assign half = (raddr-waddr==(1<<(ADDR_WIDTH-1)))||(waddr-raddr==(1<<(ADDR_WIDTH-1))) ? 1'b1 : 1'b0;

endmodule