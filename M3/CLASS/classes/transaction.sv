/****************************************
*  Transaction Class for the OOP/Class Based
*  Testbench for an Asynchronous FIFO Module
*
*  This class contains the transaction packet
*  that is passed between the generator, driver,
*  monitor, and scoreboard.  It contains inputs
*  that can be randomized as well as containers
*  for the outputs and flags of the FIFO module.
*  
*  Author: Nick Alleyer
*  Modifications: Alexander Maso
****************************************/

class transaction;

	// inputs
	logic wr_en;	// not randomizing wr_en and rd_en for now
	logic rd_en;	// will be used in the future
	//rand logic wr_en;
	//rand logic rd_en;
	rand logic [DATA_WIDTH-1:0] data_in;

	// outputs
	logic [DATA_WIDTH-1:0] data_out;
	logic full;
	logic half;
	logic empty;

	//constraint wr_con{wr_en dist {1 := 3, 0 := 1};}	//3x more likely to write than not
	//constraint rd_con{rd_en dist {1 := 1, 0 := 2};}	//2x more likely to not read than read

	/*
	function void print();
		$display("Writing: %b or Reading: %b", wr_en, rd_en);
		$display("Data in: %h, Data out: %h", data_in, data_out);
		$display("Full: %b, Half: %b, Empty: %b", full, half, empty);
	endfunction: print
	*/

endclass: transaction
