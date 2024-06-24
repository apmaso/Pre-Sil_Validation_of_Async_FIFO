`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
//`include "monitor_in.sv"
//`include "monitor_out.sv"
`include "scoreboard.sv"

class environment;
	generator gen;
	driver drv;
	monitor mon;
	//monitor_in mon_in;
	//monitor_out mon_out;
	scoreboard scb;
	
	mailbox gen2drive;
	mailbox mon2scb;
	//mailbox mon_in2scb;
	//mailbox mon_out2scb;
	
	virtual fifo_bfm bfm;
	
	//reset driver function like in slides?
	
	task test();
		fork
			gen.execute();
			driv.execute();
			mon.execute();
			//mon_in.execute();
			//mon_out.execute();
			scb.execute();
		join_any
	endtask
	
	//task to reset, then run the test function
	//should reset be a function in the driver like the slides?


endclass: environment