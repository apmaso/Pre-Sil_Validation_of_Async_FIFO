/*********************************************
//	Scoreboard Class for the OOP/Class Based 
//  Testbench for an Asynchronous FIFO Module
//
//
//  @ shift() saves the past value of rd_eb and the data word that
//  read_ptr points to in the local fifo
//  @ write() creates a local fifo and writes data_in to the fifo.  
//  @ read_and_check()reads from the local fifo and compares it 
//  against data_out of the bfm.  
//  @ execute() runs the write() and the read_and_check() functions indefinitely
//
//
//	Author: Alexander Maso
//	 
*********************************************/

class scoreboard extends uvm_component;
	`uvm_component_utils(scoreboard);
	
	virtual fifo_bfm bfm;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual fifo_bfm)::get(null, "*", "bfm", bfm))
			$fatal("Failed to get BFM");
	endfunction: build phase
    
    mailbox drv2scb, mon2scb;
    transaction tx_wr, tx_rd;;

    function new (mailbox drv2scb, mailbox mon2scb);
        this.drv2scb = drv2scb;
        this.mon2scb = mon2scb;
    endfunction : new

    // Local memory, ptrs and count used to check FIFO
    localparam DEPTH = 2**ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1]; 
    int write_ptr = 0;
    int read_ptr = 0;
    int count = 0;


    task tb_write(input logic [DATA_WIDTH-1:0] data);
        if (count < DEPTH) begin
            memory[write_ptr] = data;
            write_ptr = (write_ptr + 1) % DEPTH; //Modulo keeps values in range from 0 to DEPTH-1
            count++;
        end else begin
            $display("Scoreboard Error: Write to full FIFO attempted.");
        end
     endtask : tb_write
  
    task read_and_check(input logic [DATA_WIDTH-1:0] data);
        if (count > 0) begin
            logic [DATA_WIDTH-1:0] expected_data = memory[read_ptr];
            if (data != expected_data) begin
                $error("Data mismatch!: expected %h, got %h at read pointer %0d", expected_data, data, read_ptr);
            end
            else begin
                $display("Data match!: expected %h, got %h at read pointer %0d", expected_data, data, read_ptr);
            end
            read_ptr = (read_ptr + 1) % DEPTH; //Modulo keeps values in range from 0 to DEPTH-1
            count--;
        end else begin
            $display("Scoreboard Error: Read from empty FIFO attempted.");
        end
    endtask : read_and_check


    task write();
        repeat(TX_COUNT_WR) begin
            drv2scb.get(tx_wr);
            if (tx_wr.wr_en && !tx_wr.full) begin
                $display("Scoreboard tx_wr\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h", tx_wr.wr_en, tx_wr.rd_en, tx_wr.data_in, tx_wr.data_out);
                tb_write(tx_wr.data_in);
            end
        end
    endtask : write

    task read();
        repeat(TX_COUNT_RD) begin
            mon2scb.get(tx_rd);
            if (tx_rd.rd_en && !tx_rd.empty) begin
                read_and_check(tx_rd.data_out);
                $display("Scoreboard tx_rd\t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h", tx_rd.wr_en, tx_rd.rd_en, tx_rd.data_in, tx_rd.data_out);
            end
        end
    endtask : read

    task run_phase(uvm_phase phase);
        $display("********** Scoreboard Started **********"); 
        fork
            write();
            read();
        join_none
        $display("********** Scoreboard Ended **********"); 
  endtask : run_phase  
      
endclass 
