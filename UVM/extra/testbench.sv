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
  mailbox gen2drv, gen2mon, drv2scb, mon2scb;

  //coverage    coverage_h;
  scoreboard  scoreboard_h;
  monitor     monitor_h;
  driver      driver_h;
  generator   generator_h;

  function new (virtual fifo_bfm bfm, mailbox gen2drv,  mailbox gen2mon, mailbox drv2scb, mailbox mon2scb);
    this.bfm = bfm;
    this.gen2drv = gen2drv;
    this.gen2mon = gen2mon;
    this.drv2scb = drv2scb;
    this.mon2scb = mon2scb;
  endfunction : new

  task execute();
    gen2drv = new();
    gen2mon = new();
    drv2scb= new();
    mon2scb = new();
    //coverage_h   = new(bfm);
    generator_h = new(gen2drv, gen2mon);
    driver_h = new(bfm, gen2drv, drv2scb);
    monitor_h = new(bfm, gen2mon, mon2scb);
    scoreboard_h = new(drv2scb, mon2scb);

    fork
      //coverage_h.execute();
      scoreboard_h.execute();
      monitor_h.execute();
      driver_h.execute();
      generator_h.execute();
    join_none

   endtask : execute

endclass
