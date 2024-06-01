class fifo_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_sequence) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_wr;
  
  // Constructor 
  function new(string name="fifo_sequence");
    super.new(name);
  endfunction
  
  // virtual task body();
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    // generate some transactions
    tx_wr = fifo_transaction::type_id::create("fifo_transaction");
    repeat(TX_COUNT_WR) begin
      start_item(tx_wr);
      
      if (!tx_wr.randomize())
        `uvm_error("RANDOMIZE", "Failed to randomize transaction")
      
      tx_wr.wr_en = 0;
      tx_wr.rd_en = 1;
      
      `uvm_info("GENERATE", tx_wr.convert2string(), UVM_MEDIUM)
      finish_item(tx_wr);
    end

    repeat(TX_COUNT_RD) begin
      start_item(tx_wr);
      
      //if (!tx_wr.randomize())
      //  `uvm_error("RANDOMIZE", "Failed to randomize transaction")
      
      tx_wr.wr_en = 0;
      tx_wr.rd_en = 1;
      
      `uvm_info("GENERATE", tx_wr.convert2string(), UVM_MEDIUM)
      finish_item(tx_wr);
    end

    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
  
endclass
