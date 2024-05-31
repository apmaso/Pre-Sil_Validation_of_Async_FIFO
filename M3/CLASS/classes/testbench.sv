/*********************************************
//	Testbench Class for the OOP/Class Based 
//  Testbench for an Asynchronous FIFO Module
//
//  Creates virtual bfm and calls constructor
//  Also creates handles for generator, driver
//  monitor, coverage and scoreboard classes.  
//  Contains task execute(), which passes the 
//  constructor for all handles above the bfm
//  as well as the required mailbox, then forks 
//  and calls the execute() function for each.
//
//  Author: Alexander Maso
//	 
*********************************************/

class testbench;
  
  virtual fifo_bfm bfm;
  mailbox gen2drv, drv2mon, mon2scb;

  //coverage    coverage_h;
  scoreboard  scoreboard_h;
  monitor     monitor_h;
  driver      driver_h;
  generator   generator_h;

  function new (virtual fifo_bfm bfm, mailbox gen2drv, mailbox drv2mon, mailbox mon2scb);
    this.bfm = bfm;
    this.gen2drv = gen2drv;
    this.drv2mon = drv2mon;
    this.mon2scb = mon2scb;
  endfunction : new

  task execute();
    gen2drv = new();
    drv2mon= new();
    mon2scb = new();
    //coverage_h   = new(bfm);
    generator_h = new(gen2drv);
    monitor_h = new(bfm, drv2mon, mon2scb);
    driver_h = new(bfm, gen2drv, drv2mon);
    scoreboard_h = new(mon2scb);

    fork
      //coverage_h.execute();
      scoreboard_h.execute();
      monitor_h.execute();
      driver_h.execute();
      generator_h.execute();
    join_none

   endtask : execute

endclass
