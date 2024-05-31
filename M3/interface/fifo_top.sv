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

	//Importing interface of signals internal to the FIFO
	Asynchronous_FIFO_bfm_int bfm_int();

    // Memory
    fifo_memory #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) mem_inst (
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .waddr(bfm_int.waddr),
        .raddr(bfm_int.raddr),
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
        .wptr(bfm_int.wptr),
        .waddr(bfm_int.waddr),
        .wq2_rptr(bfm_int.wq2_rptr),
        .full(full)
    );

    // Read Pointer and Empty Flag Logic
    read_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) read_ptr (
        .clk(clk_rd),
        .rst_n(rst_n),
        .inc(rd_en),
        .rptr(bfm_int.rptr),
        .raddr(bfm_int.raddr),
        .rq2_wptr(bfm_int.rq2_wptr),
        .empty(empty)
    );

    // Synchronization from write to read domain
    sync #(.ADDR_WIDTH(ADDR_WIDTH)) sync_w2r (
        .clk(clk_rd),
        .rst_n(rst_n),
        .data_in(bfm_int.wptr),
        .data_out(bfm_int.rq2_wptr)
    );

    // Synchronization from read to write domain
    sync #(.ADDR_WIDTH(ADDR_WIDTH)) sync_r2w (
        .clk(clk_wr),
        .rst_n(rst_n),
        .data_in(bfm_int.rptr),
        .data_out(bfm_int.wq2_rptr)
    );




endmodule      
       
       
       
       
       
       
