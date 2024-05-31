/****************************************************
*
*	FIFO package containing all the classes and
*	parameters for the OOP/Class Based Testbench
* 	for an Asynchronous FIFO Module 
*
*
*
*	Author: Alexander Maso
****************************************************/

package fifo_pkg;
	// Parameters for FIFO configuration
	parameter DATA_WIDTH = 8, ADDR_WIDTH = 6;
	parameter CYCLE_TIME_WR = 12.5;  // 80 MHz
	parameter CYCLE_TIME_RD = 20;    // 50 MHz
	parameter TX_COUNT = 70;

//	`include "coverage.sv"
	`include "transaction.sv"
	`include "generator.sv"
	`include "driver.sv"
	`include "monitor.sv"
	`include "scoreboard.sv"
	`include "testbench.sv"
	
endpackage : fifo_pkg
