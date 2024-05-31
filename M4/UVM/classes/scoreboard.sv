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
	`uvm_component_utils(fifo_scoreboard); // Register the component with the factory

    // Declare analysis port
    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) scoreboard_port;
    fifo_transaction tx;

    // Local memory, ptrs and count used to check FIFO
    localparam DEPTH = 2**ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1]; 
    int write_ptr = 0;
    int read_ptr = 0;
    int count = 0;


    // Constructor
	function new(string name = "fifo_scoreboard", uvm_component parent);
		super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
	endfunction: new
	
    // Build phase
	function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_HIGH);

        // Use new constructor to create the analysis ports
        scoreboard_port = new("scoreboard_port", this);
    endfunction: build_phase

    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_HIGH);
    
    endfunction: connect_phase
    
    // Run Phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);  
        `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_HIGH);
   
    endtask: run_phase


    function void write(fifo_transaction tx);
        forever begin
            if (tx.wr_en && !tx.full) begin
                scb_write(tx.data_in);
                `uvm_info(get_type_name(), $sformatf("Scoreboard tx \t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h", tx.wr_en, tx.rd_en, tx.data_in, tx.data_out), UVM_DEBUG);
            end
            else if (tx.rd_en && !tx.empty) begin
                read_and_check(tx.data_out);
                `uvm_info(get_type_name(), $sformatf("Scoreboard tx \t|  wr_en: %b  |  rd_en: %b  |  data_in: %h  |  data_out: %h", tx.wr_en, tx.rd_en, tx.data_in, tx.data_out), UVM_DEBUG);
            end 
        end
    endfunction : write

    
    function void scb_write(input logic [DATA_WIDTH-1:0] data);
        if (count < DEPTH) begin
            memory[write_ptr] = data;
            write_ptr = (write_ptr + 1) % DEPTH; //Modulo keeps values in range from 0 to DEPTH-1
            count++;
        end else begin
            `uvm_error("SCOREBOARD", "Write to full FIFO attempted.");
        end
    endfunction : scb_write
  
    function void read_and_check(input logic [DATA_WIDTH-1:0] data);
        if (count > 0) begin
            logic [DATA_WIDTH-1:0] expected_data = memory[read_ptr];
            if (data != expected_data) begin
                `uvm_error("SCOREBOARD", $sformatf("Data mismatch!: expected %h, got %h at read pointer %0d", expected_data, data, read_ptr));  
            end
            else begin
                `uvm_info("SCOREBOARD", $sformatf("Data match!: expected %h, got %h at read pointer %0d", expected_data, data, read_ptr), UVM_HIGH);
            end
            read_ptr = (read_ptr + 1) % DEPTH; //Modulo keeps values in range from 0 to DEPTH-1
            count--;
        end else begin
            `uvm_error("SCOREBOARD", "Read from empty FIFO attempted.");
        end
    endfunction : read_and_check

endclass 
