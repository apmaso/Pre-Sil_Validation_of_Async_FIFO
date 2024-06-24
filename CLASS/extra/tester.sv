/*********************************************
//	Tester Class for the OOP/Class Based 
//  Testbench for an Asynchronous FIFO Module
//
//  Creates virtual bfm and overwrites constructor
//  Also creates handles for tester, coverage
//  and scoreboard classes.  Contains function 
//  get_data(), which assigns random data with a 50%
//  chance of being 0 or max, and task execute(), which 
//  drives a 120 word write burst and, after 10 write
//  clocks reads until the FIFO is empty.
//
//
//	Alexander Maso
//	 
*********************************************/
class tester;
  
  virtual fifo_bfm bfm;

  function new (virtual fifo_bfm b);
      bfm = b;
  endfunction : new


  // Function to create random data to drive at fifo
  // Weighted to make 50% of values 0x00/0xFF
  // TODO: ? protected ? Do I need it? WHat does it do? 
  protected function logic [DATA_WIDTH-1:0] get_data();
    bit [1:0] zero_ones;
    zero_ones = $random;
    if (zero_ones == 2'b00)
      return 8'h00;
    else if (zero_ones == 2'b11)
      return 8'hFF;
    else
      return $random;
  endfunction : get_data

  // Execute a single, 120 burst read and write to FIFO
  // wr_en is asserted first and read_en is asserted 10 cycles later
  // after 120 cycles of clk_wr, wr_en is deasserted.  Reads continue
  // until FIFO is empty and rd_en is then deasserted 
  task execute();
      bfm.reset_fifo();

      // Run through 25, 120 word bursts
      repeat (25) begin

        // Grab data, set write enable and write for 10 write cylces
        @(negedge bfm.clk_wr)
        bfm.data_in = get_data();
        bfm.wr_en = 1'b1;
        repeat (9) begin
          @(negedge bfm.clk_wr)
          bfm.data_in = get_data();
        end

        // After 10 cycles enable read and continue for 110 remaining writes in burst
        bfm.rd_en = 1'b1;
        repeat (110) begin
          @(negedge bfm.clk_wr)
          bfm.data_in = get_data();
        end
    
        // After 120 cycles of wr_clk -> Deassert wr_en
        bfm.wr_en = 1'b0;
        // Wait for all reads to complete
        repeat (64) @(posedge bfm.clk_rd);
        bfm.rd_en = 1'b0;
        repeat (10) @(posedge bfm.clk_rd);
      end

      $stop;

   endtask : execute
endclass 
