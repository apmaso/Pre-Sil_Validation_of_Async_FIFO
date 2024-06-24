class coverage;
    virtual fifo_bfm bfm;               

// Constructor
//    function new (virtual fifo_bfm b);
//        bfm = b; 
//    endfunction : new


    // Covergroup for basic FIFO signals
    covergroup cg_fifo;
        coverpoint bfm.wr_en {
            bins wr_en = {1};
            bins wr_den = {0};
        }
        coverpoint bfm.rd_en {
            bins rd_en = {1};
            bins rd_den = {0};
        }
        coverpoint bfm.full {
            bins full_true = {1};
            bins full_false = {0};
        }
        coverpoint bfm.empty {
            bins empty_true = {1};
            bins empty_false = {0};
        }
        coverpoint bfm.half {
            bins half_full_true = {1};
            bins half_full_false = {0};
        }
    endgroup

    // Covergroup for depth levels of  FIFO
    covergroup cg_fifo_depth;
        coverpoint bfm.wptr {
            bins low = {[0:7]};             // Low depth
            bins mid = {[8:15]};            // Mid depth
            bins high = {[16:23]};          // High depth
            bins max = {[24:31]};           // Max depth
        }
        coverpoint bfm.rptr {
            bins low = {[0:7]};             // Low depth
            bins mid = {[8:15]};            // Mid depth 
            bins high = {[16:23]};          // High depth 
            bins max = {[24:31]};           // Max depth 
        }
    endgroup

    // Covergroup for monitoring half full and empty states
    covergroup cg_half_full_empty;
        coverpoint bfm.half {
            bins half_full_true = {1};
            bins half_full_false = {0};
        }
    endgroup

    // Covergroup for data integrity
    covergroup cg_data_integrity;
        coverpoint bfm.data_out {
            bins data_low = {[0:63]};
            bins data_mid = {[64:127]};
            bins data_high = {[128:191]};
            bins data_max = {[192:255]};
        }
    endgroup

    // Covergroup for specific data patterns
    covergroup cg_data_patterns;
        coverpoint bfm.data_in {
            bins pattern_zero = {8'h00};
            bins pattern_all_ones = {8'hFF};
            bins pattern_alt_ones = {8'h55, 8'hAA};
        }
        coverpoint bfm.data_out {
            bins pattern_zero = {8'h00};
            bins pattern_all_ones = {8'hFF};
            bins pattern_alt_ones = {8'h55, 8'hAA};
        }
    endgroup

    // Covergroup for burst w/r ops
    covergroup cg_burst_ops;
        coverpoint bfm.wr_en {
            bins burst_write = {1};
        }
        coverpoint bfm.rd_en {
            bins burst_read = {1};
        }
    endgroup

    // Covergroup for RST 
    covergroup cg_reset;
        coverpoint bfm.rst_n {
            bins reset_active = {0};
            bins reset_inactive = {1};
        }
    endgroup

    // Covergroup for idle cycles
    covergroup cg_idle_cycles;
        coverpoint bfm.wr_en iff (!bfm.wr_en) {
            bins wr_en_idle = {0};
        }
        coverpoint bfm.rd_en iff (!bfm.rd_en) {
            bins rd_en_idle = {0};
        }
    endgroup

    // Covergroup for high-freq ops
    covergroup cg_high_freq;
        coverpoint bfm.clk_wr {
            bins clk_wr_high = {1};
        }
        coverpoint bfm.clk_rd {
            bins clk_rd_high = {1};
        }
    endgroup

    // Covergroup for capturing abrupt changes in r/w rates
    covergroup cg_abrupt_change;
        coverpoint bfm.wr_en {
            bins wr_en_change = {1};
            bins wr_en_stable = {0};
        }
        coverpoint bfm.rd_en {
            bins rd_en_change = {1};
            bins rd_en_stable = {0};
        }
    endgroup

    // Covergroup for capturing throughput under varied conditions
    covergroup cg_throughput;
        coverpoint bfm.wr_en {
            bins wr_en_active = {1};
            bins wr_en_inactive = {0};
        }
        coverpoint bfm.rd_en {
            bins rd_en_active = {1};
            bins rd_en_inactive = {0};
        }
    endgroup

    // Constructor
    function new (virtual fifo_bfm b);
        this.bfm = b; 
        cg_fifo = new();
        cg_fifo_depth = new();
        cg_half_full_empty = new();
        cg_data_integrity = new();
        cg_data_patterns = new();
        cg_burst_ops = new();
        cg_reset = new();
        cg_idle_cycles = new();
        cg_high_freq = new();
        cg_abrupt_change = new();
        cg_throughput = new();
    endfunction

    // Task to sample all covergroups
    task sample();
        cg_fifo.sample();
        cg_fifo_depth.sample();
        cg_half_full_empty.sample();
        cg_data_integrity.sample();
        cg_data_patterns.sample();
        cg_burst_ops.sample();
        cg_reset.sample();
        cg_idle_cycles.sample();
        cg_high_freq.sample();
        cg_abrupt_change.sample();
        cg_throughput.sample();
    endtask

    task execute();
        forever begin
            @(posedge bfm.clk_rd or posedge bfm.clk_wr);    // Wait for a clock edge to sample
            sample();                                       
        end
    endtask : execute
endclass

