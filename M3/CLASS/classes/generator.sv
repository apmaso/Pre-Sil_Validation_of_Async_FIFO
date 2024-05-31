/*********************************************
//	Generator Class for the OOP/Class Based 
//  Testbench for an Asynchronous FIFO Module
//
//
//	Author: Alexander Maso
//	 
*********************************************/


class generator;

  transaction tx;
  mailbox gen2drv;


 function new (mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction


  task execute();
    $display("********** Generator Started **********"); 
    repeat(TX_COUNT) begin
      tx = new();
      assert(tx.randomize());
      tx.wr_en = 1;
      tx.rd_en = 0;
      gen2drv.put(tx);
      $display("Generator tx\t|  wr_en: %b  |  rd_en: %b  |  data: %h  ", tx.wr_en, tx.rd_en, tx.data_in); 
    end
    
    // #100; // wait for 100 time units before turning off wr_en and turning on rd_en
    
    repeat(TX_COUNT) begin
      tx = new();
      tx.wr_en = 0;
      tx.rd_en = 1;
      gen2drv.put(tx);
      $display("Generator tx\t|  wr_en: %b  |  rd_en: %b  |  data: %h  ", tx.wr_en, tx.rd_en, tx.data_in); 
    end
    $display("********** Generator Ended **********"); 

  endtask : execute

endclass
