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
      if (tx_wr.wr_en) begin
        @(posedge bfm.clk_wr);
          bfm.data_in <= tx_wr.data_in;
          bfm.wr_en <= tx_wr.wr_en;
      end
      else if (tx_wr.rd_en) begin
        @(posedge bfm.clk_rd);
          bfm.rd_en <= tx_wr.rd_en;
      end
      else begin
        `uvm_error("DRIVER", "Neither read nor write enabled");
      end
         
      `uvm_info(get_type_name(), $sformatf("Driver tx_wr \t\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  ", tx_wr.wr_en, tx_wr.rd_en, tx_wr.data_in), UVM_MEDIUM);
      seq_item_port.item_done(); 
    end
  endtask : run_phase
 

endclass
