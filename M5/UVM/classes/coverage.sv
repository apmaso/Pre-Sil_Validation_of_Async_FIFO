/***************************************************************
*  Coverage class for a UVM Based FIFO Verification
* 
*
*  Author: Alexander Maso
***************************************************************/

class fifo_coverage extends uvm_subscriber #(fifo_transaction);
    `uvm_component_utils(fifo_coverage) // Register the component with the factory

    // Declare the handle for our transactions
    fifo_transaction tx;

    // real is a double precision floating-point variable
    // For coverage numbers/printing (.get_coverage() returns a value of type real)

    real cov_cg_fifo;
    real cov_cg_fifo_depth;
    real cov_cg_half_full_empty;
    real cov_cg_data_integrity;
    real cov_cg_data_patterns;
    real cov_cg_burst_ops;
    real cov_cg_reset;
    real cov_cg_idle_cycles;
    real cov_cg_high_freq;
    real cov_cg_abrupt_change;
    real cov_cg_throughput;


    // Define covergroups
    // Covergroup for basic FIFO signals
    covergroup cg_fifo;
	option.per_instance = 1;
        coverpoint tx.wr_en {
            bins wr_en = {1};
            bins wr_den = {0};
        }
        coverpoint tx.rd_en {
            bins rd_en = {1};
            bins rd_den = {0};
        }
        coverpoint tx.full {
            bins full_true = {1};
            bins full_false = {0};
        }
        coverpoint tx.empty {
            bins empty_true = {1};
            bins empty_false = {0};
        }
        coverpoint tx.half {
            bins half_full_true = {1};
            bins half_full_false = {0};
        }
    endgroup

    // Covergroup for depth levels of  FIFO
/*
    covergroup cg_fifo_depth;
	option.per_instance = 1;
        coverpoint tx.wptr {
            bins low = {[0:7]};             // Low depth
            bins mid = {[8:15]};            // Mid depth
            bins high = {[16:23]};          // High depth
            bins max = {[24:31]};           // Max depth
        }
        coverpoint tx.rptr {
            bins low = {[0:7]};             // Low depth
            bins mid = {[8:15]};            // Mid depth 
            bins high = {[16:23]};          // High depth 
            bins max = {[24:31]};           // Max depth 
        }
    endgroup
*/

    // Covergroup for monitoring half full and empty states
    covergroup cg_half_full_empty;
	option.per_instance = 1;
        coverpoint tx.half {
            bins half_full_true = {1};
            bins half_full_false = {0};
        }
    endgroup

    // Covergroup for data integrity
    covergroup cg_data_integrity;
	option.per_instance = 1;
        coverpoint tx.data_out {
            bins data_low = {[0:63]};
            bins data_mid = {[64:127]};
            bins data_high = {[128:191]};
            bins data_max = {[192:255]};
        }
    endgroup

    // Covergroup for specific data patterns
    covergroup cg_data_patterns;
	option.per_instance = 1;
        coverpoint tx.data_in {
            bins pattern_zero = {8'h00};
            bins pattern_all_ones = {8'hFF};
            bins pattern_alt_ones = {8'h55, 8'hAA};
        }
        coverpoint tx.data_out {
            bins pattern_zero = {8'h00};
            bins pattern_all_ones = {8'hFF};
            bins pattern_alt_ones = {8'h55, 8'hAA};
        }
    endgroup

    // Covergroup for burst w/r ops
    covergroup cg_burst_ops;
	option.per_instance = 1;
        coverpoint tx.wr_en {
            bins burst_write = {1};
        }
        coverpoint tx.rd_en {
            bins burst_read = {1};
        }
    endgroup

/*
    // Covergroup for RST 
    covergroup cg_reset;
	option.per_instance = 1;
        coverpoint tx.rst_n {
            bins reset_active = {0};
            bins reset_inactive = {1};
        }
    endgroup
*/

    // Covergroup for idle cycles
    covergroup cg_idle_cycles;
        coverpoint tx.wr_en iff (!tx.wr_en) {
            bins wr_en_idle = {0};
        }
        coverpoint tx.rd_en iff (!tx.rd_en) {
            bins rd_en_idle = {0};
        }
    endgroup
/*
    // Covergroup for high-freq ops
    covergroup cg_high_freq;
        coverpoint tx.clk_wr {
            bins clk_wr_high = {1};
        }
        coverpoint tx.clk_rd {
            bins clk_rd_high = {1};
        }
    endgroup
*/
    // Covergroup for capturing abrupt changes in r/w rates
    covergroup cg_abrupt_change;
	option.per_instance = 1;
        coverpoint tx.wr_en {
            bins wr_en_change = {1};
            bins wr_en_stable = {0};
        }
        coverpoint tx.rd_en {
            bins rd_en_change = {1};
            bins rd_en_stable = {0};
        }
    endgroup

    // Covergroup for capturing throughput under varied conditions
    covergroup cg_throughput;
	option.per_instance = 1;
        coverpoint tx.wr_en {
            bins wr_en_active = {1};
            bins wr_en_inactive = {0};
        }
        coverpoint tx.rd_en {
            bins rd_en_active = {1};
            bins rd_en_inactive = {0};
        }
    endgroup

    // Constructor
    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_DEBUG);
    
        tx = fifo_transaction::type_id::create("tx");
	cg_fifo = new();
	//cg_fifo_depth = new();
	cg_half_full_empty = new();
	cg_data_integrity = new();
	cg_data_patterns = new();
	cg_burst_ops = new();
	//cg_reset = new();
	cg_idle_cycles = new();
	//cg_high_freq = new();
	cg_abrupt_change = new();
	cg_throughput = new();
    endfunction : new

    virtual function void write(fifo_transaction t);
        `uvm_info(get_type_name(), $sformatf("Writing to %s", get_full_name()), UVM_DEBUG);
        tx = t;
        t.print();

	cg_fifo.sample();
	//cg_fifo_depth.sample();
	cg_half_full_empty.sample();
	cg_data_integrity.sample();
	cg_data_patterns.sample();
	cg_burst_ops.sample();
	//cg_reset.sample();
	cg_idle_cycles.sample();
	//cg_high_freq.sample();
	cg_abrupt_change.sample();
	cg_throughput.sample();


	cov_cg_fifo = cg_fifo.get_coverage();
    	//cov_cg_fifo_depth = cg_fifo_depth.get_coverage();
    	cov_cg_half_full_empty = cg_half_full_empty.get_coverage();
    	cov_cg_data_integrity = cg_data_integrity.get_coverage();
    	cov_cg_data_patterns = cg_data_patterns.get_coverage();
    	cov_cg_burst_ops = cg_burst_ops.get_coverage();
    	//cov_cg_reset = cg_reset.get_coverage();
    	cov_cg_idle_cycles = cg_idle_cycles.get_coverage();
    	//cov_cg_high_freq = cg_high_freq.get_coverage();
    	cov_cg_abrupt_change = cg_abrupt_change.get_coverage();
    	cov_cg_throughput = cg_throughput.get_coverage();

