/********************************************
*   Sequence class for a UVVM testbench 
*   of an asynchronous FIFO.
*
*   The sequences are responsible for generating
*   the read and write transactions for the FIFO.
*   The sequences are parameterized to allow for
*   different combinations.
*
*   This file constains the following sequences:
*   - fifo_burst_wr_seq
*   - fifo_burst_rd_seq
*   - fifo_flag_wr_seq
*   - fifo_flag_rd_seq
*   - fifo_random_wr_seq
*   - fifo_random_rd_seq
*
*   The burst sequences generate a burst of transactions
*   with a fixed number of transactions per burst. The
*   flag sequences generate transactions to test the
*   full, half-full, and empty flags. The random sequences
*   generate a number of fully randomized transactions.
*   The flag sequences extend the burst sequences and the 
*   random sequences extend the flag sequences. 
********************************************/

class fifo_burst_wr_seq extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_burst_wr_seq) // Register the class with the factory

  // Declare handle to the transaction packet
  fifo_transaction tx_wr;
  
  // Counter for the current burst number
  int burst_count = 1;    
  
  // Constructor 
  function new(string name="fifo_burst_wr_seq");
    super.new(name);
  endfunction
  
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    tx_wr = fifo_transaction::type_id::create("tx_wr");
    repeat(BURST_SEQ_CNT) begin
      `uvm_info("BURST_WRITE_SEQ", $sformatf("Starting burst write sequence number: %0d", burst_count), UVM_MEDIUM)
      repeat (BURST_SIZE) begin
        start_item(tx_wr);
        
        // Burst of writes with random data
        assert(tx_wr.randomize() with {op == WRITE;});
        tx_wr.wr_en = 1;
        
        `uvm_info("GENERATE", tx_wr.convert2string(), UVM_HIGH)
        finish_item(tx_wr);
      end
      // 72 No-write tx to allow FIFO to be emptied -> 72*12.5 = 900 ticks (Delta btw read and write bursts)
      // Plus 8 dummy txs per buffer count (8 Write Clks = 5 Read Clks)
      repeat (72+(8*BUFFER_CNT)) begin
        start_item(tx_wr);
        tx_wr.wr_en = 0;
        `uvm_info("GENERATE", tx_wr.convert2string(), UVM_HIGH)
        finish_item(tx_wr);
      end
      burst_count++;
    end

    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
  
endclass

class fifo_burst_rd_seq extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_burst_rd_seq) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_rd;
  
  // Counter for the current burst number
  int burst_count = 1;    
  
  // Constructor 
  function new(string name="fifo_burst_rd_seq");
    super.new(name);
  endfunction
  
  // virtual task body();
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    tx_rd = fifo_transaction::type_id::create("tx_rd");
    repeat(BURST_SEQ_CNT) begin
      `uvm_info("BURST_READ_SEQ", $sformatf("Starting burst read sequence number: %0d", burst_count), UVM_MEDIUM)
      // Burst of reads
      repeat (BURST_SIZE) begin
        start_item(tx_rd);
        tx_rd.op = READ; 
        tx_rd.rd_en = 1;
        `uvm_info("GENERATE", tx_rd.convert2string(), UVM_HIGH)
        finish_item(tx_rd);
      end
      // 5 dummy txs per buffer count (5 Read Clks = 8 Write Clks)
      repeat(5*BUFFER_CNT) begin
        start_item(tx_rd);
        tx_rd.rd_en = 0;
        `uvm_info("GENERATE", tx_rd.convert2string(), UVM_HIGH)
        finish_item(tx_rd);
      end
      burst_count++;
    end
   
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
endclass

