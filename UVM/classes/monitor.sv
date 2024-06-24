/*********************************************
* Monitor Classes for a UVM Based Testbench 
* of an Asynchronous FIFO Module
*  
* This class is responsible for grabbing the bfm
* handle from the configuration database, using
* the new() constructor to create the analysis
* port, and monitoring the signals in the FIFO.
* 
* This file contains two separate classes, one
* monitor for the write domain and one monitor
* for the read domain.
*	 
*********************************************/

class fifo_read_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_read_monitor) // Register the component with the factory
  
  virtual fifo_bfm bfm;
  fifo_transaction mon_tx_rd;

  // Declare analysis port
  uvm_analysis_port #(fifo_transaction) monitor_port_rd;

  // Flag for last vaue of empty
  // This is used to determine if data will be actually be available
  // Since the read and write domains are asynchronous, the two clocks
  // can sometimes be only 1 ns apart. In this scenario, if the empty 
  // signal was asserted last cycle the data may not be available next cycle
  bit last_empty = 0;

  // Constructor
  function new(string name = "fifo_read_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_DEBUG);
  endfunction : new

  // Build phase   TODO: Check if this can be virtual
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_DEBUG);
    
    if(!uvm_config_db #(virtual fifo_bfm)::get(this, "", "bfm", bfm))
      `uvm_fatal("NOBFM", {"bfm not defined for ", get_full_name(), "."});
  
    // Use new constructor to create the analysis port
    monitor_port_rd = new("monitor_port_rd", this);
  endfunction : build_phase
  
  // Connect phase   TODO: Check if this can be virtual
  //virtual function void connect_phase(uvm_phase phase);
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_DEBUG);

  endfunction : connect_phase

  // Run Phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_DEBUG);
    
    forever begin
      mon_tx_rd = fifo_transaction::type_id::create("mon_tx_rd");
      mon_tx_rd.op = READ;
      @(posedge bfm.clk_rd);
        if (bfm.rd_en) begin
	        mon_tx_rd.clk_rd = bfm.clk_rd;
	        mon_tx_rd.clk_wr = bfm.clk_wr;
	        mon_tx_rd.rst_n = bfm.rst_n;
          mon_tx_rd.rd_en = bfm.rd_en;
          mon_tx_rd.wr_en = bfm.wr_en;
          mon_tx_rd.empty = bfm.empty;
          mon_tx_rd.full = bfm.full;
          mon_tx_rd.half = bfm.half;
	        mon_tx_rd.rptr = bfm.rptr;
	        mon_tx_rd.raddr = bfm.raddr;
	        mon_tx_rd.rq2_wptr = bfm.rq2_wptr;
          if (last_empty == 0) begin // If last empty signal wasn't asserted, data will be available next cycle
            #(CYCLE_TIME_RD);
            mon_tx_rd.data_out = bfm.data_out; 
          end
          `uvm_info(get_type_name(), $sformatf("Monitor mon_tx_rd \t|  rd_en: %b  |  data_out: %h  |  full: %b  |  empty: %b  |  half: %b", mon_tx_rd.rd_en, mon_tx_rd.data_out, mon_tx_rd.full, mon_tx_rd.empty, mon_tx_rd.half), UVM_HIGH);
          monitor_port_rd.write(mon_tx_rd);
        end
        last_empty = bfm.empty;
      end
  endtask : run_phase
endclass : fifo_read_monitor

class fifo_write_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_write_monitor) // Register the component with the factory
  
  virtual fifo_bfm bfm;
  fifo_transaction mon_tx_wr;

  // Declare analysis port
  uvm_analysis_port #(fifo_transaction) monitor_port_wr;

  // Constructor
  function new(string name = "fifo_write_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_DEBUG);
  endfunction : new

  // Build phase   TODO: Check if this can be virtual
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_DEBUG);
    
    if(!uvm_config_db #(virtual fifo_bfm)::get(this, "", "bfm", bfm))
      `uvm_fatal("NOBFM", {"bfm not defined for ", get_full_name(), "."});
  
    // Use new constructor to create the analysis port
    monitor_port_wr = new("monitor_port_wr", this);
  endfunction : build_phase
  
  // Connect phase   TODO: Check if this can be virtual
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_DEBUG);

  endfunction : connect_phase

  // Run Phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_DEBUG);
    
    forever begin
      mon_tx_wr = fifo_transaction::type_id::create("mon_tx_wr");
      mon_tx_wr.op = WRITE;
      @(posedge bfm.clk_wr);
	      mon_tx_wr.clk_wr = bfm.clk_wr;
	      mon_tx_wr.clk_rd = bfm.clk_rd;
        mon_tx_wr.wr_en = bfm.wr_en;
        mon_tx_wr.rd_en = bfm.rd_en;
	      mon_tx_wr.rst_n = bfm.rst_n;
        mon_tx_wr.full = bfm.full;
        mon_tx_wr.empty = bfm.empty;
        mon_tx_wr.half = bfm.half;
	      mon_tx_wr.wptr = bfm.wptr;
	      mon_tx_wr.waddr = bfm.waddr;
	      mon_tx_wr.wq2_rptr = bfm.wq2_rptr;
        if (bfm.wr_en) begin // If this was a read, then grab the data and write it to the port
          mon_tx_wr.data_in = bfm.data_in; 
          `uvm_info(get_type_name(), $sformatf("Monitor mon_tx_wr \t|  wr_en: %b  |  data_in: %h  |  full: %b  |  empty: %b  |  half: %b", mon_tx_wr.wr_en, mon_tx_wr.data_in, mon_tx_wr.full, mon_tx_wr.empty, mon_tx_wr.half), UVM_HIGH);
          monitor_port_wr.write(mon_tx_wr);
        end 
    end
  endtask : run_phase
endclass : fifo_write_monitor 