/*
        `uvm_info(get_type_name(), $sformatf("Coverage cg_fifo: %f", cov_cg_fifo), UVM_NONE);
	    //`uvm_info(get_type_name(), $sformatf("Coverage cg_fifo_depth: %f", cov_cg_fifo_depth), UVM_NONE);
	    `uvm_info(get_type_name(), $sformatf("Coverage cg_half_full_empty: %f", cov_cg_half_full_empty), UVM_NONE);
	    `uvm_info(get_type_name(), $sformatf("Coverage cg_data_integrity: %f", cov_cg_data_integrity), UVM_NONE);
	    `uvm_info(get_type_name(), $sformatf("Coverage cg_data_patterns: %f", cov_cg_data_patterns), UVM_NONE);
	    `uvm_info(get_type_name(), $sformatf("Coverage cg_burst_ops: %f", cov_cg_burst_ops), UVM_NONE);
	    //`uvm_info(get_type_name(), $sformatf("Coverage cg_reset: %f", cov_cg_reset), UVM_NONE);
	    `uvm_info(get_type_name(), $sformatf("Coverage cg_idle_cycles: %f", cov_cg_idle_cycles), UVM_NONE);
	    //`uvm_info(get_type_name(), $sformatf("Coverage cg_high_freq: %f", cov_cg_high_freq), UVM_NONE);
	    `uvm_info(get_type_name(), $sformatf("Coverage cg_abrupt_change: %f", cov_cg_abrupt_change), UVM_NONE);
	    `uvm_info(get_type_name(), $sformatf("Coverage cg_throughput: %f", cov_cg_throughput), UVM_NONE);
*/

    endfunction : write

endclass