class fifo_flag_wr_seq extends fifo_burst_wr_seq;
  `uvm_object_utils(fifo_flag_wr_seq) // Register the class with the factory

  // Declare handle to the transaction packet
  fifo_transaction tx_wr;
  
  // Constructor 
  function new(string name="fifo_flag_wr_seq");
    super.new(name);
  endfunction
  
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("FLAG_WRITE_SEQ", "Starting write sequence for flag_test", UVM_MEDIUM)
    
    tx_wr = fifo_transaction::type_id::create("tx_wr");
    repeat(FLAG_SEQ_CNT) begin
      repeat(32) begin // 32 writes to half-fill the FIFO
        start_item(tx_wr);
      
        assert(tx_wr.randomize() with {op == WRITE;});
        tx_wr.wr_en = 1;
      
        `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
        finish_item(tx_wr);
      end

      // 8 Writes = 5 Reads => Toggle write tx signals in sets of 8
      // FLAG_TX_CNT controls the number of times the HALF flag is toggled
      repeat (FLAG_TX_CNT) begin
        repeat (7) begin
          start_item(tx_wr);
          tx_wr.wr_en = 0;
          `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
          finish_item(tx_wr);
        end
        repeat (1) begin
          start_item(tx_wr);
          assert(tx_wr.randomize() with {op == WRITE;});
          tx_wr.wr_en = 1;
          `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
          finish_item(tx_wr);
        end
      end

      // 32 more writes to fill the FIFO
      repeat(32) begin 
        start_item(tx_wr);
        assert(tx_wr.randomize() with {op == WRITE;});
        tx_wr.wr_en = 1;
        `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
        finish_item(tx_wr);
      end

      // 8 Writes = 5 Reads => Toggle write tx signals in sets of 8
      // FLAG_TX_CNT controls the number of times the FULL flag is toggled
      // One less then FLAG_TX_CNT to allow for the initial 64 writes
      repeat (FLAG_TX_CNT) begin
        repeat (7) begin
          start_item(tx_wr);
          tx_wr.wr_en = 0;
          `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
          finish_item(tx_wr);
        end
        repeat (1) begin
          start_item(tx_wr);
          assert(tx_wr.randomize() with {op == WRITE;});
          tx_wr.wr_en = 1;
          `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
          finish_item(tx_wr);
        end
      end
    
      // 104 write clks = 64+1 read clks to empty the FIFO
      repeat (104) begin
        start_item(tx_wr);
        tx_wr.wr_en = 0;
        `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
        finish_item(tx_wr);
      end
    
      // 8 Writes = 5 Reads => Toggle write tx signals in sets of 8
      // FLAG_TX_CNT controls the number of times the EMPTY flag is toggled
      // No writes are needed to attempt to read from an empty FIFO 
      repeat (FLAG_TX_CNT) begin
        repeat (8) begin
          start_item(tx_wr);
          tx_wr.wr_en = 0;
          `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
          finish_item(tx_wr);
        end
      end

      // 8 dummy transactions to buffer between tests
      repeat(8) begin
        start_item(tx_wr);
        tx_wr.wr_en = 0;
        `uvm_info("GENERATE", tx_wr.convert2string(), UVM_HIGH)
        finish_item(tx_wr);
      end
    end

    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
  
