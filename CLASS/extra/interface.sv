/*
Interface for the Asynchronous FIFO
*/

interface Asynchronous_FIFO_bfm_ext #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 6);

//External FIFO signals
logic clk_wr; 
logic clk_rd; 
logic rst_n;
logic wr_en;
logic rd_en;
logic [DATA_WIDTH-1:0] data_in;
logic [DATA_WIDTH-1:0] data_out;
logic full;
logic empty;
logic half;

endinterface



interface Asynchronous_FIFO_bfm_int #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 6);

//Internal FIFO signals
logic [ADDR_WIDTH:0] wptr;
logic [ADDR_WIDTH:0] rptr;
logic [ADDR_WIDTH-1:0] waddr;
logic [ADDR_WIDTH-1:0] raddr;
logic [ADDR_WIDTH:0] wq2_rptr;
logic [ADDR_WIDTH:0] rq2_wptr;


endinterface




//Modports aren't really necessary here
/*
modport mem_unit_signals(	input clk_wr, 
							input clk_rd,
							input wr_en,
							input rd_en,
							input waddr, 
							input raddr,
							input data_in
							output data_out);


modport read_ptr_signals(	input clk_rd,
							input rst_n,
							input rd_en,
							input rq2_wptr,
							output rptr,
							output raddr,
							output empty);

modport write_ptr_signals(	input clk_wr,
							input rst_n,
							input wr_en,
							input wq2_rptr,
							output wptr,
							output waddr,
							output full);

modport rd2wr_signals(	input clk_wr,
						input rst_n,
						input rptr,
						output wq2_rptr);

modport wr2rd_signals(	input clk_rd,
						input rst_n,
						input wptr,
						output rq2_wptr);
*/



