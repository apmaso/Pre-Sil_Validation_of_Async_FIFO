module read_pointer #(
    parameter ADDR_WIDTH = 6
)(
    input  logic                    clk, rst_n, inc,
    input  logic [ADDR_WIDTH:0]     rq2_wptr,
    output logic [ADDR_WIDTH:0]     rptr, 
    output logic [ADDR_WIDTH-1:0]   raddr,
    output logic                    empty
);

    logic [ADDR_WIDTH:0]    gray_rptr_next;
    logic [ADDR_WIDTH:0]    binary_rptr, binary_rptr_next;
    logic                   empty_next;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rptr <= 0;
            binary_rptr <= 0;
            empty <= 1;
        end
        else begin
            rptr <= gray_rptr_next;
            binary_rptr <= binary_rptr_next;
            empty <= empty_next;
        end
    end

    assign empty_next = (gray_rptr_next == rq2_wptr);
    assign gray_rptr_next = (binary_rptr_next >> 1) ^ binary_rptr_next;
    assign binary_rptr_next = binary_rptr + (inc & ~empty);
    assign raddr = binary_rptr[ADDR_WIDTH-1:0];

endmodule
