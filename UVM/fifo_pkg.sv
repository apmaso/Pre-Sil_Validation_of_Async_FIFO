package fifo_pkg;
	import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Parameters for FIFO configuration
	parameter DATA_WIDTH = 8, ADDR_WIDTH = 6;
	parameter CYCLE_TIME_WR = 12.5;  // 80 MHz
	parameter CYCLE_TIME_RD = 20;    // 50 MHz
	
	// Parameters for the testbench	
	parameter BURST_SEQ_CNT	= 2;  // Number of burst_test sequences
	parameter BURST_SIZE   	= 120;  // Number of transactions in each burst
	parameter BUFFER_CNT	= 1;  // Number of buffer tx between burst_test

	parameter FLAG_SEQ_CNT  = 2;  // Number of flag_test sequences
    parameter FLAG_TX_CNT   = 3;  // Number of times each flag_test toggles the three flags

	parameter RANDOM_TX_CNT = 750;  // Number of random_test transactions


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
