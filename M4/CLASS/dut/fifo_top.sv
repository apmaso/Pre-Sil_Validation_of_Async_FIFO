module fifo_top #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 6  // Log2 of FIFO depth 64
)(
    input  logic                   clk_wr, clk_rd, rst_n,
    input  logic                   wr_en, rd_en,
    input  logic [DATA_WIDTH-1:0]  data_in,
    output logic [DATA_WIDTH-1:0]  data_out,
    output logic                   full, empty, half
);

    // Internal signals for fifo_top
    logic [ADDR_WIDTH:0] wptr, rptr;
    logic [ADDR_WIDTH-1:0] waddr, raddr;
    logic [ADDR_WIDTH:0] wq2_rptr, rq2_wptr;

	// Importing interface of signals internal to the FIFO
	fifo_bfm bfm();

    // Memory
    fifo_memory #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) mem_inst (
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .waddr(waddr),
        .raddr(raddr),
        .data_in(data_in),
        .data_out(data_out),
        .wr_en(wr_en & ~full),
        .rd_en(rd_en & ~empty),
        .half(half)
    );

    // Write Pointer and Full Flag Logic
    write_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) write_ptr (
        .clk(clk_wr),
        .rst_n(rst_n),
        .inc(wr_en),
        .wptr(wptr),
        .waddr(waddr),
        .wq2_rptr(wq2_rptr),
        .full(full)
    );

    // Read Pointer and Empty Flag Logic
    read_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) read_ptr (
        .clk(clk_rd),
        .rst_n(rst_n),
        .inc(rd_en),
        .rptr(rptr),
        .raddr(raddr),
        .rq2_wptr(rq2_wptr),
        .empty(empty)
    );

    // Synchronization from write to read domain
    sync #(.ADDR_WIDTH(ADDR_WIDTH)) sync_w2r (
        .clk(clk_rd),
        .rst_n(rst_n),
        .data_in(wptr),
        .data_out(rq2_wptr)
    );

    // Synchronization from read to write domain
    sync #(.ADDR_WIDTH(ADDR_WIDTH)) sync_r2w (
        .clk(clk_wr),
        .rst_n(rst_n),
        .data_in(rptr),
        .data_out(wq2_rptr)
    );

endmodule      
       
       
       
       
       
       
