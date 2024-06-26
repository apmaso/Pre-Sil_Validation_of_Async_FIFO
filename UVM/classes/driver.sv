/*********************************************
* Driver Class for a UVM Based Testbench 
* of an Asynchronous FIFO Module
*
* The driver is responsible for getting the bfm
* handle from the configuration database and
* driving the data coming from the sequencer
* to the FIFO.
*
* This file contains two separate classes, one
* driver for the write domain and one driver
* for the read domain.
*
*********************************************/

class fifo_write_driver extends uvm_driver #(fifo_transaction); 
  `uvm_component_utils(fifo_write_driver)

  virtual fifo_bfm bfm;
  fifo_transaction tx_wr;
  
  // Constructor
  function new(string name = "fifo_write_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_DEBUG);
  endfunction : new

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_DEBUG);
    
    if(!uvm_config_db #(virtual fifo_bfm)::get(this, "", "bfm", bfm))
      `uvm_fatal("NOBFM", {"bfm not defined for ", get_full_name(), "."});
  
  endfunction : build_phase

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);  
    `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_DEBUG);
  endfunction : connect_phase
  
  // Run Phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);  //Not included in Doulos Video

    // Reset FIFO and wait for 8 write cycles or 100 ticks -> Equivalent to 5 read cycles
    bfm.reset_fifo();
    #(8*CYCLE_TIME_WR);    
    
    forever begin
      seq_item_port.get_next_item(tx_wr); 
      // Drive data to FIFO
      @(posedge bfm.clk_wr);
        bfm.data_in <= tx_wr.data_in;
        bfm.wr_en <= tx_wr.wr_en;
         
      `uvm_info(get_type_name(), $sformatf("Driver tx_wr \t\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  ", tx_wr.wr_en, tx_wr.rd_en, tx_wr.data_in), UVM_HIGH);
      seq_item_port.item_done(); 
    end
  endtask : run_phase
endclass

class fifo_read_driver extends uvm_driver #(fifo_transaction); 
  `uvm_component_utils(fifo_read_driver)

  virtual fifo_bfm bfm;
  fifo_transaction tx_rd;
  
  // Constructor
  function new(string name = "fifo_read_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
  endfunction : new

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_HIGH);
    
    if(!uvm_config_db #(virtual fifo_bfm)::get(this, "", "bfm", bfm))
      `uvm_fatal("NOBFM", {"bfm not defined for ", get_full_name(), "."});
  
  endfunction : build_phase

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);  
    `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_HIGH);
  endfunction : connect_phase
  
  // Run Phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);  

    // Reset FIFO and wait for 5 read cycles or 100 ticks -> Equivalent to 8 write cycles
    bfm.reset_fifo();
    #(5*CYCLE_TIME_RD);

    #(5*CYCLE_TIME_RD); // Wait for 5 read cycles
    forever begin
      seq_item_port.get_next_item(tx_rd);
      // Drive data to FIFO
      @(posedge bfm.clk_rd);
        bfm.rd_en <= tx_rd.rd_en;
         
      `uvm_info(get_type_name(), $sformatf("Driver tx_rd \t\t|  wr_en: %b  |  rd_en: %b  ", tx_rd.wr_en, tx_rd.rd_en), UVM_HIGH);
      seq_item_port.item_done(); 
    end
  endtask : run_phase
 

endclass

