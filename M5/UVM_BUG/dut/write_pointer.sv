module write_pointer #(
    parameter ADDR_WIDTH = 6
)(
    input  logic                    clk, rst_n, inc,
    input  logic [ADDR_WIDTH:0]     wq2_rptr,
   //output logic [ADDR_WIDTH:0]     wptr,
    
    // INJECTING BUG: Write pointr is too small
    output logic [1:0]     wptr,
    output logic [ADDR_WIDTH-1:0]   waddr,
    output logic                    full
);

    logic   [ADDR_WIDTH:0]  binary_wptr;
    logic   [ADDR_WIDTH:0]  binary_wptr_next, gray_wptr_next;
    logic                   full_next;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 0;
            binary_wptr <= 0;
            full <= 0;
        end
        else begin 
            wptr <= gray_wptr_next;
            binary_wptr <= binary_wptr_next;
            full <= full_next;
        end
    end

    assign waddr = binary_wptr[ADDR_WIDTH-1:0];
    assign binary_wptr_next = binary_wptr + (inc & ~full); //proper line of code
    assign gray_wptr_next = (binary_wptr_next>>1) ^ binary_wptr_next;

    assign full_next =  ((gray_wptr_next[ADDR_WIDTH-2:0] == wq2_rptr[ADDR_WIDTH-2:0]) &&
                        (gray_wptr_next[ADDR_WIDTH-1:0] != wq2_rptr[ADDR_WIDTH-1:0]) && 
                        (gray_wptr_next[ADDR_WIDTH] != wq2_rptr[ADDR_WIDTH]));

    
endmodule

