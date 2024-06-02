/*********************************************
//	Scoreboard Class for our UVM Based 
//  Testbench for an Asynchronous FIFO Module
//
//
//
//
//	Author: Alexander Maso
//	 
*********************************************/
class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
    
    
    uvm_analysis_fifo #(fifo_transaction) received_fifos;
    uvm_analysis_fifo #(fifo_transaction) expected_writes;
    uvm_analysis_fifo #(fifo_transaction) expected_reads;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        received_fifos = new("received_fifos", this);
        expected_writes = new("expected_writes", this);
        expected_reads = new("expected_reads", this);
    endfunction : new

    task run_phase(uvm_phase phase);
        fifo_transaction item;
        fifo_transaction exp_write;
        fifo_transaction exp_read;
        forever begin
            received_fifos.get(item);
            if (item.op == WRITE) begin
                expected_writes.get(exp_write);
                assert(item.data == exp_write.data) else `uvm_error("FIFO_SB", "Data mismatch on write");
            end
            else if (item.op == READ) begin
                expected_reads.get(exp_read);
                assert(item.data == exp_read.data) else `uvm_error("FIFO_SB", "Data mismatch on read");
            end
        end
    endtask
endclass
