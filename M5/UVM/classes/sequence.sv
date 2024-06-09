class fifo_write_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_write_sequence) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_wr;
  
  // Constructor 
  function new(string name="fifo_write_sequence");
    super.new(name);
  endfunction
  
  // virtual task body();
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("FIFO_WRITE_SEQ", "Starting write sequence", UVM_MEDIUM)
    
    // generate some transactions
    tx_wr = fifo_transaction::type_id::create("tx_wr");
    repeat(TX_COUNT_WR) begin
      start_item(tx_wr);
      
      assert(tx_wr.randomize() with {op == WRITE;});
      tx_wr.wr_en = 1;
      tx_wr.rd_en = 0;
      
      `uvm_info("GENERATE", tx_wr.convert2string(), UVM_HIGH)
      finish_item(tx_wr);
    end

    // 5 dummy transactions to buffer between tests
    repeat(5) begin
      start_item(tx_wr);
      assert(tx_wr.randomize() with {op == WRITE;});
      tx_wr.wr_en = 0;
      tx_wr.rd_en = 0;
      `uvm_info("GENERATE", tx_wr.convert2string(), UVM_HIGH)
      finish_item(tx_wr);
    end
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
  
endclass

class fifo_read_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_read_sequence) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_rd;
  
  // Constructor 
  function new(string name="fifo_read_sequence");
    super.new(name);
  endfunction
  
  // virtual task body();
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("FIFO_READ_SEQ", "Starting read sequence", UVM_MEDIUM)
    // generate some transactions
    tx_rd = fifo_transaction::type_id::create("tx_rd");
    repeat(TX_COUNT_RD) begin
      start_item(tx_rd);
      
      
      assert(tx_rd.randomize() with {op == READ;});
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 1;
      
      `uvm_info("GENERATE", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    end

    // 5 dummy transactions to buffer between tests 
    repeat(5) begin
      start_item(tx_rd);
      assert(tx_rd.randomize() with {op == READ;});
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 0;
      `uvm_info("GENERATE", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    end
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
endclass

class fifo_half_wr_seq extends fifo_write_sequence;
  `uvm_object_utils(fifo_half_wr_seq) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_wr;
  
  // Constructor 
  function new(string name="fifo_half_wr_seq");
    super.new(name);
  endfunction
  
  // virtual task body();
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("HALF_WRITE_SEQ", "Starting write sequence for half_test", UVM_MEDIUM)
    
    // generate some transactions
    tx_wr = fifo_transaction::type_id::create("tx_wr");
    repeat(32) begin // 32 writes to half-fill the FIFO
      start_item(tx_wr);
      
      assert(tx_wr.randomize() with {op == WRITE;});
      tx_wr.wr_en = 1;
      tx_wr.rd_en = 0;
      
      `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
      finish_item(tx_wr);
    end

    // 5 tx pairs to toggle the half-full flag 5 times
    repeat (5) begin
      start_item(tx_wr);
      assert(tx_wr.randomize() with {op == WRITE;});
      tx_wr.wr_en = 1;
      tx_wr.rd_en = 0;
      `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
      finish_item(tx_wr);
    
      start_item(tx_wr);
      assert(tx_wr.randomize() with {op == WRITE;});
      tx_wr.wr_en = 0;
      tx_wr.rd_en = 0;
      `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
      finish_item(tx_wr);
    end
    
    // 32 dummy writes to empty the FIFO
    repeat(32) begin 
      start_item(tx_wr);
      
      assert(tx_wr.randomize() with {op == WRITE;});
      tx_wr.wr_en = 0;
      tx_wr.rd_en = 0;
      
      `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
      finish_item(tx_wr);
    end

    // 5 dummy transactions to buffer between tests
    repeat(5) begin
      start_item(tx_wr);
      assert(tx_wr.randomize() with {op == WRITE;});
      tx_wr.wr_en = 0;
      tx_wr.rd_en = 0;
      `uvm_info("GENERATE", tx_wr.convert2string(), UVM_HIGH)
      finish_item(tx_wr);
    end
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
  
endclass
class fifo_half_rd_seq extends fifo_read_sequence;
  `uvm_object_utils(fifo_half_rd_seq) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_rd;
  
  // Constructor 
  function new(string name="fifo_half_rd_seq");
    super.new(name);
  endfunction
  
  // virtual task body();
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("HALF_READ_SEQ", "Starting read sequence for half_test", UVM_MEDIUM)
    
    // generate some transactions
    tx_rd = fifo_transaction::type_id::create("tx_rd");
    repeat(32) begin // 32 transactions w/o rd_en to half-fill the FIFO
      start_item(tx_rd);
      
      tx_rd.op = READ;
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 0;
      
      `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    end

    // 5 tx pairs to toggle the half-full flag 5 times
    repeat (5) begin
      start_item(tx_rd);
      tx_rd.op = READ;
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 0;
      `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    
      start_item(tx_rd);
      tx_rd.op = READ;
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 1;
      `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    end

    // 32 Reads to empty the FIFO
    repeat(32) begin 
      start_item(tx_rd);
      
      tx_rd.op = READ;
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 1;
      
      `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    end
    
    // 5 dummy transactions to buffer between tests 
    repeat(5) begin
      start_item(tx_rd);
      assert(tx_rd.randomize() with {op == READ;});
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 0;
      `uvm_info("GENERATE", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    end
    
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body

endclass
