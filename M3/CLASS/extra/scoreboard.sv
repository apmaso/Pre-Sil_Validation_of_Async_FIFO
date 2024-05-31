class Scoreboard;

  import fifo_pkg::*;

  // Adding this paramters just to check functionality of the environment
  // FIXME: I believe this should be imported as part of the package
  // parameter DATA_WIDTH = 8;
  // parameter ADDR_WIDTH = 6;

  parameter DEPTH = 2**ADDR_WIDTH;
  
  // Local memory, ptrs and count used to check FIFO
  logic [DATA_WIDTH-1:0] memory[DEPTH-1:0]; 
  int write_ptr = 0;
  int read_ptr = 0;
  int count = 0;

  virtual Asynchronous_FIFO_bfm_ext bfm;

  function new(virtual Asynchronous_FIFO_bfm_ext bfm);
    this.bfm = bfm;
  endfunction
  
  task write(input logic [DATA_WIDTH-1:0] data);
    if (count < DEPTH) begin
      memory[write_ptr] = data;
      write_ptr = (write_ptr + 1) % DEPTH; //Modulo keeps values in range from 0 to DEPTH-1
      count++;
    end else begin
      $display("Scoreboard Error: Write to full FIFO attempted.");
    end
  endtask
  
  task read_and_check();
    if (count > 0) begin
      logic [DATA_WIDTH-1:0] expected_data = memory[read_ptr];
      if (bfm.data_out !== expected_data) begin
        $error("Data mismatch!: expected %h, got %h at read pointer %0d", expected_data, bfm.data_out, read_ptr);
      end
      /*else begin
        $display("Scoreboard: Data out %h, matches expected %h at read pointer %0d", bfm.data_out, expected_data, read_ptr);
      end*/
      read_ptr = (read_ptr + 1) % DEPTH; //Modulo keeps values in range from 0 to DEPTH-1
      count--;
    end else begin
      $display("Scoreboard Error: Read from empty FIFO attempted.");
    end
  endtask

  // Monitor both write and read operations to keep the scoreboard fifo updated
  task execute();
    forever begin
      @(negedge bfm.clk_wr);
      if (bfm.wr_en && !bfm.full) write(bfm.data_in);
      
      @(posedge bfm.clk_rd);
      if (bfm.rd_en && !bfm.empty) read_and_check();
    end
  endtask
endclass
