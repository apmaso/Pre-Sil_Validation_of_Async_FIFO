class coverage;
	
	// Instantiating the interface
	virtual Asynchronous_FIFO_bfm_ext bfm;
	
	// Coverage
	covergroup cg_fifo with function sample(logic wr_en, logic rd_en, logic full, logic empty);
		coverpoint wr_en;
		coverpoint rd_en;
		coverpoint full;
		coverpoint empty;
	endgroup
	
	function new (virtual Asynchronous_FIFO_bfm_ext b);
		cg_fifo = new();
		bfm = b;
	endfunction
	
	// Instantiate coverage
	task execute();
		forever begin
			@(negedge bfm.clk_wr);
			/*wr_en = bfm.wr_en;
			rd_en = bfm.rd_en;
			full = bfm.full_en;
			empty = bfm.empty_en;*/
			cg_fifo.sample(bfm.wr_en, bfm.rd_en, bfm.full, bfm.empty);
		end
	endtask

endclass
