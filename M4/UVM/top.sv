/*********************************************
//	 Top Module for UVM Testbench
//  of an Asynchronous FIFO Module
//	
//  Contains instantaion of the bfm and connection
//  to the dut as well as our three mailboxes.  Mailboxes
//  are used to pass the transaction packet between
//  the generator, driver, and monitor.  Also creates
//  an instance of the testbench class, passes the constructor
//  the bfm and calls the execute() function
//
//	 Alexander Maso
//	 
*********************************************/
module top;
  import   fifo_pkg::*;
  import   uvm_pkg::*;
   
   fifo_bfm     bfm();
   
   // Instantiate the dut and connect it with the Bus Func Model
   fifo_top dut (.clk_wr(bfm.clk_wr), .clk_rd(bfm.clk_rd), .rst_n(bfm.rst_n), 
                 .wr_en(bfm.wr_en), .rd_en(bfm.rd_en), .data_in(bfm.data_in),
                 .data_out(bfm.data_out), .full(bfm.full), .empty(bfm.empty), 
                 .half(bfm.half));


   initial begin
      // Type, Caller, Path, Name, Value
      uvm_config_db #(virtual fifo_bfm)::set(null, "*", "bfm", bfm);
      uvm_top.finish_on_completion = 1; // Calls $finish(1) when all tests are done
      run_test("my_first_test");
   end


endmodule : top
