/*********************************************
//	Driver Class for a UVM Based Testbench 
//  of an Asynchronous FIFO Module
//
//
//	Author: Alexander Maso
//	 
*********************************************/

class fifo_driver extends uvm_driver #(fifo_transaction); 
  `uvm_component_utils(fifo_driver)

  virtual fifo_bfm bfm;
  fifo_transaction tx_wr;
  
  // Constructor
  function new(string name = "fifo_driver", uvm_component parent);
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
    super.run_phase(phase);  //Not included in Doulos Video
    forever begin
      seq_item_port.get_next_item(tx_wr); 
      // Drive data to FIFO
      @(posedge bfm.clk_wr);
        bfm.data_in   <= tx_wr.data_in; 
        bfm.wr_en     <= tx_wr.wr_en; 
      // Update flags in this transaction
      @(negedge bfm.clk_wr); 
        tx_wr.full      = bfm.full;
        tx_wr.empty     = bfm.empty;
        tx_wr.half      = bfm.half;
      
      `uvm_info(get_type_name(), $sformatf("Driver tx_wr \t\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h  |  full: %b  |  empty: %b  |  half: %b", tx_wr.wr_en, tx_wr.rd_en, tx_wr.data_in, tx_wr.data_out, tx_wr.full, tx_wr.empty, tx_wr.half), UVM_DEBUG);
      seq_item_port.item_done(); 
    end
  endtask : run_phase

/*
  task execute();
    $display("********** Driver Started **********");
    bfm.reset_fifo();  // reset takes 2 RD_CLKs
    repeat(TX_COUNT_WR) begin
      gen2drv.get(tx_wr);
      // Drive data to FIFO
      @(posedge bfm.clk_wr);
        bfm.data_in <= tx_wr.data_in; 
        bfm.wr_en   <= tx_wr.wr_en; 
      // Update flags in this transaction
      @(negedge bfm.clk_wr); 
        tx_wr.full      = bfm.full;
        tx_wr.empty     = bfm.empty;
        tx_wr.half      = bfm.half;
        $display("Driver tx_wr \t\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h  |  full: %b  |  empty: %b  |  half: %b", tx_wr.wr_en, tx_wr.rd_en, tx_wr.data_in, tx_wr.data_out, tx_wr.full, tx_wr.empty, tx_wr.half);
        drv2scb.put(tx_wr);
    end
    $display("********** Driver Ended **********");
  endtask : execute
*/  

endclass
