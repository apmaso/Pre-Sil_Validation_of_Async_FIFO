/*********************************************
//	Interface for the Asynchronous FIFO
//	Contains external signals for the FIFO 
//	and internal signals for the BFM. Also
//	contains a reset_fifo task to reset the 
//	FIFO and generate both the write and read 
// 	clocks for our two domains
//
//	Author: Alexander Maso
//	 
*********************************************/

interface fifo_bfm;
	import fifo_pkg::*;

	//External FIFO signals
	logic clk_wr, clk_rd, rst_n;
	logic wr_en, rd_en;
	logic [DATA_WIDTH-1:0] data_in, data_out;
	logic full, empty, half;
	
	//Internal FIFO signals
	/*
	logic [ADDR_WIDTH:0] wptr;
	logic [ADDR_WIDTH:0] rptr;
	logic [ADDR_WIDTH-1:0] waddr;
	logic [ADDR_WIDTH-1:0] raddr;
	logic [ADDR_WIDTH:0] wq2_rptr;
	logic [ADDR_WIDTH:0] rq2_wptr;
	*/

	// Clock Generation for Write and Read domains
	initial begin
		clk_wr = 1'b0;
		clk_rd = 1'b0;
		forever begin
			#(CYCLE_TIME_WR/2) clk_wr = ~clk_wr;
	 		#(CYCLE_TIME_RD/2) clk_rd = ~clk_rd;
		end
	end

	// Reset uses the slower, read clock
	task reset_fifo();
	    @(negedge clk_rd);
	    rst_n = 1'b0;
	    @(negedge clk_rd);
	    wr_en = 1'b0;
	    rd_en = 1'b0;
	    @(posedge clk_rd);
	    rst_n = 1'b1;
	endtask : reset_fifo

endinterface


