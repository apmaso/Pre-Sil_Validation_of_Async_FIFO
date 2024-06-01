/*********************************************
//	Monitor Class for a UVM Based Testbench 
//  of an Asynchronous FIFO Module
//
//
//	Author: Alexander Maso
//	 
*********************************************/

class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor) // Register the component with the factory
  
  virtual fifo_bfm bfm;
  fifo_transaction tx_rd;

  // Declare analysis port
  uvm_analysis_port #(fifo_transaction) monitor_port;

  // This variable is used to determine if the last transaction was a read
  bit last_rd_en = 0;

  // Constructor
  function new(string name = "fifo_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
  endfunction : new

  // Build phase   TODO: Check if this can be virtual
  // virtual function void build_phase(uvm_phase phase);
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_HIGH);
    
    if(!uvm_config_db #(virtual fifo_bfm)::get(this, "", "bfm", bfm))
      `uvm_fatal("NOBFM", {"bfm not defined for ", get_full_name(), "."});
  
    // Use new constructor to create the analysis port
    monitor_port = new("monitor_port", this);
  endfunction : build_phase
  
  // Connect phase   TODO: Check if this can be virtual
  //virtual function void connect_phase(uvm_phase phase);
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_HIGH);


  endfunction : connect_phase

  // Run Phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase); 
    `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_HIGH);

    @(posedge bfm.clk_rd);
    bfm.rd_en <= 1'b0;
    // TODO: This should be a forever loop if I can work the timing out
    #((READ_DELAY+8)*CYCLE_TIME_RD); // wait for the driver to reset and for some data to be put on the FIFO (8 RD_CLK min...)
    repeat(TX_COUNT_RD+2) begin
      tx_rd = fifo_transaction::type_id::create("tx_rd");
      @(posedge bfm.clk_rd);
        bfm.rd_en <= 1'b1;
        // If the last transaction was also a read, then we must wait for the next read clock edge
        if (bfm.rd_en && last_rd_en) begin
          #(CYCLE_TIME_RD);
          tx_rd.rd_en = bfm.rd_en;
          tx_rd.wr_en = bfm.wr_en;
          tx_rd.data_out = bfm.data_out;
          tx_rd.empty = bfm.empty;
          tx_rd.full = bfm.full;
          tx_rd.half = bfm.half;
        end
        // Otherwise, we can sample the data_out on the same cycle as the read
        else begin
          @(posedge bfm.clk_rd);
          tx_rd.rd_en = bfm.rd_en;
          tx_rd.wr_en = bfm.wr_en;
          tx_rd.data_out = bfm.data_out;
          tx_rd.empty = bfm.empty;
          tx_rd.full = bfm.full;
          tx_rd.half = bfm.half;
        end
        //bfm.rd_en <= 1'b1;
        last_rd_en = tx_rd.rd_en;
        `uvm_info(get_type_name(), $sformatf("Monitor tx_rd \t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h  |  full: %b  |  empty: %b  |  half: %b", tx_rd.wr_en, tx_rd.rd_en, tx_rd.data_in, tx_rd.data_out, tx_rd.full, tx_rd.empty, tx_rd.half), UVM_DEBUG);
        monitor_port.write(tx_rd);
    end

  endtask : run_phase

/*
  task execute();
    #((READ_DELAY+8)*CYCLE_TIME_RD); // wait for the driver to reset and for some data to be put on the FIFO (8 RD_CLK min...)
    $display("********** Monitor Started **********"); 
    repeat(TX_COUNT_RD) begin
      gen2mon.get(tx_rd);
      @(posedge bfm.clk_rd);
        bfm.rd_en <= tx_rd.rd_en;
        // If the last transaction was also a read, then we must wait for the next read clock edge
        if (tx_rd.rd_en && last_rd_en) begin
          #(CYCLE_TIME_RD);
          tx_rd.data_out = bfm.data_out;
          tx_rd.empty = bfm.empty;
          tx_rd.full = bfm.full;
          tx_rd.half = bfm.half;
        end
        // Otherwise, we can sample the data_out on the same cycle as the read
        else begin
          @(posedge bfm.clk_rd);
          tx_rd.data_out = bfm.data_out;
          tx_rd.empty = bfm.empty;
          tx_rd.full = bfm.full;
          tx_rd.half = bfm.half;
        end
        last_rd_en = tx_rd.rd_en;
        mon2scb.put(tx_rd);
        $display("Monitor tx_rd \t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h  |  full: %b  |  empty: %b  |  half: %b", tx_rd.wr_en, tx_rd.rd_en, tx_rd.data_in, tx_rd.data_out, tx_rd.full, tx_rd.empty, tx_rd.half); 
    end
    $display("********** Monitor Ended **********"); 
  endtask : execute
*/

endclass
