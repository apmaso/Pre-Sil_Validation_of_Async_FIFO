/*********************************************
//	Monitor Classes for a UVM Based Testbench 
//  of an Asynchronous FIFO Module
//  
//  Contains separate classes for read and write
//
//	Author: Alexander Maso
//	 
*********************************************/

class fifo_read_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_read_monitor) // Register the component with the factory
  
  virtual fifo_bfm bfm;
  fifo_transaction mon_tx_rd;

  // Declare analysis port
  uvm_analysis_port #(fifo_transaction) monitor_port_rd;

  // Constructor
  function new(string name = "fifo_read_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_DEBUG);
  endfunction : new

  // Build phase   TODO: Check if this can be virtual
  // virtual function void build_phase(uvm_phase phase);
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
    

    //repeat(TX_COUNT_RD+2) begin
    forever begin
      mon_tx_rd = fifo_transaction::type_id::create("mon_tx_rd");
      mon_tx_rd.op = READ;
      @(posedge bfm.clk_rd);
        if (bfm.rd_en) begin
          #(CYCLE_TIME_RD);
          mon_tx_rd.rd_en = bfm.rd_en;
          mon_tx_rd.data_out = bfm.data_out; 
          mon_tx_rd.empty = bfm.empty;
          //mon_tx_rd.full = bfm.full;
          mon_tx_rd.half = bfm.half;
          `uvm_info(get_type_name(), $sformatf("Monitor mon_tx_rd \t|  rd_en: %b  |  data_out: %h  |  full: %b  |  empty: %b  |  half: %b", mon_tx_rd.rd_en, mon_tx_rd.data_out, mon_tx_rd.full, mon_tx_rd.empty, mon_tx_rd.half), UVM_HIGH);
          monitor_port_rd.write(mon_tx_rd);
        end
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
  // virtual function void build_phase(uvm_phase phase);
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_DEBUG);
    
    if(!uvm_config_db #(virtual fifo_bfm)::get(this, "", "bfm", bfm))
      `uvm_fatal("NOBFM", {"bfm not defined for ", get_full_name(), "."});
  
    // Use new constructor to create the analysis port
    monitor_port_wr = new("monitor_port_wr", this);
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
      mon_tx_wr = fifo_transaction::type_id::create("mon_tx_wr");
      mon_tx_wr.op = WRITE;
      @(posedge bfm.clk_wr);
        mon_tx_wr.wr_en = bfm.wr_en;
        //mon_tx_wr.empty = bfm.empty;
        mon_tx_wr.full = bfm.full;
        mon_tx_wr.half = bfm.half;
        if (bfm.wr_en) begin
          mon_tx_wr.data_in = bfm.data_in; 
          `uvm_info(get_type_name(), $sformatf("Monitor mon_tx_wr \t|  wr_en: %b  |  data_in: %h  |  full: %b  |  empty: %b  |  half: %b", mon_tx_wr.wr_en, mon_tx_wr.data_in, mon_tx_wr.full, mon_tx_wr.empty, mon_tx_wr.half), UVM_HIGH);
          monitor_port_wr.write(mon_tx_wr);
        end 
    end
  endtask : run_phase
endclass : fifo_write_monitor 
