/*********************************************
//	Monitor Class for the OOP/Class Based 
//  Testbench for an Asynchronous FIFO Module
//
//
//	Author: Alexander Maso
//	 
*********************************************/

class monitor;
  
  virtual fifo_bfm bfm;
  mailbox gen2mon, mon2scb;
  transaction tx_rd;

  function new (virtual fifo_bfm bfm, mailbox gen2mon, mailbox mon2scb);
    this.bfm = bfm;
    this.gen2mon= gen2mon;
    this.mon2scb = mon2scb;
  endfunction

  // This variable is used to determine if the last transaction was a read
  bit last_rd_en = 0;
  
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

endclass
