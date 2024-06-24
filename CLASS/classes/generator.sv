/*********************************************
//	Generator Class for the OOP/Class Based 
//  Testbench for an Asynchronous FIFO Module
//
//
//	Author: Alexander Maso
//	 
*********************************************/


class generator;

  transaction tx_wr, tx_rd;
  mailbox gen2drv, gen2mon;


  function new (mailbox gen2drv, mailbox gen2mon);
    this.gen2drv = gen2drv;
    this.gen2mon = gen2mon;
  endfunction

  task write();
    repeat(TX_COUNT_WR) begin
      tx_wr = new();
      assert(tx_wr.randomize());
      tx_wr.wr_en = 1;
      tx_wr.rd_en = 0;
      gen2drv.put(tx_wr);
      $display("Generator tx_wr\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h", tx_wr.wr_en, tx_wr.rd_en, tx_wr.data_in, tx_wr.data_out); 
    end
  endtask : write

  task read();
    repeat(TX_COUNT_RD) begin
      tx_rd = new();
      //assert(tx_rd.randomize());
      tx_rd.wr_en = 0;
      tx_rd.rd_en = 1;
      gen2mon.put(tx_rd);
      $display("Generator tx_rd\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h", tx_rd.wr_en, tx_rd.rd_en, tx_rd.data_in, tx_rd.data_out);    
    end
  endtask : read


  task execute();
    $display("********** Generator Started **********"); 
    fork
      write();
      read();
    join_none
    // #100; 
    $display("********** Generator Ended **********"); 
  endtask : execute

endclass
