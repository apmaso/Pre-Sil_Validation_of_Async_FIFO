/*********************************************
//	Driver Class for the OOP/Class Based 
//  Testbench for an Asynchronous FIFO Module
//
//
//	Author: Alexander Maso
//	 
*********************************************/

class driver;
  virtual fifo_bfm bfm;
  mailbox gen2drv, drv2mon;
  transaction tx;

  function new(virtual fifo_bfm bfm, mailbox gen2drv, mailbox drv2mon);
    this.bfm = bfm;
    this.gen2drv = gen2drv;
    this.drv2mon = drv2mon;
  endfunction

  // internal signal to track address
  // bit [ADDR_WIDTH-1:0]  address = 0;

  task execute();
    $display("********** Driver Started **********");
    bfm.reset_fifo();  // reset takes 2 RD_CLKs
    repeat(2*TX_COUNT) begin
      gen2drv.get(tx);
      @(posedge bfm.clk_wr);
        $display("Driver tx \t\t|  wr_en: %b  |  rd_en: %b  |  data: %h", tx.wr_en, tx.rd_en, tx.data_in);
        if (tx.wr_en) begin
          bfm.data_in <= tx.data_in;
        end
        bfm.wr_en   <= tx.wr_en;
        bfm.rd_en   <= tx.rd_en;
        drv2mon.put(tx);
    end
    $display("********** Driver Ended **********");
  endtask : execute
  
/*  
  task execute();
    // Generate random data and write to FIFO
    forever begin
      bfm.data_in = $random;
      bfm.wr_en = 1;
      @(negedge bfm.clk_wr);
      bfm.wr_en = 0;
      repeat(10) @(negedge bfm.clk_wr);
    end
  endtask : execute
*/

endclass
