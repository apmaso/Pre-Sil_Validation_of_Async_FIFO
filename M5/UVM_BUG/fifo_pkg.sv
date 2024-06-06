package fifo_pkg;
	import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Parameters for FIFO configuration
	parameter DATA_WIDTH = 8, ADDR_WIDTH = 6;
	parameter CYCLE_TIME_WR = 12.5;  // 80 MHz
	parameter CYCLE_TIME_RD = 20;    // 50 MHz
	
	// Parameters for the testbench	
	parameter TX_COUNT_WR = 30;
	parameter TX_COUNT_RD = 30;
	parameter READ_DELAY = 5;


	`include "transaction.sv"
	`include "sequence.sv"
	`include "sequencer.sv"
	`include "driver.sv"
	`include "monitor.sv"
    `include "agent.sv"
	`include "scoreboard.sv"
	`include "coverage.sv"
    `include "environment.sv"
	`include "test.sv"

endpackage : fifo_pkg
