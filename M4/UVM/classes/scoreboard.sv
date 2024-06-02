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
    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) scoreboard_port_wr;
    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) scoreboard_port_rd;
    fifo_transaction tx_stack_wr[$];
    fifo_transaction tx_stack_rd[$];

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
        
        forever begin        
            fifo_transaction current_tx_rd;
            fifo_transaction current_tx_wr;

            wait(tx_stack_wr.size() > 0);
            wait(tx_stack_rd.size() > 0);
        
            current_tx_rd = tx_stack_rd.pop_front();
            current_tx_wr = tx_stack_wr.pop_front();

            if (current_tx_wr.wr_en && !current_tx_wr.full) begin
                scb_write(current_tx_wr.data_in);
                `uvm_info(get_type_name(), $sformatf("Scoreboard tx \t|  wr_en: %b  |  data_in: %h  |", current_tx_wr.wr_en, current_tx_wr.data_in), UVM_MEDIUM);
            end
            if (current_tx_rd.rd_en && !current_tx_rd.empty) begin
                read_and_check(current_tx_rd.data_out);
                `uvm_info(get_type_name(), $sformatf("Scoreboard tx \t|  rd_en: %b  |  data_out: %h  |", current_tx_rd.rd_en, current_tx_rd.data_out), UVM_MEDIUM);
            end
        end

    endtask: run_phase

    function void write(fifo_transaction tx);
        forever begin
            if (tx.op==READ) begin
                tx_stack_rd.push_back(tx);
            end
            if (tx.op==WRITE) begin
                tx_stack_wr.push_back(tx);
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