endclass
class fifo_flag_rd_seq extends fifo_burst_rd_seq;
  `uvm_object_utils(fifo_flag_rd_seq) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_rd;
  
  // Constructor 
  function new(string name="fifo_flag_rd_seq");
    super.new(name);
  endfunction
  
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("FLAG_READ_SEQ", "Starting read sequence for flag_test", UVM_MEDIUM)
    tx_rd = fifo_transaction::type_id::create("tx_rd");
    repeat(FLAG_SEQ_CNT) begin
      repeat(20) begin // 20 tx w/o rd_en to half-fill the FIFO -> 20 Read Clks = 32 Write Clks
        start_item(tx_rd);
        tx_rd.op = READ;
        tx_rd.rd_en = 0;
        `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
        finish_item(tx_rd);
      end

      // 5 Reads = 8 Writes => Toggle read tx signals in sets of 5
      // FLAG_TX_CNT controls the number of times the HALF flag is toggled
      // One less then FLAG_TX_CNT to allow for the initial half-fill
      repeat (FLAG_TX_CNT) begin
        repeat (1) begin
          start_item(tx_rd);
          tx_rd.op = READ;
          tx_rd.rd_en = 1;
          `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
          finish_item(tx_rd);
        end
        repeat (4) begin 
          start_item(tx_rd);
          tx_rd.op = READ;
          tx_rd.rd_en = 0;
          `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
          finish_item(tx_rd);
        end
      end

      repeat(20) begin // 20 tx w/o rd_en to fill the FIFO -> 20 Read Clks = 32 Write Clks
        start_item(tx_rd);
        tx_rd.op = READ;
        tx_rd.rd_en = 0;
        `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
        finish_item(tx_rd);
      end

      // 5 Reads = 8 Writes => Toggle read tx signals in sets of 5
      // FLAG_TX_CNT controls the number of times the FULL flag is toggled
      // No reads are needed to attempt to write to a full FIFO 
      repeat (FLAG_TX_CNT) begin
        repeat (5) begin 
          start_item(tx_rd);
          tx_rd.op = READ;
          tx_rd.rd_en = 0;
          `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
          finish_item(tx_rd);
        end
      end 

      // 64 Reads to empty the FIFO
      repeat (64) begin
        start_item(tx_rd);
        tx_rd.op = READ;
        tx_rd.rd_en = 1;
        `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
        finish_item(tx_rd);
      end 
      // Single read to make 65 => 65 Read Clks = 104 Write Clks
      start_item(tx_rd);
      tx_rd.op = READ;
      tx_rd.rd_en = 0;
      `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);

      // 5 Reads = 8 Writes => Toggle read tx signals in sets of 5
      // FLAG_TX_CNT controls the number of times the EMPTY flag is toggled
      // One less then FLAG_TX_CNT to allow for the initial emptying
      repeat (FLAG_TX_CNT) begin
        repeat (4) begin
          start_item(tx_rd);
          tx_rd.op = READ;
          tx_rd.rd_en = 0;
          `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
          finish_item(tx_rd);
        end
        repeat (1) begin 
          start_item(tx_rd);
          tx_rd.op = READ;
          tx_rd.rd_en = 1;
          `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
          finish_item(tx_rd);
        end
      end

      // 5 dummy transactions to buffer between tests 
      repeat(5) begin
        start_item(tx_rd);
        tx_rd.rd_en = 0;
        `uvm_info("GENERATE", tx_rd.convert2string(), UVM_HIGH)
        finish_item(tx_rd);
      end
    end

    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body

endclass

class fifo_random_wr_seq extends fifo_burst_wr_seq;
  `uvm_object_utils(fifo_random_wr_seq) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_wr;
  
  // Constructor 
  function new(string name="fifo_random_wr_seq");
    super.new(name);
  endfunction
  
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("RANDOM_WRITE_SEQ", "Starting write sequence for random_test", UVM_MEDIUM)
    
    // Force one write so there is data if first randomzied read tx has rd_en asserted
    tx_wr = fifo_transaction::type_id::create("tx_wr");
    // Remaining writes are fully randomzied
    repeat(RANDOM_TX_CNT) begin 
      start_item(tx_wr);
      
      assert(tx_wr.randomize() with {op == WRITE;});
      `uvm_info("GENERATED", tx_wr.convert2string(), UVM_HIGH)
      
      finish_item(tx_wr);
    end

    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body
  
endclass
class fifo_random_rd_seq extends fifo_burst_rd_seq;
  `uvm_object_utils(fifo_random_rd_seq) // Register the class with the factory

  // Declare handles to the transaction packet
  fifo_transaction tx_rd;
  
  // Constructor 
  function new(string name="fifo_random_rd_seq");
    super.new(name);
  endfunction
  
  // Not virtual in Doulos Video
  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    `uvm_info("RANDOM_READ_SEQ", "Starting read sequence for random_test", UVM_MEDIUM)
    
    // Fully randomzied read transactions 
    tx_rd = fifo_transaction::type_id::create("tx_rd");
    repeat(RANDOM_TX_CNT) begin 
      start_item(tx_rd);
      
      assert(tx_rd.randomize() with {op == READ;});
      
      `uvm_info("GENERATED", tx_rd.convert2string(), UVM_HIGH)
      finish_item(tx_rd);
    end
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : body

endclass
